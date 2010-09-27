module Pegasus
  module ClassMethods
    def instance; @instance ||= new; end

    extend Forwardable
    def_delegators :redis, :rpush, :llen, :lindex, :get, :set, :del, :lpop, :incrby

    def playout *svcs
      @svcs ||= []
      @svcs.concat svcs.map{ |s| s.instance }
      true while @svcs.any?{ |s| s.play }
    end

    def blpop key, timeout = 0
      true while (x = blocking_redis.blpop(key, 10)).blank?
      x
    end

    def queue_with_ticket(ticket, *a)
      a[0] = "do_#{a[0]}"
      logger.debug "queueing #{a.inspect}"
      rpush wait_queue_key, "#{Time.unix} #{ticket || '-'} #{serializer.dump(a)}"
      trouble?
    end

    def next_ticket_no
      if !@max or @current && @current >= @max
        @max = incrby tickets_key, 1000
        @min = @max - 1000
        @current = @min
      end
      @current += 1
      "#{ticket_prefix}#{@current}"
    end

    def wait ticket_no
      @instance.play if @instance
      logger.debug "waiting on ticket #{ticket_no}"
      blpop ticket_no, 0
      del ticket_no
    end

    def track *a
      ticket_no = next_ticket_no
      queue_with_ticket(ticket_no, *a)
      ticket_no
    end

    def method_missing(*a)
      super unless method_defined? "do_#{a.first}"
      raise "blocks are not allowed for queued methods" if block_given?
      queue_with_ticket(nil, *a)
    end

    def trouble?
      return false unless next_task = lindex(wait_queue_key, 0)
      seconds_behind = Time.unix - next_task.split(' ', 2)[0].to_i
      return false unless seconds_behind > 5
      logger.warn "#{wait_queue_key} is running #{seconds_behind}s behind"
      return false unless seconds_behind > 20
      return false unless current_task = get(processing_key)
      t, etc = current_task.split(' ', 2)
      seconds = Time.unix - t.to_i
      return false unless seconds > 20
      logger.warn "has been #{etc ? "running task #{etc.inspect}" : "idle"} for #{seconds}s"
      return true
    end
  end
end

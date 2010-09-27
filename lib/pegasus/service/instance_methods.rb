module Pegasus
  class Service
    module InstanceMethods

      def run_task taskspec = nil
        taskspec or begin
          return unless pair = blpop(wait_queue_key, 10)
          taskspec = pair[1]
        end
        set processing_key, "#{Time.unix} #{taskspec}"
        queued_at, ticket_no, task_marshal = taskspec.split(' ', 3)
        args = serializer.load(task_marshal)
        logger.debug "running task #{args.inspect}"
        result = "-"
        begin
          send(*args)
        rescue Exception => e
          logger.error("ERROR running task #{taskspec.inspect}: #{e.message}:: #{e.backtrace.join("\n\t")}")
          result = serializer.dump(e)
          raise e if raise_errors
        end
        unless ticket_no == '-'
          logger.debug "posting ticket #{ticket_no}"
          rpush ticket_no, result
        end
        set processing_key, Time.unix
      end

      alias_method :call, :run_task

      def do_noop
        logger.info "#{self.class.name} NOOP"
      end

      def play
        while next_task = lpop(wait_queue_key)
          run_task next_task
          did_something = true
        end
        did_something
      end

    end
  end
end

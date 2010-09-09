require 'thread'
require 'pegasus/service/class_methods'
require 'pegasus/service/instance_methods'

module Pegasus
  class Service
    extend Configurer
    config :redis           do Thread.current[:redis]          ||= ::Redis.new; end
    config :blocking_redis  do Thread.current[:blocking_redis] ||= ::Redis.new(:timeout=>0); end
    config :logger          do Logger.new(STDERR); end
    config :serializer      do Marshal; end
    config :redis_prefix    do "redis_svc_" end
    config :wait_queue_key  do "#{redis_prefix}wait_#{name}"; end
    config :processing_key  do "#{redis_prefix}process_#{name}"; end
    config :tickets_key     do "#{redis_prefix}tickets_#{name}"; end
    config :ticket_prefix   do "#{redis_prefix}ticket_#{name}_"; end
    config :raise_errors    do true; end

    extend Forwardable
    def_delegators :redis, :rpush, :llen, :lindex, :get, :set, :del, :lpop, :incrby, :blpop

    extend ClassMethods
    def_delegators 'self.class', :track, :wait
    include InstanceMethods
  end
end

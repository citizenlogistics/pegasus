require 'forwardable'
require 'configurer'

class Time
  def self.unix
    Time.now.utc.to_i
  end
  def self.float
    Time.now.utc.to_f
  end
end

require 'pegasus/service'

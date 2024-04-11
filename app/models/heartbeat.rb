require "timeout"

class Heartbeat
  attr_reader :string, :status

  def initialize
    if services_up?
      @string = "OK"
      @status = 200
    else
      @string = "failed"
      @status = 500
    end
  end

  def services_up?
    [memcached_up?].all?
  end

  def memcached_up?
    host = ENV["MEMCACHE_SERVERS"]
    memcached_client = Dalli::Client.new(ENV["MEMCACHE_SERVERS"])
    memcached_client.alive!
    true
  rescue
    false
  end
end

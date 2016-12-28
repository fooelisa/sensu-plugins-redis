#!/usr/bin/env ruby
#
# Checks if a redis set operation succeeds
# ===
#
# Depends on redis gem
# gem install redis
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-plugin/check/cli'
require 'redis'

class RedisSetCheck < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h HOST',
         long: '--host HOST',
         description: 'Redis Host to connect to',
         required: false,
         default: '127.0.0.1'

  option :port,
         short: '-p PORT',
         long: '--port PORT',
         description: 'Redis Port to connect to',
         proc: proc(&:to_i),
         required: false,
         default: 6379

  option :database,
         short: '-n DATABASE',
         long: '--dbnumber DATABASE',
         description: 'Redis database number to connect to',
         proc: proc(&:to_i),
         required: false,
         default: 0

  option :password,
         short: '-P PASSWORD',
         long: '--password PASSWORD',
         description: 'Redis Password to connect with'

  option :key,
         long: '--key KEY',
         description: 'Argument passed in as data key, defaults to "key"',
         required: false,
         default: 'key'

  option :value,
         long: '--value VALUE',
         description: 'Argument passed in as data value, defaults to "value"',
         required: false,
         default: 'value'

  def run
    options = { host: config[:host], port: config[:port], db: config[:database] }
    options[:password] = config[:password] if config[:password]
    redis = Redis.new(options)

    # length = redis.keys(config[:pattern]).size
    set = redis.set(config[:key], config[:value])

    if set == 'OK'
      ok "Redis set succeeded"
    else
      critical "Redis set failed"
    end
  rescue
    unknown "Could not connect to Redis server on #{config[:host]}:#{config[:port]}"
  end
end

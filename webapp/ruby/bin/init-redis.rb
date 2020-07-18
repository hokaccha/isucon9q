require 'mysql2'
require 'redis'
require 'hiredis'
require 'json'

redis = Redis.new(
  host: 'isucon9-1',
  driver: :hiredis
)

redis.flushdb

db= Mysql2::Client.new(
  'host' => ENV['MYSQL_HOST'] || 'isucon9-3',
  'port' => ENV['MYSQL_PORT'] || '3306',
  'database' => ENV['MYSQL_DBNAME'] || 'isucari',
  'username' => ENV['MYSQL_USER'] || 'isucari',
  'password' => ENV['MYSQL_PASS'] || 'isucari',
  'charset' => 'utf8mb4',
  'database_timezone' => :local,
  'cast_booleans' => true,
  'reconnect' => true,
)

db.query('select * from users').each do |user|
  redis.set("users:#{user['id']}", user.to_json)
end

redis.save

system 'sudo cp /var/lib/redis/dump.rdb /tmp'

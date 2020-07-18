lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'isucari/web'

if ENV['lp'] == '1'
  require 'rack-lineprof'
  use Rack::Lineprof, profile: 'isucari/web.rb'
end

if ENV['sp'] == '1'
  require 'stackprof'
  system 'rm -rf ./tmp'
  use StackProf::Middleware, enabled: true,
    mode: :cpu,
    interval: 1000,
    save_every: 5,
    raw: true
end

run Isucari::Web

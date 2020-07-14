lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'isucari/web'

if ENV['lp'] == '1'
  require 'rack-lineprof'
  use Rack::Lineprof, profile: 'isucari/web.rb'
end

run Isucari::Web

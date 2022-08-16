#require 'colorize'
#require 'readline'

#require_relative 'ui'
#require_relative 'which'
require_relative 'logic'
#require_relative 'bucket'
#require_relative 'object'

trap("INT", "SIG_IGN")

begin
  @chila = Chila.new
  @chila.start
rescue StandardError => e
  puts "ERRO: #{e.full_message}"
end
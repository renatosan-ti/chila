#require_relative 'which'

class Uplink
	class << self
		def check_uplink_command
			# Fazer uma forma de detectar a arquitetura
			UI.print_install_uplink unless which('uplink')
		end

		def run_command(cmd, *args)	
			output = IO.popen(['uplink', cmd, *args], :err=>File::NULL).read	
			UI.print_uplink_output(cmd, output, *args)
		end
	end
end
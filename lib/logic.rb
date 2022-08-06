# Aqui ficará toda a lógica do programa
require 'readline'
require 'json'

require_relative 'ui'
require_relative 'bucket'
require_relative 'which'
#require_relative 'object'

class Chila	
	@prompt = "#{UI.instance_variable_get(:@appName).bold} #{%{> }.light_blue}"
	
	class << self
		def start_chila			
			#UI.clear_screen
			Uplink.check_command
			UI.show_welcome
			
			comp = proc { |s| UI.LIST.grep(/^#{Regexp.escape(s)}/) }

			Readline.completion_append_character = ''
			Readline.completion_proc = comp
			while line = Readline.readline(@prompt, true)
				parse_command(line.to_sym)
				exit if line =~ /^exit$|^quit$/i
			end
		end
		
		def parse_command(command)
			# command = Symbol
			# :help ou :"help ls"
			
			# "help ls"
			# cmd = help
			# args = ls
			cmd = command.to_s.partition(' ').first
			args = command.to_s.partition(' ').last
						
			unless cmd.nil?
				if UI.COMMAND.include?(cmd.to_sym)					
					# Encontrar uma forma de inserir várias classes
					run_command(UI.COMMAND[cmd.to_sym][:class], cmd, UI.COMMAND[cmd.to_sym][:method], *args.split)					
				else
					UI.command_not_found cmd unless cmd.empty?		
				end
			end
		end

		def run_command(klass, cmd, method, *args)
			# cmd = String
			# method = String
			# args = Array			
			const_get(klass).send(method.to_sym, *args) #if UI.COMMAND[cmd.to_sym][:command].include?(cmd)
		end
		 
		def show_help(*command)
			# command = Array
			if command.empty?
				Print.help
			else
				cmd = command.first.to_s
				begin
					Print.help_command cmd
				rescue
					UI.command_not_found cmd
				end
			end
		end

		def exit_chila; exit end
		def set_variable(variable); puts end
		def show_options
			Print.output
		end
	end
end

class Uplink
	class << self		
		def check_command
			# Fazer uma forma de detectar a arquitetura (arm ou x64, por exemplo)
			
			Print.install_uplink unless which('uplink')
			Print.uplink_no_access if Uplink.run_command("access", "list").nil?
		end

		def run_command(cmd, *args)							
			#output = IO.popen(['uplink', cmd, *args], :err => File::NULL) {}
			#puts output #unless output.empty?
			output = IO.popen(['uplink', cmd, *args], :err=>File::NULL).read
			return output unless output.lines.count.zero?
			
			# out = IO.popen(['uplink', 'ls', '-o=json', 'sj://coisas/'], :err=>File::NULL).read
			# out.each_line { |line| puts JSON.parse(line, {symbolize_names: true})[:kind] }

			#Print.uplink_output(cmd, output, *args) unless output.empty?
			#data_hash = JSON.parse(output.to_json)
			#p data_hash[:kind]
			#exit
		end

		# FIXME: erro ao rodar comando em máquina que não tem autorização pra rodar o uplink
		def ls_output
			array = []
			dale = IO.popen(['uplink', 'ls', '-r', '-o=json'], :err=>File::NULL).read.each_line { 
                |line|
                    name = JSON.parse(line, {symbolize_names: true})[:Name]
                    created = JSON.parse(line, {symbolize_names: true})[:Created]
                    
                    array << [Print.truncate(name, 10), created.split(/\s|T|\./)[0..1].join(' ')]  
            }
			return array			
		end
		
		def ls_output_bucket(*args)
            bucket = args.join            
            
            arrFolder = []
            arrFile = []
			array = []

            IO.popen(['uplink', 'ls', '-o=json', bucket], :err=>File::NULL).read.each_line { 
                |line|
                    kind = JSON.parse(line, {symbolize_names: true})[:kind]
                    size = JSON.parse(line, {symbolize_names: true})[:size]
                    created = JSON.parse(line, {symbolize_names: true})[:created]
                    key = JSON.parse(line, {symbolize_names: true})[:key]
                    
                    arrFolder << key if kind == "PRE"
                    arrFile << [key, size, created] if kind == "OBJ"
            }      
            
			array = [bucket, arrFolder, arrFile]

			return array
        end
	end
end

# FIXME Retorno de valores incorretos
def bytes_to_human(bytes)
	unless bytes.nil?
		case
			when (bytes <= 1023) then Print.byte(bytes)
			when (bytes >= 1024) && (bytes <= 1048575) then Print.kbyte(bytes)
			when (bytes >= 1048576) && (bytes <= 1073741823) then Print.mbyte(bytes)
			when (bytes >=1073741824) then Print.gbyte(bytes)
		end	
	end
end
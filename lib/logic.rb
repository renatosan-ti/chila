# Aqui ficará toda a lógica do programa
require 'readline'
require 'json'

require_relative 'ui'
require_relative 'bucket'
require_relative 'which'
#require_relative 'misc'
require_relative 'object'
require_relative 'uplink'

class Chila			      
  def start			
    #UI.clear_screen
    Uplink.check_command    
    UI.show_welcome    
    
    @prompt = "#{UI.instance_variable_get("@appName").bold} #{%{> }.light_blue}"    
    @comp = proc { |s| UI.instance_variable_get("@list").grep(/^#{Regexp.escape(s)}/) }

    Readline.completion_append_character = ''
    Readline.completion_proc = @comp
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
    begin
      cmd = command.to_s.partition(' ').first
      args = command.to_s.partition(' ').last
          
      unless cmd.nil?
        if UI.instance_variable_get("@command").include?(cmd.to_sym)              
          run_command(UI.instance_variable_get("@command")[cmd.to_sym][:class], cmd, UI.instance_variable_get("@command")[cmd.to_sym][:method], *args.split)
        else
          UI.command_not_found cmd unless cmd.empty?		
        end
      end
    rescue StandardError => e
      UI.err "[parse_command] #{e.full_message}"
    end 
  end

  def run_command(classe, cmd, metodo, *args)
    # cmd = String
    # method = String
    # args = Array	
    
    #puts "Comando: #{cmd}"
    #puts "Classe: #{classe}"
    #puts "Método: #{metodo}"
    #p Module.const_get(classe)
    begin
      Module.const_get(classe).send("#{metodo}", *args)
    rescue StandardError => e
      UI.err "[run_command] #{e.full_message}"
    end    
  end
    
  def self.show_help(*command)
    # command = Array
    if command.empty?
      Print.help
    else
      cmd = command.first.to_s
      begin
        @print.help_command cmd
      rescue
        @ui.command_not_found cmd
      end
    end
  end

  def self.exit_chila; exit end
  def set_variable(variable); puts end
  def self.show_options
    Print.output
  end
end

class Uplink	
  def check_command
    # Fazer uma forma de detectar a arquitetura (arm ou x64, por exemplo)
    
    @print.install_uplink unless which('uplink')
    @print.uplink_no_access if self.run_command("access", "list").nil?
  end

  def run_command(cmd, *args)							
    output = IO.popen(['uplink', cmd, *args], :err=>File::NULL).read
    return output unless output.lines.count.zero?
  end

  # FIXME: erro ao rodar comando em máquina que não tem autorização pra rodar o uplink
  def self.ls_output
    array = []
    IO.popen(['uplink', 'ls', '-r', '-o=json'], :err=>File::NULL).read.each_line do |line|
      name = JSON.parse(line, {symbolize_names: true})[:Name]
      created = JSON.parse(line, {symbolize_names: true})[:Created]
      
      array << [Print.truncate(name, 10), created.split(/\s|T|\./)[0..1].join(' ')]        
    end
    return array			
  end

  def self.ls_output_bucket(*args)
    bucket = args.join            

    @arrFolder = []
    @arrFile = []
    array = []

    IO.popen(['uplink', 'ls', '-o=json', bucket], :err=>File::NULL).read.each_line do |line|
      kind = JSON.parse(line, {symbolize_names: true})[:kind]      
      size = JSON.parse(line, {symbolize_names: true})[:size]
      created = JSON.parse(line, {symbolize_names: true})[:created]
      key = JSON.parse(line, {symbolize_names: true})[:key]

      @arrFolder << key if kind.include?("PRE")
      @arrFile << [key, size, created] if kind.include?("OBJ")
    end      

    array = [bucket, @arrFolder, @arrFile]
    return array  
  end

  # FIXME Retorno de valores incorretos
  def self.bytes_to_human(bytes)
    unless bytes.nil?
      case
        when (bytes <= 1023) then Print.byte(bytes)
        when (bytes >= 1024) && (bytes <= 1048575) then Print.kbyte(bytes)
        when (bytes >= 1048576) && (bytes <= 1073741823) then Print.mbyte(bytes)
        when (bytes >=1073741824) then Print.gbyte(bytes)
      end	
    end
  end
end
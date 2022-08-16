#require_relative 'which'

class Uplink  
  # TODO implementar isso
  def self.check_version; end

  # TODO implementar isso
  def self.update_version
    # curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip
    # unzip -o uplink_linux_amd64.zip
    # sudo install uplink /usr/local/bin/uplink
  end

  def self.check_command  
    Print.install_uplink unless which('uplink')
  end  

  def self.run_command(cmd, *args)	
    output = IO.popen(['uplink', cmd, *args], :err=>File::NULL).read	
    #UI.print_uplink_output(cmd, output, *args)
  end
end
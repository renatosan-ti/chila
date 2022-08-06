# Aqui ficará tudo que for relativo à interface / texto

require 'colorize'

# Variáveis  

class UI
    @appName = "chila"
    @appVersion = "0.0.1"
        
    @COMMAND = {
        # - chila commands -
        options: { class: "Chila", method: "show_options", description: ["Show all variables"], example: nil, hint: nil },
        set: { class: "Chila", method: "set_variable", description: ["Set variable value from environment","Type options to see all variables available"], example: ["set parallel_tasks 4","set history_size 200"], hint: nil },    
        exit: { class: "Chila", method: "exit_chila", description: ["Closes #{@appName.light_blue}"], example: nil, hint: nil },
        q: { class: "Chila", method: "exit_chila", description: ["Same as exit"], example: nil, hint: nil },
        quit: { class: "Chila", method: "exit_chila", description: ["Same as exit"], example: nil, hint: nil },
        help: { class: "Chila", method: "show_help", description: ["This help"], example: nil, hint: nil },
        '?': { class: "Chila", method: "show_help", description: ["Same as help"], example: nil, hint: nil },
        clear: { class: "UI", method: "clear_screen", description: ["Clear screen"], example: nil, hint: nil },
        # - uplink commands -         
        ls: { class: "Bucket", method: "list_content", description: ["Lists buckets, prefixes, or objects"], example: ["ls sj://mybucket"], hint: ["before list buckets, run ls command to show all available buckets"] },
        mb: { class: "Bucket", method: "create_bucket", description: ["Create a new bucket"], example: ["mb sj://mynewbucket"], hint: ["before create a new bucket, run ls command to check if bucket already exists"] },
        rb: { class: "Bucket", method: "remove_bucket", description: ["Remove a bucket"], example: ["rb sj://mybucket"], hint: "before remove a bucket, run ls command to show all available buckets" },
        rm: { class: "Object", method: "remove_object", description: ["Remove an object"], example: ["rm sj://mybucket/object1", "rm sj://myobjects/*", "rm sj://pictures/*.jpg"], hint: nil },
        cp: { class: "Object", method: "copy_content", description: ["Copies files or objects into or out of storj"], example: ["cp /my/local/files sj://mybucket"], hint: ["at lease one parameter must be a bucket"] },
        mv: { class: "Object", method: "move_content", description: ["Moves files or objects"], example: ["mv sj://mybucket/object1 sj://anoter-bucket","mv sj://pictures/* sj://backup-pictures"], hint: "can be use to rename objects in a bucket too" }
    }
    @LIST = @COMMAND.keys.to_a

    class << self
        attr_reader :appName, :appVersion, :COMMAND, :LIST       

        def show_welcome
            print "\n  Welcome to ".light_blue + @appName.bold + " v#{@appVersion}".light_blue +
            "\n  Type #{%{help}.light_blue} for help\n\n".bold
        end

        def err(text); print " ERR ".bold.on_light_red + " #{text}\n" end
        def msg(text); print " INF ".bold.on_blue + " #{text}\n" end
        def progress(text); print " >>> ".blue + "#{text}\n" end
        def wrn(text)
            print " WRN ".bold.on_red + " #{text}"
            answer = gets.chomp
            return answer
        end

        def command_not_found(command); err "Command not found: #{command.red}" end
        def clear_screen; puts "\e[H\e[2J" end 
    end
end

class Print
    class << self
        # mais recente
        def help   
            UI.COMMAND.each_pair { |cmd, desc| puts "%10s %s %s\n" % [ cmd, "│".blue, desc[:description].first ] }
        end

        def help_command(command)        
            desc = UI.COMMAND[command.to_sym][:description]
            example = UI.COMMAND[command.to_sym][:example]
            hint = UI.COMMAND[command.to_sym][:hint]

            print "Description: \n".bold + "%s\n".rjust(5) % desc    
            print "Example: \n".bold ; example.each { |s| puts "%s\n".rjust(5) % s} unless example.nil?    
            print "\nHint: \n".green + "%s\n".rjust(5).light_green % hint unless hint.nil?    
        end

        def install_uplink
            UI.msg "uplink seems not to be installed. Install? (Y/n)"
            exit
        end

        def uplink_no_access
            UI.err "uplink doesn't work correctly. Please run uplink setup"
            exit
        end
       
        def ls_output            
            array = Uplink.ls_output
            
            puts " Buckets ".on_blue
            print "%12s %s %s\n".bold % ["Name", "│".blue, "Date Added".bold ]
            array.sort.each { |s| print "%12s %21s\n" % [s[0], s[1].gsub("-","/")] }
        end

        def ls_output_bucket(*args)
            bucket = args.join            
            arrFolder = []
            arrFile = []

            array = Uplink.ls_output_bucket(bucket)
                        
            print " %s %s %s\n" % ["Buckets".bold, ">".blue, bucket.split('//')[1]]
            print "  %15s %s %24s %s %10s\n".bold % ["Name", "│".blue, "Size".bold, "│".blue, "Upload Date".bold]

            arrFolder.sort.each { |s| print "  %15s\n".light_blue % [s.chomp('/')] } unless array
            arrFile.sort.each { |s| print "  %15s %12s %21s\n" % [Print.truncate(s[0], 12), bytes_to_human(s[1]), s[2].gsub("-","/")] }
        end

        def output()
            puts "Mostrando options"
        end

        def bucket_empty; UI.msg "This bucket is empty" end        
        def bucket_exists(bucket); UI.msg "Bucket #{bucket.bold} already exists" end
        def bucket_empty_exists(bucket); UI.msg "Bucket #{bucket.bold} exists and is empty" end
        def bucket_invalid(bucket); UI.err "Invalid bucket #{bucket.bold}" end

        def bucket_not_found(bucket); UI.err "Bucket #{bucket.bold} not found" end
        def bucket_not_empty(bucket); UI.wrn "This bucket isn't empty. Remove anyway? (Y/N) " end

        def object_not_found(object); UI.err "Object #{object.bold} not found" end
            
        def removing(arg); UI.progress "Removing #{arg.bold} bucket..." end
        def removing_bucket?(bucket); UI.msg "#{bucket.bold} is a bucket. To remove, type rb instead" end
        def creating(arg); UI.progress "Creating #{arg.bold} bucket..." end
        
        def byte(bytes); "#{bytes} B" end

        def kbyte(bytes)
            integer = bytes / 1024
            decimal = bytes * 100 / 1024    
            "#{integer}.#{decimal.to_s.slice(-2, 2)} KB"    
        end

        def mbyte(bytes)
            integer = bytes / 1024 / 1024
            decimal = bytes * 100 / 1024 / 1024    
            "#{integer}.#{decimal.to_s.slice(-2, 2)} MB"
        end

        def gbyte(bytes)
            integer = bytes / 1024 / 1024 / 1024
            decimal = bytes * 100 / 1024 / 1024 / 1024   
            "#{integer}.#{decimal.to_s.slice(-2, 2)} GB"
        end 
        
        # From https://stackoverflow.com/a/19048598
        def truncate(string, max)
            string.length > max ? "#{string[0...max]}..." : string
        end
    end
end
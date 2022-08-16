require 'json'
require_relative 'ui'

# Funcionando 100%
# Não precisa mexer mais:
# - check_if_exists
# - list_content
# - remove_bucket
# - create_bucket

class Bucket  
  def self.check_if_exists(bucket)     
    # exitstatus:
    # -----------
    # 0 - bucket vazio válido
    # 1 - bucket inválido
    # nil - bucket cheio válido

    # when 98 then Print.bucket_invalid(bucket)
    # when 99 then Print.bucket_not_found(bucket)
    # TODO refazer esses códigos de status
    begin                
      return 90 if bucket.length < 8                
      unless bucket.empty?
        if bucket.split('/')[2].length.between?(3, 63)                  
          output = IO.popen(['uplink', 'ls', bucket], :err=>File::NULL) {}
          #if output =~ /^PRE/
          #    puts "#{bucket} é um bucket"
          #else
          #    puts "#{bucket} é um objeto"
          #end
          status = $?.exitstatus
        else
          status = 98
        end
      else 
        status = 99
      end
      rescue StandardError => e
        @ui.err e.message            
      else
        return status
      end
  end

  def self.list_content(*args)            
    begin      
      bucket = args.join  

      if bucket.empty?
        Print.ls_output
      else
        # 0 - bucket vazio válido
        # 1 - bucket inválido
        # nil - bucket cheio válido
        case check_if_exists(bucket)
          when 0 then UI.msg "Bucket #{bucket.light_blue} is empty"                            
          when nil then Print.ls_output_bucket(bucket)
          when 1 then UI.err "Bucket #{bucket.light_red} not found"
          when 90 then Print.bucket_invalid(bucket)
        end
      end
    rescue StandardError => e
      UI.err e.full_message                
    end
  end

  def self.remove_bucket(*args)    
    begin
      bucket = args.join  

      if bucket.empty?
        Print.help_command('rb')
      else
        # 0 - bucket vazio válido
        # 1 - bucket inválido
        # nil - bucket cheio válido        
        case Bucket.check_if_exists(bucket)
          when 0
            Print.removing(bucket)
            Uplink.run_command('rb', '--force', bucket)
          when 99 then Print.bucket_invalid(bucket)
          when nil
            question = Print.bucket_not_empty(bucket)
            case question.downcase
              when "y"
                Print.removing(bucket)
                Uplink.run_command('rb', '--force', bucket)
              when "n" then return
              else puts                                    
            end
          when 1
            Print.bucket_not_found(bucket)
          end
      end
    rescue StandardError => e
      UI.err e.message                            
    end
  end

  def self.create_bucket(*args)
    begin
      bucket = args.join  

      if bucket.empty?
        Print.help_command('mb')
      else
        # 0 - bucket vazio existe
        # 1 - bucket pode ser criado
        # nil - bucket cheio existe

        case Bucket.check_if_exists(bucket)
          when 0 then Print.bucket_empty_exists(bucket)                         
          when nil then Print.bucket_exists(bucket)
          when 98 then Print.bucket_invalid(bucket)
          when 99 then Print.bucket_not_found(bucket)                
          when 1                            
            Print.creating(bucket)
            Uplink.run_command("mb", bucket)                            
        end
      end
    rescue StandardError => e
      UI.err e.message                            
    end
  end

  # Ainda não sei onde usar
  def get_bucket_size(bucket)
    unless @bkt.check_if_exists(bucket)
      output = IO.popen(['uplink', 'ls'], :err=>File::NULL).read
      p output.lines.count
    end            
  end  
end

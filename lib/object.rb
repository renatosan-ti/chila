class Object
    class << self       
        def check_if_exists(object)     
            # exitstatus:
            # -----------
            # 0 - objeto não enontrado
            # 1 - bucket inválido
            # nil - bucket cheio válido

            # when 98 then Print.bucket_invalid(bucket)
            # when 99 then Print.bucket_not_found(bucket)

            # FIXME: encontrar uma forma de separar diretório de objeto em sj://bucket/diretorio/sub1/objeto
            begin                
                return 90 if object.length <= 8                  
                unless object.empty?                    
                    bucket = "sj://#{object.split('/')[2]}"
                    if Bucket.check_if_exists(bucket)                        
                        #if object.start_with?('sj://') # evita passar . ou qualquer outro caractere                      
                        output = IO.popen(['uplink', 'ls', object], :err=>File::NULL).read                            
                        if output.lines.count.zero?
                            status = 1
                        else
                            status = nil
                            #status = 99 if object.split('/')[3].nil?                        
                        end                                                    
                        #end                                              
                    end                    
                end
            rescue StandardError => e
                UI.err e.message            
            else
                return status
            end                        
        end
        
        # FIXME: encontrar uma forma de separar diretório de objeto em sj://bucket/diretorio/sub1/objeto
        def remove_object(*args)
            begin
                object = args.join  
                
                if object.empty?
                    Print.help_command('rb')
                else
                    # 0 - bucket vazio válido
                    # 1 - bucket inválido
                    # nil - bucket cheio válido                    
                    
                    case Object.check_if_exists(object)
                        when 1 then Print.object_not_found(object)
                        when 0 then Print.removing(object)
                    #        #Uplink.run_command('rb', '--force', bucket)
                        when 99 then Print.removing_bucket?(object)
                        when nil then Print.removing(object)
                    #        #question = Print.bucket_not_empty(bucket)
                    #        #case question.downcase
                    #        #    when "y"
                    #                Print.removing(object)
                    #        #        Uplink.run_command('rb', '--force', bucket)
                    #        #    when "n" then return
                    #        #    else puts                                    
                    #        #end
                    #    when 1
                    #        Print.bucket_not_found(object)
                    end
                end
            rescue StandardError => e
                UI.err e.message                            
            end
        end

        # Retorna o caminho do path (local ou remoto) ou nil
        def copy(klass, content)
            #klass = args.to_s.partition(' ').first        
            #content = args.to_s.partition(' ').last
            #begin
                puts "Classe: #{klass} -- Conteúdo: #{content} -- Retorno: [#{klass.check_if_exists(content)}]"
                #puts "#{content} existe? #{File.exist?(content)}"
                #exit
                #if klass.check_if_exists(content).nil?                    
                #    case klass.check_if_exists(content)
                #        # 0 - bucket válido vazio
                #        # nil - comando executado com sucesso
                #        # 1 - bucket inválido                
                #        # 99 - comando sem parâmetros - exibe a ajuda
                #        when 0 then Print.bucket_empty
                #        when 1 then Print.object_not_found(content)
                #        when 99 then Print.help_command("cp")
                #        when nil                            
                #            return content
                #    end
                #else
                #    return content if File.exist?(content)                    
                #end
            #rescue StandardError => e
            #    UI.err e.message
            #    raise
            #end

            #return @path
        end

        # Em andamento
        # Checar isso:
        # chila > cp sj://maria/dale /home/p0ng/
        # >>> Copying objects from sj://maria/dale to /home/p0ng/0 B [______________________________________________________________________________________________________________________________________________________________________________________________________________________________] ?% ? p/s
        # INF  Done.
        def copy_content(src, dst)
            source = copy(Object, src)
            destination = copy(Bucket, dst)

            # local: arquivo e diretório
            #        /diretório/arquivo
            # remoto: objeto, diretório e bucket
            #        sj://bucket/diretório/objeto
            #        sj://diretório/objeto
            #
            #
            # retorna 0
            # - cópia concluída sem erros
            # 
            # retorna 1
            # - quando source (arquivo) não existe
            # - quando source é um diretório (e não um arquivo)
            # - quando source (objeto) não existe
            # - quando bucket não existe
            # - quando o bucket é vazio (quando passa sj:// apenas)
            # - quando o source é um diretório e não existe

            #begin                
            #    source = copy(Object, src) #unless self.nil?
            #    destination = copy(Bucket, dst) #unless self.nil?

            #    #p source
            #    #p destination

            #    unless source.nil? and destination.nil?
            #        UI.progress "Copying from #{source.bold} to #{destination.bold} ..."
            #        Uplink.run_command("cp", source, destination)                   
            #    #else
            #    #    Print.help_command("cp")
            #    end
            #rescue StandardError => e
            #    UI.err e.message
            #    raise
            ##else
            ##    UI.msg "Done."
            #end
        end

        def move_content(source, destination); puts	end
    end
end
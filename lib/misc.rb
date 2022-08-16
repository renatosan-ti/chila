# Retirado de https://stackoverflow.com/a/26858652/4603968
class Hash
  def method_missing method_name, *args, &block
    return self[method_name] if has_key?(method_name)
    return self[$1.to_sym] = args[0] if method_name.to_s =~ /^(.*)=$/

    super
  end
end
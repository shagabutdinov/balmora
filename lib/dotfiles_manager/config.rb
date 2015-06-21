require 'json'

class DotfilesManager::Config

  def initialize()
    @path = File.join(DotfilesManager::PATH, 'config.json')
    reload()
  end

  def get(key)
    if !key.instance_of?(::Array)
      key = [key]
    end

    result =
      key.inject(@config) { |current, part|
        begin
          current = current.fetch(part)
        rescue KeyError
          raise "Config value #{key.inspect()} should be defined in " +
            "#{@path.inspect()}"
        end

        next current
      }

    return result.clone()
  end

  def set(key, value)

  end

  def reload()
    @config = JSON.parse(File.read(@path), {symbolize_names: true})
  end

end

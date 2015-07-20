class Balmora::Variables

  class Error < StandardError; end

  def self.factory(state)
    return self.new(state.extension, state.shell, state)
  end

  def initialize(extension, shell, state)
    @extension = extension
    @shell = shell
    @state = state
  end

  def get(name)
    if !name.instance_of?(::Array)
      name = name.split('.').collect() { |part| part.to_sym() }
    else
      name = name.clone()
    end

    parts = []
    provider = @extension.get(Balmora::Variables, name.shift()).factory(@state)

    result =
      name.
      inject(provider) { |current, part|
        parts.push(part)

        if current.instance_of?(::Hash)
          if !current.has_key?(part)
            raise Error.new("Unknown variable #{parts.join('.')}")
          end

          next current[part]
        end

        if !current.respond_to?(part)
          raise Error.new("Unknown variable #{parts.join('.')}")
        end

        next current.public_send(part)
      }

    return result
  end

  def inject(value, string = true)
    result =
      if value.instance_of?(::Array)
        _inject_array(value, string)
      elsif value.instance_of?(::Hash)
        _inject_hash(value, string)
      elsif value.instance_of?(::String) && string
        _inject_string(value)
      else
        value
      end

    return result
  end

  def _inject_array(value, string)
    result = []

    value.each_with_index() { |item, index|
      if item.instance_of?(::Hash) && item.keys() == [:'extend-variable']
        result += get(item[:'extend-variable'])
      else
        result.push(inject(item, string))
      end
    }

    return result
  end

  def _inject_hash(value, string)
    result = {}
    value.each() { |key, item|
      if key == :'include-variable'
        result.merge!(get(item))
      else
        result[key] = inject(item, string)
      end
    }

    return result
  end

  def _inject_string(value)
    value = value.gsub('\\\\', '{{__ESCAPED_SLASH__}}')

    if value.match(/(?<!\\)\#\{/)
      value = value.gsub('\\#', '#')
      value = eval('"' + value + '"')
    end

    value = value.gsub(/(?<!\\)\${(.*?)}/) { |string | get(string[2...-1]) }
    value = value.gsub(/(?<!\\)\%{(.*?)}/) { |string |
      command = @shell.expression(string[2...-1])
      @shell.run!([command], verbose: false, message: 'Executing embedded ' +
        'command: ').rstrip()
    }

    value = value.gsub('\\$', '$')
    value = value.gsub('\\%', '%')
    value = value.gsub('{{__ESCAPED_SLASH__}}', '\\')
  end

end
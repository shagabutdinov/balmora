module DotfilesManager::Utility

  def self.get_console_option(args, option)
    if option.instance_of?(::Array)
      option.each() { |option_item|
        result = get_console_option(args, option_item)
        if !result.nil?()
          return result
        end
      }

      return nil
    end

    if option.length == 1
      index = args.index('-' + get_arguments_key(option))
      if !index.nil?()
        return args[index + 1]
      end
    end

    if args.index('--no-' + get_arguments_key(option))
      return false
    end

    index = args.index('--' + get_arguments_key(option))
    if index.nil?()
      return nil
    end

    if args[index + 1].nil?()
      return true
    end

    return args[index + 1]
  end

  def self.get_arguments_key(key)
    key = key.gsub('_', '{{__DASH__}}')
    key = key.gsub('-', '_')
    key = key.gsub('{{__DASH__}}', '-')
    return key
  end

  def self.get_arguments_hash(args)
    result = {}
    args.each_with_index() { |value, index|
      if value.start_with?('--no-')
        result[get_arguments_key(value[5..-1])] = true
        next
      end

      if value.start_with?('--')
        if args[index + 1].nil?() || args[index + 1].start_with?('--')
          result[get_arguments_key(value[2..-1])] = true
          next
        end

        result[get_arguments_key(value[2..-1])] = args[index + 1]
      end
    }

    return result
  end

  def self.get_command_instance(manager, entry)
    type =
      entry[:type].
      to_s().
      split('-').
      collect() { |part| part.capitalize() }.
      join('').
      to_sym()

    if !DotfilesManager.const_defined?(type, false)
      raise "Unknown entry type #{entry[:type].inspect()} for entry " +
        "#{entry.inspect()}"
    end

    command = DotfilesManager.const_get(type, false).new(manager)
    command.entry = entry
    entry.each() { |key, value|
      if key == :type || key == :on # system keys
        next
      end

      if !command.respond_to?(:"#{key}=")
        raise "Unknown option #{key.inspect()} for entry " +
          "#{entry.inspect()}"
      end

      command.send(:"#{key}=", value)
    }

    return command
  end

end
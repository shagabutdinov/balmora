class Balmora::Arguments

  class Error < StandardError; end

  def self.parse(options, argv)
    shortcuts = _shortcuts(options)

    result = {}
    index = 0
    while index < argv.length
      arg = argv[index]

      if arg.start_with?('--')
        new_index = _parse_key(result, options, argv, index, arg[2..-1])
      elsif arg.start_with?('-')
        new_index = _parse_flags(result, options, argv, index, shortcuts, arg)
      else
        new_index = nil
      end

      if new_index.nil?()
        return result, argv[index..-1]
      end

      index = new_index + 1
    end

    return result, nil
  end

  protected

  def self._shortcuts(options)
    shortcuts = Hash[
      options.
        collect() { |key, option|
          if !option.has_key?(:shortcut)
            next nil
          end

          [option[:shortcut].to_sym(), key]
        }.
        compact()
    ]

    return shortcuts
  end

  def self._parse_flags(result, options, argv, index, shortcuts, arg)
    new_index = nil

    if arg.length > 2
      arg[1..-1].split('').each() { |flag|
        new_index = _parse_key(result, options, argv, index,
          shortcuts[flag.to_sym()], true)

        if new_index.nil?()
          return nil
        end
      }
    else
      new_index = _parse_key(result, options, argv, index,
        shortcuts[arg[1..-1].to_sym()])
    end

    return new_index
  end

  def self._parse_key(result, options, argv, index, key, flag_required = false)
    if key.nil?()
      return nil
    end

    key = key.to_sym()

    if !options.has_key?(key)
      return nil
    end

    option = options[key]
    if option[:flag] == true
      result[key] = true
    else
      if flag_required
        return nil
      end

      value = argv[index + 1]
      result[key] = value
      index += 1
    end

    return index
  end

  public

  def self.help(options)
    lines = []
    options.each() { |long, option|
      if option.instance_of?(::String)
        lines.push(option)
        next
      end

      arg =
        if option[:shortcut].nil?()
          (' ' * 7) + '--' + long.to_s()
        else
          (' ' * 4) + '-' + option[:shortcut] + ', ' + '--' + long.to_s()
        end

      lines.push([arg, option[:description]])
    }

    return format(lines)
  end

  def self.format(lines)
    indent =
      lines.
      inject(0) { |current, line|
        if line.instance_of?(::String)
          next current
        end

        if current < line[0].length
          current = line[0].length
        end

        current
      } +
      4

    result = []
    lines.each() { |line|
      if line.instance_of?(::String)
        result.push(line)
        next
      end

      summary = _wrap(line[1] || '', 60)
      result.push(line[0] + (' ' * (indent - line[0].length)) +
        (summary[0] || ''))

      (summary[1..-1] || []).each() { |ln| result.push(' ' * indent + ln) }

      result.push('')
    }

    return result.join("\n").rstrip()
  end

  def self._wrap(text, length)
    line = ''
    result = []

    text.split("\n").each() { |text_line|
      text_line.split(' ').each() { |word|
        if (line + word + ' ').length > length
          result.push(line.rstrip())
          line = ''
        end

        line += word + ' '
      }

      result.push(line.rstrip())
      line = ''
    }

    return result
  end

end
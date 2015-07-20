class Balmora::Command::Files < Balmora::Command

  class Error < StandardError; end

  def init()
    super()

    @files = @variables.inject(@files)
    @storage = @variables.inject(@storage)
    @exclude = @variables.inject(@exclude)
  end

  def options()
    return super().concat([:action, :options, :files, :storage, :exclude])
  end

  def verify()
    if @files.nil?() && @storage.nil?()
      raise Error.new('"files" or "storage" should be defined')
    end

    if @files.nil?() || @files.empty?()
      raise Error.new('"files" should be defined')
    end

    if !@options.nil?() && @options.has_key?(:storage) && !@storage.nil?()
      raise Error.new('"file.storage" and "storage" could not be defined ' +
        'together')
    end

    if @action.nil?()
      raise Error.new('"action" should be defined')
    end
  end

  def run()
    _files().each() { |file|
      command = _get_command(file)
      @balmora.run_command(@state, command)
    }
  end

  def _files()
    files = _find_files()
    files = _filter_files(files)
    return files
  end

  def _find_files()
    storage = @shell.expand(@storage)

    files = []
    @files.each() { |file|
      path = file
      if path.instance_of?(::Hash)
        path = path[:file]
      end

      if @action == 'pull'
        path = ::File.join(storage, path.gsub(/^(\~\/|\~$|\/)/, ''))
      else
        path = @shell.expand(path)
      end

      command = ['test', '-d', path, @shell.expression('&&'), 'find', path,
        '-type', 'f']

      dir_status, dir_files = @shell.run(command, verbose: false)
      if dir_status != 0
        files.push(file)
        next
      end

      dir_files.
        strip().
        split("\n").
        each() { |found|
          found = found[(path.length + 1)..-1]
          if file.instance_of?(::Hash)
            files.push(file.merge(file: ::File.join(file[:file], found)))
          else
            files.push(::File.join(file, found))
          end
        }
    }

    return files
  end

  def _filter_files(files)
    if !@exclude.nil?()
      exclude = Regexp.new('(' + @exclude.collect() { |part| "(#{part})" }.
        join('|') + ')')

      files = files.select() { |file|
        result =
          if file.instance_of?(::Hash)
            !file[:file].match(exclude)
          else
            !file.match(exclude)
          end

        next result
      }
    end

    return files
  end

  def _get_command(file)
    command = (@options || {}).merge(command: 'file', file: file)

    if file.instance_of?(::Hash)
      command.merge!(file)
    end

    command.merge!(action: @action, storage: @storage)

    return command
  end

end
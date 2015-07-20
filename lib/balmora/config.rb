require 'json'

class Balmora::Config

  class Error < StandardError; end

  attr_accessor :file, :dir, :require, :variables
  attr_reader :old, :config

  def self.factory(state)
    return self.create(state.options[:config], state.variables)
  end

  def self.create(config = nil, variables = nil)
    if config.nil?()
      config = File.join(Dir.home(), '.config/balmora/balmora.conf')
    end

    if !File.exist?(config)
      config = File.join('/etc/balmora/balmora.conf')
    end

    if !File.exist?(config)
      raise Error.new('Config not found in ~/.config/balmora/balmora.conf ' +
        'and /etc/balmora/balmora.conf; you should create config to ' +
        'continue or use --config switch')
    end

    return self.new(config || '~/.config/balmora/balmora.conf', variables)
  end

  def initialize(path, variables = nil)
    @file = File
    @dir = Dir

    @variables = variables
    @path = path
    @require = Object.method(:require)

    @config = nil
  end

  def get(key = [], options = {})
    if !key.instance_of?(::Array)
      key = [key]
    end

    result =
      key.
      inject(@config) { |current, part|
        begin
          current = current.fetch(part)
        rescue KeyError
          if options[:default]
            return options[:default]
          end

          raise "Config value #{key.inspect()} should be defined in " +
            "#{@path.inspect()}"
        end

        next current
      }

    result = _deep_clone(result)
    if options[:variables] != false
      result = @variables.inject(result, false)
    end

    return result
  end

  def load()
    @old = _deep_clone(@config)

    Dir.chdir(File.dirname(@path)) {
      @config = _load(@path)
    }

    @config[:config_dir] = File.dirname(@path)
    @config[:config_path] = @path

    get(:require, default: [], variables: false).each() { |file|
      @require.call(file)
    }
  end

  def _load(path)
    contents = @file.read(@file.expand_path(path))
    value = JSON.parse(contents, {symbolize_names: true})
    value = _process(value)
    return value
  rescue => error
    raise Error.new("Failed to read config file #{path}: #{error.to_s()}")
  end

  def _process(value)
    result =
      if value.instance_of?(::Array)
        _process_array(value)
      elsif value.instance_of?(::Hash)
        _process_hash(value)
      else
        value
      end

    return result
  end

  def _process_array(value)
    result = []
    value.each() { |item|
      if item.instance_of?(::Hash) && item.keys() == [:'extend-file']
        files = item[:'extend-file']
        if !files.instance_of?(::Array)
          files = [files]
        end

        files.each() { |path|
          _glob(path).each() { |file|
            result.concat(_load(file))
          }
        }
      else
        result.push(_process(item))
      end
    }

    return result
  end

  def _process_hash(value)
    result = {}
    value.each() { |key, item|
      if key == :'include-file'
        files = item
        if !files.instance_of?(::Array)
          files = [files]
        end

        files.each() { |path|
          _glob(path).each() { |file|
            result.merge!(_load(file))
          }
        }
      else
        result[key] = _process(item)
      end
    }

    return result
  end

  def _glob(file)
    if !file.include?('*')
      return [file]
    end

    return @dir.glob(file)
  end

  def _deep_clone(value)
    if value.instance_of?(::Array)
      value = value.collect() { |item|
        _deep_clone(item)
      }
    elsif value.instance_of?(::Hash)
      value = Hash[
        value.collect() { |key, item|
          [_deep_clone(key), _deep_clone(item)]
        }
      ]
    else
      is_clonable = (
        !value.is_a?(::Numeric) &&
        !value.is_a?(::TrueClass) &&
        !value.is_a?(::FalseClass) &&
        !value.is_a?(::NilClass) &&
        !value.is_a?(::Symbol)
      )

      if is_clonable
        value = value.clone()
      end
    end

    return value
  end

end
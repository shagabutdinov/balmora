class Balmora::Command

  class Error < StandardError; end

  def initialize(state, command)
    @state = state

    @logger = state.logger
    @shell = state.shell
    @config = state.config
    @contexts = state.contexts
    @variables = state.variables
    @balmora = state.balmora

    @command = command
  end

  def init()
    if (@command.keys() - [:command] - options()).length != 0
      raise Error.new("Unknown options #{(@command.keys() - [:command] -
        options()).inspect()}")
    end

    options().each() { |key|
      if self.instance_variable_defined?(:"@#{key}")
        raise Error.new("Can not use #{key} as option")
      end

      option = @command.fetch(key, nil)
      self.instance_variable_set(:"@#{key}", option)
    }

    verify()
  end

  def options()
    return [:ignore_error, :fallback, :extensions, :sudo, :context, :chdir,
      :require]
  end

  def execute()
    if @command.has_key?(:chdir)
      dir = @command[:chdir]
      dir = @variables.inject(dir)
      dir = @shell.expand(dir)
      Dir.chdir(dir) {
        _execute()
      }
    else
      _execute()
    end
  end

  def _execute()
    if @command.instance_of?(::Hash) && !@contexts.check(@command[:context])
      @logger.debug("Skip: #{@command.inspect()}")
      return
    end

    init()

    if !@require.nil?()
      option(:require).each() { |file|
        require file
      }
    end

    @logger.debug("Run: #{@command.inspect()}")

    execute = self.method(:run)

    if !@sudo.nil?()
      execute_sudo = execute
      execute = Proc.new() {
        @shell.sudo!(option(:sudo)) {
          execute_sudo.call()
        }
      }
    end

    execute.call()
  rescue => error
    @logger.error("#{error.inspect()}; failed to run " +
      "command: #{@command.inspect()}")

    if @fallback
      @logger.debug("Executing fallback for command #{@command.inspect()}")
      @balmora.execute(@fallback)
    end

    if option(:ignore_error) == true
      return
    end

    raise error
  end

  def run()
    raise Error.new("Run should be implemented in subclass")
  end

  def option(option)
    return @variables.inject(self.instance_variable_get(:"@#{option}"))
  end

end
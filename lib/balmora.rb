class Balmora

  class Error < StandardError; end
  class Restart < StandardError; end
  class Stop < StandardError

    attr_reader :status

    def initialize(message, status)
      super(message)
      @status = status
    end

  end

  def self.run(task, arguments = {}, options = {})
    state = Balmora::State.create(options, arguments)
    state.balmora.run(task, state)
  end

  # def self.create(options = {}, arguments = {})
  #   state = Balmora::State.create(options, arguments)
  #   return state.balmora
  # end

  def self.factory(state)
    return self.new(state.logger, state.extension, state)
  end

  def initialize(logger, extension, state)
    @logger = logger
    @extension = extension
    @state = state
  end

  def run(task, state)
    restarts = state.config.get([:max_restarts], default: 3)

    restarts.
      times() { |index|
      begin
        dir = state.config.get(:chdir, default: Dir.pwd)
        dir = state.variables.inject(dir)
        Dir.chdir(dir) {
          commands = state.config.get([:tasks, task.to_sym(), :commands])
          run_commands(state, commands)
        }
        return 0
      rescue Restart
        @logger.debug("Restarting task (#{restarts - index} attempts left)")
        state = Balmora::State.create(@state.options, @state.arguments)
      end
    }


    raise Error.new("Maximal restart attempts count (#{restarts}) reached")
  rescue Stop => stop
    @logger.debug("Stop with status #{stop.status} catched")
    return stop.status
  end

  def run_commands(state, commands)
    commands.
      each() { |command|
        run_command(state, command)
      }
  end

  def run_command(state, command)
    @extension.
      create_command(state, command).
      execute()
  end

end

require 'balmora/require.rb'
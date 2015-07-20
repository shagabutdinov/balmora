require 'shellwords'

class Balmora::Shell

  class Error < StandardError

    attr_reader :status

    def initialize(message, status)
      super(message)
      @status = status
    end

  end

  class Expression

    attr_reader :command

    def initialize(command)
      @command = command
    end

  end

  attr_accessor :exec, :status
  attr_reader :home, :user_id

  def self.factory(state)
    return self.new(state.logger)
  end

  def initialize(logger, home = nil)
    @logger = logger
    @run = ::Object.method(:'`')
    @system = ::Object.method(:system)
    @status = Proc.new() { $?.exitstatus }
    @home = Dir.home()
    @user_id ||= `id -un; id -gn`.strip().split("\n").join(':')
    @sudo_stack = []
  end

  def expression(command)
    Expression.new(command)
  end

  def sudo()
    if @sudo_stack.length == 0
      return []
    end

    if @sudo_stack[-1] == true
      return ['sudo']
    else
      return ['sudo', '--user', @sudo_stack[-1]]
    end
  end

  def run(command, options = {})
    command = sudo() + command

    shell_command =
      command.
      collect() { |part|
        if part.instance_of?(Expression)
          next part.command
        end

        next Shellwords.escape(part)
      }.
      join(' ')

    if options[:verbose] != false
      @logger.info(shell_command)
    else
      @logger.debug(shell_command)
    end

    method = @run
    if options[:system] == true
      method = @system
    end

    result = method.call(shell_command)
    status = @status.call()

    if options[:raise] == true && status != 0
      raise Error.new("Failed to execute command: #{shell_command}",
        status)
    end

    return status, result
  end

  def run!(command, options = {})
    return run(command, options.merge(raise: true))[1]
  end

  def system(command, options = {})
    return run(command, options.merge(raise: true, system: true))[1]
  end

  def expand(path)
    if path.start_with?('~') || path.start_with?('/')
      return ::File.expand_path(path)
    end

    return path
  end

  def sudo!(sudo)
    @sudo_stack.push(sudo)
    yield
  ensure
    @sudo_stack.pop()
  end

end
require 'balmora'
require 'balmora/arguments'
require 'optparse'

class Balmora::Cli

  class Error < StandardError; end

  attr_accessor :out, :err, :rescue

  def initialize()
    _create_options()

    @out = STDOUT
    @err = STDERR
    @rescue = true

    @arguments = Balmora::Arguments
  end

  def _create_options()
    @options = {
      config: {
        shortcut: 'c',
        description: 'Configuration file; if not specified, balmora will ' +
          'look configuration file at ~/.config/balmora/balmora.conf and ' +
          '/etc/balmora/balmora.conf in order',
      },

      quite: {
        shortcut: 'q',
        flag: true,
        description: 'Quite mode; reports only errors',
      },

      dry: {
        shortcut: 'd',
        flag: true,
        description: 'Dry run; will not run modify commands but report it to log',
      },

      verbose: {
        shortcut: 'v',
        flag: true,
        description: 'Verbose mode; reports all executed commands',
      },

      help: {
        shortcut: 'h',
        flag: true,
        description: 'Show help; if --config specified in arguments, shows ' +
          'config help; if TASK specified, shows task help',
      },
    }
  end

  def run(argv)
    args, tail = @arguments.parse(@options, argv)
    state = Balmora::State.create(args, {})
    if tail.nil?()
      if args[:help] == true
        @out.puts(help(state))
        return 1
      end

      @err.puts('No task specified; use --help to see help')
      return 1
    end

    if tail[0].start_with?('-')
      raise Error.new("Unknown option #{tail.first()}; use --help to see " +
        "options")
    end


    task_name, *task_argv = tail
    task = state.config.get([:tasks, task_name.to_sym()], default: nil,
      variables: false)

    if task.nil?()
      raise Error.new("Unknown task #{task_name.to_s().inspect()}; use " +
        "--help to see task list")
    end

    if args[:help] == true
      @out.puts(task_help(state, task_name, task))
      return 1
    end

    if task.has_key?(:arguments)
      task_args, task_args_tail = @arguments.parse(task[:arguments], task_argv)
      if !task_args_tail.nil?()
        raise Error.new("Unknown task option #{task_args_tail.first().
          inspect()}; use --help #{task_name} to see task options")
      end
    else
      task_args = {}
    end

    state.arguments.merge!(task_args)

    STDIN.reopen("/dev/tty") # make sure that input to tty will

    return state.balmora.run(task_name, state)
  rescue => error
    if !@rescue || true
      raise error
    end

    @err.puts('Error: ' + error.to_s())
    if args[:debug]
      @err.puts(error.backtrace)
    end

    return 1
  end

  def help(state)
    tasks =
      state.
      config.
      get([:tasks], variables: false, default: []).
      collect() { |key, task|
        [' ' * 4 + key.to_s(), task[:description] || '']
      }

    help =
      "Usage: balmora [common-options] task [task-options]\n\n" +
      "Options\n\n" +
      @arguments.help(@options) + "\n\n" +
      "Tasks:\n\n" +
      @arguments.format(tasks)

    return help
  end

  def task_help(statetask_name, task)
    help =
      "Usage: balmora [common-optinos] #{task_name} [task-options]\n\n" +
      "Description:\n\n" +
      (
        task[:description] &&
        @arguments.format([['   ', task[:description]]]) ||
        ((' ' * 4) + 'No description provided')
      ) + "\n\n" +
      "Arguments:\n\n" +
      (
        task[:arguments] &&
        @arguments.help(statetask[:arguments]) ||
        ((' ' * 4) + 'Task has no arguments')
      )

    return help
  end

end
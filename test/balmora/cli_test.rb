require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/cli'

class Balmora::CliTest < MiniTest::Test

  def setup()
    @balmora = stub(run: true)
    @tasks = {
      task1: {
        description: 'Test description 1',
        arguments: {
          arg1: {
            shortcut: 'a',
            description: 'First argument',
          },
          arg2: {
            shortcut: 'b',
            description: 'Second argument',
          },
        },
      },
      task2: {
        description: 'Test description 2',
        arguments: {
          arg1: {
            shortcut: 'a',
            description: 'First argument',
          },
          arg2: {
            shortcut: 'b',
            description: 'Second argument',
          },
        },
      }
    }

    @config = stub(get: @tasks)
    @object = Balmora::Cli.new(@balmora, @config)
    @object.out = stub(puts: true)
    @object.err = stub(puts: true)
    @object.rescue = false
  end

  def test_run_puts_help_to_out()
    @object.out.expects(:puts).with() { |message | message.
      start_with?('Usage: balmora ') }
    @object.run(['--help'])
  end

  def test_run_puts_help_to_out_and_returns_1()
    assert_equal(1, @object.run(['--help']))
  end

  def test_run_puts_task_list_help_to_out()
    @object.out.expects(:puts).with() { |message | message.
      include?('task1') && message.include?('task2') }
    @object.run(['--help'])
  end

  def test_run_puts_task_descriptons_help_to_out()
    @object.out.expects(:puts).with() { |message | message.
      include?('Test description 1') && message.include?('Test description 2') }
    @object.run(['--help'])
  end

  def test_run_reports_unknown_option()
    @object.rescue = true
    @object.err.expects(:puts).with('Unknown option --unknown; use --help to ' +
      'see options')
    @object.run(['--unknown'])
  end

  def test_run_reports_unknown_option_and_returns_1()
    @object.rescue = true
    assert_equal(1, @object.run(['--unknown']))
  end

  def test_run_puts_help_on_task()
    @object.out.expects(:puts).with() { |message | message.
      include?('Usage: balmora [common-optinos] task1 [task-options]') }
    @object.run(['--help', 'task1'])
  end

  def test_run_puts_help_with_description_on_task()
    @config.stubs(:get).returns(@tasks[:task1])
    @object.out.expects(:puts).with() { |message | message.
      include?('Test description 1') }
    @object.run(['--help', 'task1'])
  end

  def test_run_puts_help_with_arguments_on_task()
    @config.stubs(:get).returns(@tasks[:task1])
    @object.out.expects(:puts).with() { |message | message.include?('-a') &&
      message.include?('First argument') }
    @object.run(['--help', 'task1'])
  end

  def test_run_puts_unknown_task_on_help_for_unknown_task()
    @config.stubs(:get).returns(nil)
    @object.err.expects(:puts).with('Unknown task "unknown"; use --help to ' +
      'see task list')
    @object.rescue = true
    @object.run(['--help', 'unknown'])
  end

  def test_run_puts_no_task_specified_if_no_task()
    @object.err.expects(:puts).with('No task specified; use --help to see help')
    @object.rescue = true
    @object.run(['--config', 'file'])
  end

  def test_run_puts_no_task_specified_if_no_task_and_returns_1()
    @object.rescue = true
    assert_equal(1, @object.run(['--config', 'file']))
  end

  def test_run_puts_unknown_task()
    @config.stubs(:get).returns(nil)
    @object.err.expects(:puts).with('Unknown task "unknown"; use --help to ' +
      'see task list')
    @object.rescue = true
    @object.run(['unknown'])
  end

  def test_run_puts_unknown_task_and_returns_1()
    @config.stubs(:get).returns(nil)
    @object.rescue = true
    assert_equal(1, @object.run(['unknown']))
  end

  def test_run_puts_unknown_task_option_on_unknown_task_option()
    @config.stubs(:get).returns(@tasks[:task1])
    @object.err.expects(:puts).with('Unknown task option "--unknown"; use ' +
        '--help task to see task options')
    @object.rescue = true
    @object.run(['task', '--unknown'])
  end

  def test_run_calls_balmora()
    @config.stubs(:get).returns(@tasks[:task1])
    @balmora.expects(:run).with('task', {})
    @object.run(['task'])
  end

  def test_run_calls_balmora_with_options()
    @config.stubs(:get).returns(@tasks[:task1])
    @balmora.expects(:run).with('task', {arg1: 'value'})
    @object.run(['task', '-a', 'value'])
  end

  def test_run_calls_balmora_with_long_options()
    @config.stubs(:get).returns(@tasks[:task1])
    @balmora.expects(:run).with('task', {arg1: 'value'})
    @object.run(['task', '--arg1', 'value'])
  end

  def test_run_calls_balmora_and_returns_balmora_run_result()
    @config.stubs(:get).returns(@tasks[:task1])
    @balmora.stubs(:run).returns('RESULT')
    assert_equal('RESULT', @object.run(['task', '--arg1', 'value']))
  end

end
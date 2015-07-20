require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/command'

class BalmoraTest < MiniTest::Test

  def setup()

    @object = Balmora.factory(_create_state())
  end

  def _create_state()
    @logger = stub(debug: true)

    @config = stub()
    @config.stubs(:get).returns([{command: 'COMMAND'}])
    @config.stubs(:get).with([:max_restarts], {default: 3}).returns(5)

    @command_instance = stub(execute: true)
    # @command_class = stub(new: @command_instance)
    @extension = stub(create_command: @command_instance)

    @contexts = stub(check: true)

    @state = stub(
      config: @config,
      logger: @logger,
      extension: @extension,
      contexts: @contexts,
    )

    return @state
  end

  def test_run_runs_command()
    @command_instance.expects(:execute)
    @object.run('TASK', @state)
  end

  def test_run_asks_config_about_action()
    @config.expects(:get).with([:tasks, :TASK, :commands]).
      returns([{command: 'COMMAND'}])
    @object.run('TASK', @state)
  end

  # def test_run_passes_command_info_to_constructor()
  #   @command_class.expects(:new).with(@state, {command: 'COMMAND'}).
  #     returns(@command_instance)
  #   @object.run('TASK', @state)
  # end

  def test_run_calls_contexts()
    @contexts.expects(:check).with({command: 'COMMAND'}).returns(true)
    @object.run('TASK', @state)
  end

  def test_run_not_calls_runner_if_check_failed()
    @contexts.stubs(:check).returns(false)
    @command_instance.expects(:execute).never()
    @object.run('TASK', @state)
  end

  def test_run_calls_logger()
    @state.logger.expects(:debug).
      with() { |message| message.start_with?('Executing command: ') }
    @object.run('TASK', @state)
  end

  def test_run_returns_zero_status()
    assert_equal(0, @object.run('TASK', @state))
  end

  def test_run_returns_non_zero_status_on_stop()
    @command_instance.stubs(:execute).raises(Balmora::Stop.new(nil, 1))
    assert_equal(1, @object.run('TASK', @state))
  end

  def test_run_restarts_on_restart_raised()
    count = 0
    @state.logger.stubs(:debug).with() { |message|
      if message.start_with?('Executing command: ')
        count += 1
        @command_instance.stubs(:execute)
      end
    }

    @command_instance.stubs(:execute).raises(Balmora::Restart.new())
    @object.run('TASK', @state)
    assert_equal(count, 1)
  end

  def test_run_restarts_restarts_five_times()
    count = 0
    @state.logger.stubs(:debug).with() { |message|
      if message.start_with?('Executing command: ') then count += 1 end
    }

    @command_instance.stubs(:execute).raises(Balmora::Restart.new())
    @object.run('TASK', @state)
    raise "test failed"
  rescue Balmora::Error
    assert_equal(count, 5)
  end

  def test_run_raises_on_max_restarts_attempts()
    @command_instance.stubs(:execute).raises(Balmora::Restart.new())
    assert_raises(Balmora::Error) {
      @object.run('TASK', @state)
    }
  end

end
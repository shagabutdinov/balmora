require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/shell'

class Balmora::ShellTest < MiniTest::Test

  def setup()
    @logger = stub(debug: true, info: true)

    state = stub(logger: @logger, options: {home: '/HOME/'})
    @object = Balmora::Shell.factory(state)

    @object.run = stub(call: 'RESULT')
    @object.status = stub(call: 0)
  end

  # run

  def test_run_runs_command()
    @object.run.expects(:call).with('ls')
    @object.run(['ls'])
  end

  def test_run_returns_command_result()
    assert_equal([0, 'RESULT'], @object.run(['ls']))
  end

  def test_run_prepares_command()
    @object.run.expects(:call).with('ls -la')
    @object.run(['ls', '-la'])
  end

  def test_run_escapes_command_special_chars()
    @object.run.expects(:call).with('ls -la \~')
    @object.run(['ls', '-la', '~'])
  end

  def test_run_uses_not_escapes_expressins()
    @object.run.expects(:call).with('ls | grep TEST')
    @object.run(['ls', @object.expression('| grep TEST')])
  end

  def test_run_calls_logger()
    @logger.expects(:info).with('ls -la')
    @object.run(['ls', '-la'])
  end

  def test_run_calls_logger_with_debug()
    @logger.expects(:debug).with('ls -la')
    @object.run(['ls', '-la'], verbose: false)
  end

  def test_run_raises_on_bad_status()
    assert_raises(Balmora::Shell::Error) {
      @object.status.stubs(:call).returns(1)
      @object.run(['ls', '-la'], raise: true)
    }
  end

  def test_run_not_raises_on_good_status()
    @object.run(['ls', '-la'], raise: true)
    assert_equal(1, 1) # assertion placeholder
  end

  def test_run_exclamation_raises_on_bad_status()
    assert_raises(Balmora::Shell::Error) {
      @object.status.stubs(:call).returns(1)
      @object.run!(['ls', '-la'])
    }
  end

  # # file_exists?

  # def test_file_exists_asks_os_about_file()
  #   @object.run.expects(:call).with('test -e /HOME/FILE')
  #   @object.file_exists?('~/FILE')
  # end

  # def test_file_exists_returns_true_on_zero_status()
  #   assert_equal(true, @object.file_exists?('~/FILE'))
  # end

  # def test_file_exists_returns_false_on_non_zero_status()
  #   @object.status.stubs(:call).returns(1)
  #   assert_equal(false, @object.file_exists?('~/FILE'))
  # end

end
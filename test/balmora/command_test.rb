require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/command'

class Balmora::CommandTest < MiniTest::Test

  class Helper < Balmora::Command

    def initialize(state, command, method)
      super(state, command)
      @method = method
    end

    def run()
      @method.call()
    end

    def verify()

    end

    def options()
      return super()
    end

  end

  def setup()
    @logger = stub(debug: true, error: true)
    @balmora = stub()

    @state = stub(
      logger: @logger,
      shell: stub(),
      config: stub(),
      balmora: @balmora,
    )
  end

  def _object(command, method)
    instance = Helper.new(@state, command, method)
    instance.init()
    return instance
  end

  def test_command_ignores_exception()
    @logger.expects(:error)
    _object({ignore_failure: true}, Proc.new() { raise "error" }).execute()
  end

  def test_command_runs_fallback_on_exception()
    @balmora.expects(:execute).with('fallback')
    _object({ignore_failure: true, fallback: 'fallback'},
      Proc.new() { raise "error" }).execute()
  end

  def test_command_reraise_error_if_no_ignore_failure()
    assert_raises(RuntimeError) {
      _object({}, Proc.new() { raise "error" }).execute()
    }
  end

end
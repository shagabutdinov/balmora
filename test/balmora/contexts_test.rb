require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/contexts'
require 'balmora/condition'

class Balmora::ContextsTest < MiniTest::Test

  def setup()
    @check_instance = stub(check: true)
    @check_class = stub(new: @check_instance)
    @extensions = stub(get: @check_class)

    @state = stub(
      extensions: @extensions,
      logger: stub(debug: true)
    )

    @object = Balmora::Contexts.factory(@state)
  end

  def test_check_returns_true_if_no_checkers_found()
    assert_equal(true, @object.check({}))
  end

  def test_check_returns_true()
    assert_equal(true, @object.check({:'on-CHECK' => true}))
  end

  def test_check_returns_false()
    @check_instance.stubs(:check).returns(false)
    assert_equal(false, @object.check({:'on-CHECK' => true}))
  end

  def test_check_returns_false_on_if_is_arrray()
    @check_instance.stubs(:check).returns(false)
    assert_equal(false, @object.check({:'on' => [{if: 'CHECK'}]}))
  end

  def test_check_logs_on_check_fail()
    @check_instance.stubs(:check).returns(false)
    @state.logger.expects(:debug).
      with() { |message| message.start_with?('Check not passed: ')}
    @object.check({:'on-CHECK' => true})
  end

  def test_check_asks_extensions_about_extension()
    @extensions.expects(:get).with(Balmora::Condition, 'CHECK').
      returns(@check_class)
    @object.check({:'on-CHECK' => true})
  end

  def test_check_asks_extensions_about_extension_on_if_is_array()
    @extensions.expects(:get).with(Balmora::Condition, 'CHECK').
      returns(@check_class)
    @object.check({:'on' => [{condition: 'CHECK'}]})
  end

  def test_check_pass_state_and_info_to_new()
    @check_class.expects(:new).with(@state, {condition: 'CHECK'}).
      returns(@check_instance)
    @object.check({:'on' => [{condition: 'CHECK'}]})
  end

end
require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/variables'

class Balmora::VariablesTest < MiniTest::Test

  def setup()
    @extensions = stub(get: {test: {key: 'value'}, array: [1, 2, 3]})
    @shell = stub(run!: 'SHELL_RESULT', expression: 'EXPRESSION')
    @state = stub(extensions: @extensions, shell: @shell)
    @object = Balmora::Variables.factory(@state)
  end

  # get

  def test_get_returns_variable()
    assert_equal('value', @object.get([:ns, :test, :key]))
  end

  def test_get_returns_variable_by_string()
    assert_equal('value', @object.get('ns.test.key'))
  end

  def test_get_raise_on_unknown()
    assert_raises(Balmora::Variables::Error) {
      @object.get([:ns, :test, :UNKNOWN])
    }
  end

  # inject

  def test_inject_includes_variable()
    actual = @object.inject({:'include-variable' => 'ns.test'})
    assert_equal({key: 'value'}, actual)
  end

  def test_inject_includes_nested_variable()
    actual = @object.inject({key: {:'include-variable' => 'ns.test'}})
    assert_equal({key: {key: 'value'}}, actual)
  end

  def test_inject_extends_variable()
    actual = @object.inject([{:'extend-variable' => 'ns.array'}])
    assert_equal([1, 2, 3], actual)
  end

  def test_inject_extends_nested_variable()
    actual = @object.inject({key: [{:'extend-variable' => 'ns.array'}]})
    assert_equal({key: [1, 2, 3]}, actual)
  end

  def test_inject_extends_string()
    assert_equal('test: value', @object.inject('test: ${ns.test.key}'))
  end

  def test_inject_not_extends_escaped_string()
    actual = @object.inject('test: \${ns.test.key}')
    assert_equal('test: ${ns.test.key}', actual)
  end

  def test_inject_extends_with_eval()
    assert_equal('test: 3', @object.inject('test: #{1 + 2}'))
  end

  def test_inject_not_extends_escaped_eval()
    assert_equal('test: #{1 + 2}', @object.inject('test: \#{1 + 2}'))
  end

  def test_inject_extends_with_exec()
    assert_equal('test: SHELL_RESULT', @object.inject('test: %{echo TEST}'))
  end

  def test_inject_pass_exec_to_shell()
    @shell.expects(:run!).with('EXPRESSION', message: 'Executing embedded ' +
        'command: ', verbose: false).returns('RESULT')
    @object.inject('test: %{echo TEST}')
  end

  def test_inject_pass_exec_to_shell_expression()
    @shell.expects(:expression).with('echo TEST').returns('RESULT')
    @object.inject('test: %{echo TEST}')
  end

  def test_inject_not_extends_escaped_exec()
    assert_equal('test: %{echo TEST}', @object.inject('test: \%{echo TEST}'))
  end

end
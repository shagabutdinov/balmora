require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/arguments'

class Balmora::ArgumentsTest < MiniTest::Test

  def setup()
    @object = Balmora::Arguments
  end

  # parse

  def test_parse_parses_option()
    actual, _ = @object.parse({option: {}}, ['--option', 'value'])
    assert_equal({option: 'value'}, actual)
  end

  def test_parse_parses_two_options()
    args = ['--option1', 'value1', '--option2', 'value2']
    actual, _ = @object.parse({option1: {}, option2: {}}, args)
    assert_equal({option1: 'value1', option2: 'value2'}, actual)
  end

  def test_parse_returns_tail()
    _, actual = @object.parse({}, ['--unknown', 'value'])
    assert_equal(['--unknown', 'value'], actual)
  end

  def test_parse_returns_result_with_tail()
    args = ['--option', 'value', '--unknown', 'value']
    actual = @object.parse({option: {}}, args)
    assert_equal([{option: 'value'}, ['--unknown', 'value']], actual)
  end

  def test_parse_parses_flag()
    actual, _ = @object.parse({option: {flag: true}}, ['--option'])
    assert_equal({option: true}, actual)
  end

  def test_parse_parses_flag_with_option()
    args = ['--option1', '--option2', 'value']
    actual, _ = @object.parse({option1: {flag: true}, option2: {}}, args)
    assert_equal({option1: true, option2: 'value'}, actual)
  end

  def test_parse_parses_option_with_flag()
    args = ['--option2', 'value', '--option1']
    actual, _ = @object.parse({option1: {flag: true}, option2: {}}, args)
    assert_equal({option2: 'value', option1: true}, actual)
  end

  def test_parse_parses_flag_with_tail()
    actual = @object.parse({option: {flag: true}}, ['--option', 'tail'])
    assert_equal([{option: true}, ['tail']], actual)
  end

  def test_parse_parses_shortcut()
    actual, _ = @object.parse({option: {shortcut: 'o'}}, ['-o', 'value'])
    assert_equal({option: 'value'}, actual)
  end

  def test_parse_parses_two_shortcuts()
    options = {option1: {shortcut: '1'}, option2: {shortcut: '2'}}
    actual = @object.parse(options, ['-1', 'value1', '-2', 'value2'])
    assert_equal([{option1: 'value1', option2: 'value2'}, nil], actual)
  end

  def test_parse_parses_shortcut_with_tail()
    actual = @object.parse({option: {shortcut: 'o'}}, ['-o', 'value', 'tail'])
    assert_equal([{option: 'value'}, ['tail']], actual)
  end

  def test_parse_parses_unknown_shortcut_as_tail()
    actual = @object.parse({}, ['-o'])
    assert_equal([{}, ['-o']], actual)
  end

  def test_parse_parses_shortcut_as_flag()
    actual = @object.parse({option: {flag: true, shortcut: 'o'}}, ['-o'])
    assert_equal([{option: true}, nil], actual)
  end

  def test_parse_parses_two_shortcut_as_flag()
    opts = {o1: {flag: true, shortcut: '1'}, o2: {flag: true, shortcut: '2'}}
    actual = @object.parse(opts, ['-1', '-2'])
    assert_equal([{o1: true, o2: true}, nil], actual)
  end

  def test_parse_parses_two_compact_shortcuts_as_flag()
    opts = {o1: {flag: true, shortcut: '1'}, o2: {flag: true, shortcut: '2'}}
    actual = @object.parse(opts, ['-12'])
    assert_equal([{o1: true, o2: true}, nil], actual)
  end

  def test_parse_parses_two_compact_shortcuts_as_tail()
    opts = {o1: {shortcut: '1', flag: true}, o2: {shortcut: '2'}}
    actual = @object.parse(opts, ['-12', 'value'])
    assert_equal([{o1: true}, ['-12', 'value']], actual)
  end

  # help

  def test_help_returns_string()
    assert_equal('    -o, --option', @object.help({option: {shortcut: 'o'}}))
  end

  def test_help_returns_string_with_description()
    actual = @object.help({option: {shortcut: 'o', description: 'DESCRIPTION'}})
    assert_equal('    -o, --option    DESCRIPTION', actual)
  end

  def test_help_returns_string_for_two_options()
    expected =
      "    -1, --option1    DESCRIPTION 1\n\n" +
      "    -2, --option2    DESCRIPTION 2"
    options = {
      option1: {shortcut: '1', description: 'DESCRIPTION 1'},
      option2: {shortcut: '2', description: 'DESCRIPTION 2'},
    }

    assert_equal(expected, @object.help(options))
  end

end
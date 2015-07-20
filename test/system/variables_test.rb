require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::VariablesTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'variables_test')
    @config = File.join(@home, 'balmora.conf')
    _cleanup()
    Balmora.run('test', {}, {config: @config, verbose: true})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    files = [
      'config_dir',
      'config_path',
      'variable',
      'variable_by_key',
      'set_variable',
      'extended_variable',
      'included_variable',
      'extended',
      'included',
    ]

    files.each() { |file|
      if File.exist?(File.join(@home, file))
        File.delete(File.join(@home, file))
      end
    }
  end

  def _contents(file)
    return File.read(File.join(@home, file))
  end

  def test_variables_included()
    assert_equal(@home, _contents('config_dir'))
    assert_equal(File.join(@home, 'balmora.conf'), _contents('config_path'))
    assert_equal('VARIABLE', _contents('variable'))
    assert_equal('VARIABLE_BY_KEY', _contents('variable_by_key'))
    assert_equal('EXTENDED_VARIABLE', _contents('extended_variable'))
    assert_equal('INCLUDED_VARIABLE', _contents('included_variable'))
    assert_equal('SET_VARIABLE', _contents('set_variable'))
    assert_equal('EXTENDED_FILE', _contents('extended_file'))
    assert_equal('INCLUDED_FILE', _contents('included_file'))
  end

end
require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::ContextsTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'contexts_test')
    @config = File.join(@home, 'balmora.conf')
    _cleanup()
    FileUtils.cp(_path('balmora.conf.actual'), _path('balmora.conf'))
    Balmora.run('test', {}, {config: @config, home: @home})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    files = [
      'context_1',
      'context_2',
      'context_3',
      'context_4',
      'context_5',
      'context_6',
      'context_7',
      'context_8',
      'context_9',
      'balmora.conf',
    ]

    files.each() { |file|
      FileUtils.rm_rf(_path(file))
    }
  end

  def _contents(file)
    return File.read(_path(file))
  end

  def _path(file)
    return File.join(@home, file)
  end

  def test_command_runned_correctly()
    assert_equal('CONTEXT_1', _contents('context_1'))
    assert_equal('CONTEXT_2', _contents('context_2'))
    assert_equal(false, ::File.exist?(_path('context_3')))
    assert_equal('CONTEXT_4', _contents('context_4'))
    assert_equal(false, ::File.exist?(_path('context_5')))
    assert_equal('CONTEXT_6', _contents('context_6'))
    assert_equal(false, ::File.exist?(_path('context_7')))
    assert_equal('CONTEXT_8', _contents('context_8'))
    assert_equal(false, ::File.exist?(_path('context_9')))
  end

end
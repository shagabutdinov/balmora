require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::LinksTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'links_test')
    @config = File.join(@home, 'balmora.conf')
    _cleanup()
    Balmora.run('test', {}, {config: @config, home: @home})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    links = [
      'file_1',
      'list',
    ]

    links.each() { |file|
      FileUtils.rm_rf(File.join(@home, file))
    }
  end

  def _contents(file)
    return File.read(_path(file))
  end

  def _path(file)
    return File.join(@home, file)
  end

  def test_command_runned_correctly()
    assert_equal('FILE1', _contents('file_1'))
    assert_equal('FILE1', _contents('list/file_1'))
  end

end
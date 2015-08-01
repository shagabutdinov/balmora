require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::LinkTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'link_test')
    p @config = File.join(@home, 'balmora.conf')
    _cleanup()
    Balmora.run('test', {}, {config: @config, home: @home})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    links = [
      'pull/file_1',
      'pull/file_2',
      'pull/file_3',
      'pull/file_4',
    ]

    links.each() { |file|
      `sudo rm -rf '#{File.join(@home, file)}'`
    }
  end

  def _contents(file)
    return File.read(File.join(@home, file))
  end

  def test_file_pulled()
    assert_equal('FILE1', _contents('pull/file_1'))
    assert_equal('FILE2', _contents('pull/file_2'))
    assert_equal('FILE3', _contents('pull/file_3'))

    assert_equal('root:root', `sudo stat -c '%U:%G' '#{File.
      join(@home, 'pull/file_4')}'`.strip())
  end

end
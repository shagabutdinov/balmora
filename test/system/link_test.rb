require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::LinkTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'link_test')
    @config = _path('balmora.conf')
    _cleanup()
    File.write(_path('file_4'), 'FILE4')
    File.write(_path('file_5'), 'FILE5')
    Balmora.run('test', {}, {config: @config, home: @home})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    links = [
      'file_1',
      'file_2',
      'file_3',
      'file_4',
      'storage/file_4',
      'file_5',
    ]

    links.each() { |file|
      `sudo rm -rf '#{_path(file)}'`
    }
  end

  def _contents(file)
    return File.read(_path(file))
  end

  def _path(file)
    return File.join(@home, file)
  end

  def test_links_created()
    assert_equal('FILE1', _contents('file_1'))
    assert_equal(true, `stat #{_path('file_1')}`.include?('symbolic link'))

    assert_equal('FILE2', _contents('file_2'))
    assert_equal(true, `stat #{_path('file_2')}`.include?('symbolic link'))

    assert_equal('root', `sudo stat -c '%U' '#{_path('file_3')}'`.strip())
    assert_equal(true, `stat #{_path('file_3')}`.include?('symbolic link'))

    assert_equal('FILE4', _contents('file_4'))
    assert_equal(true, `stat #{_path('file_4')}`.include?('symbolic link'))

    assert_equal('FILE5', _contents('file_5'))
    assert_equal(true, `stat #{_path('file_5')}`.include?('symbolic link'))
  end

end
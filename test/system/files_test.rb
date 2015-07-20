require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::FilesTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'files_test')
    @config = File.join(@home, 'balmora.conf')
    _cleanup()
    Balmora.run('test', {}, {config: @config, home: @home})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    files = [
      'pull',
      'pull-list',
      'pull-secret',
      'push-storage',
    ]

    files.each() { |file|
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
    assert_equal('FILE1', _contents('pull/file_1'))
    assert_equal('FILE2', _contents('pull/file_2'))
    assert_equal(false, File.exist?(_path('pull/file_3')))

    assert_equal('FILE1', _contents('pull-list/file_1'))
    assert_equal('FILE2', _contents('pull-list/file_2'))
    assert_equal(false, File.exist?(_path('pull-list/file_3')))

    assert_equal('FILE1', _contents('pull-secret/file_1'))
    assert_equal('FILE2', _contents('pull-secret/file_2'))
    assert_equal(false, File.exist?(_path('pull-secret/file_3')))

    assert_equal('FILE1', _contents('push-storage/push/file_1'))
    assert_equal(false, 'FILE2' == _contents('push-storage/push/file_2'))
    assert_equal(false, File.exist?(_path('push-storage/push/file_3')))

    assert_equal('FILE1', _contents('push-storage/push-list/file_1'))
    assert_equal('FILE2', _contents('push-storage/push-list/file_2'))
    assert_equal(false, File.exist?(_path('push-storage/push-list/file_3')))

    assert_equal(false, 'FILE1' == _contents('push-storage/push-secret/file_1'))
    assert_equal(false, 'FILE2' == _contents('push-storage/push-secret/file_2'))
    assert_equal(false, File.exist?(_path('push-storage/push-secret/file_3')))
  end

end
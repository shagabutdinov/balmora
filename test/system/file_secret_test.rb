require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::FileSecretTest < MiniTest::Test

  def setup()
    @home = File.expand_path(File.join(File.dirname(__FILE__), 'file_secret'))
    @config = File.join(@home, 'balmora.conf')
    _cleanup()
    File.write(File.join(@home, 'pull/file_3'), 'WRONG')
    FileUtils.mkdir_p(File.join(@home, 'push/storage/push'))
    File.write(File.join(@home, 'push/storage/push/file_3'), 'FILE3')
    Balmora.run('test', {}, {config: @config})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    files = [
      'pull/file_1',
      'pull/file_2',
      'pull/file_3',
      'push/storage/file_1',
      'push/storage/push/file_2',
      'push/storage/push/file_3',
    ]

    files.each() { |file|
      FileUtils.rm_rf(File.join(@home, file))
    }
  end

  def _contents(file)
    return File.read(File.join(@home, file))
  end

  def test_file_pulled()
    assert_equal('FILE1', _contents('pull/file_1'))
    assert_equal('FILE2', _contents('pull/file_2'))
    assert_equal('FILE3', _contents('pull/file_3'))

    contents = _contents('push/storage/file_1')
    assert_equal(true, contents != '' && contents != 'FILE1')

    contents = _contents('push/storage/push/file_2')
    assert_equal(true, contents != '' && contents != 'FILE2')

    contents = _contents('push/storage/push/file_3')
    assert_equal(true, contents != '' && contents != 'FILE3')
  end

end
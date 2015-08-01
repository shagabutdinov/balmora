require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'fileutils'

class Balmora::CommandTest < MiniTest::Test

  def setup()
    @home = File.join(File.dirname(__FILE__), 'command_test')
    @config = File.join(@home, 'balmora.conf')
    _cleanup()
    Balmora.run('test', {}, {config: @config})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    files = [
      'command',
      'sudo',
      'test/chdir',
      'test/sudo',
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

  def _path(file)
    return File.join(@home, file)
  end

  def test_commands_runned()
    assert_equal('COMMAND', _contents('command'))
    assert_equal('root:root', `stat -c '%U:%G' '#{_path('sudo')}'`.strip())
    assert_equal('CHDIR', _contents('test/chdir'))
    assert_equal('root:root', `stat -c '%U:%G' '#{_path('test/sudo')}'`.strip())
  end

end
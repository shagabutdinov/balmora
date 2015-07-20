require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'

class Balmora::PacmanTest < MiniTest::Test

  def setup()
    home = File.join(File.dirname(__FILE__), 'pacman_test')
    config = File.join(home, 'balmora.conf')
    _cleanup()

    if !(`pacman -Q`.include?('srclib'))
      system('pacman -S spandsp --noconfirm')
    end

    Balmora.run('test', {}, {config: config, debug: true})
  end

  def teardown()
    _cleanup()
  end

  def _cleanup()
    if `pacman -Q`.include?('runki')
      system('sudo pacman -R runki --noconfirm')
    end

    if `pacman -Q`.include?('smpeg')
      system('sudo pacman -R smpeg --noconfirm')
    end
  end

  def test_command_runned()
    assert_equal(true, `pacman -Q | grep smpeg`.strip() != '')
    assert_equal(true, `pacman -Q | grep runki`.strip() != '')
    assert_equal(true, `pacman -Q | grep spandsp`.strip() == '')
  end

end
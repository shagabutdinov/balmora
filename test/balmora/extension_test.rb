require 'minitest/autorun'
require 'mocha/mini_test'

require 'balmora'
require 'balmora/command'
require 'balmora/extension'

class Balmora::ExtensionTest < MiniTest::Test

  module Extension; end
  class Commands; end
  class Commands::Command < Commands

    attr_reader :state, :command

    def initialize(state, command)
      @state = state
      @command = command
    end

    def init()

    end

  end


  def setup()
    @object = Balmora::Extension.new()
    @object.command_constant = Commands
    @object.extension_constant = self.class
  end

  # get

  def test_get_extension_returns_class()
    assert_equal(Balmora::Extension, @object.get(Balmora, 'extension'))
  end

  def test_get_extension_returns_class_by_dash_case()
    assert_equal(Balmora::ExtensionTest, @object.get(Balmora, 'extension-test'))
  end

  def test_get_extension_raises_if_no_extension_found()
    assert_raises(Balmora::Extension::Error) {
      @object.get(Balmora, :unknown)
    }
  end

  # create_command

  def test_create_command_creates_command()
    instance = @object.create_command('STATE', command: 'command')
    assert_equal(true, instance.instance_of?(Commands::Command))
  end

  def test_create_command_passes_state_to_command()
    instance = @object.create_command('STATE', command: 'command')
    assert_equal('STATE', instance.state)
  end

  def test_create_command_passes_command_to_command()
    instance = @object.create_command('STATE', command: 'command', info: 'INFO')
    assert_equal({command: 'command', info: 'INFO'}, instance.command)
  end

  def test_create_command_extends_object_with_extensions()
    instance = @object.create_command('STATE', command: 'command',
      extensions: ['extension'])
    assert_equal(true, instance.is_a?(Extension))
  end

end
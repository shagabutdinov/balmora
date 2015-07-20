class Balmora::Extension

  class Error < StandardError; end

  attr_accessor :command_constant, :extension_constant

  def self.factory(state)
    return self.new(state)
  end

  def initialize(state)
    @command_constant = ::Balmora::Command
    @extension_constant = ::Balmora::Extension
    @state = state
  end

  def get(namespace, extension)
    class_name =
      extension.
      to_s().
      gsub(/(-|^)(\w)/) { |char | (char[1] || char[0]).upcase() }.
      to_sym()

    if !namespace.const_defined?(class_name, false)
      raise Error.new("Extension #{class_name.inspect()} not found in " +
        "namespace " + namespace.inspect())
    end

    return namespace.const_get(class_name, false)
  end

  def create_command(state, command)
    if command.instance_of?(::String)
      command = {command: 'exec', exec: command}
    end

    if command[:command].nil?()
      raise Error.new("\"command\" should be defined in command " +
        "#{command.inspect()}")
    end

    command_name = @state.variables.inject(command[:command])
    command_class = get(@command_constant, command_name)
    if !(command_class < @command_constant)
      raise Error.new("Command should be instance of #{@command_constant}")
    end

    command_instance = command_class.new(state, command)

    (command[:extensions] || []).each() { |extension|
      extension_class = get(@extension_constant, extension)
      command_instance.extend(extension_class)
    }

    return command_instance
  end

end
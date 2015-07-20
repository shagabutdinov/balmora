class Balmora::State

  attr_reader :options, :arguments, :logger, :balmora, :extension, :config
  attr_reader :shell, :variables, :context

  @@constants = [
    Balmora::Logger,
    Balmora::Extension,
    Balmora::Shell,
    Balmora::Variables,
    Balmora::Config,
    Balmora::Contexts,
    Balmora,
  ]

  def self.create(options, arguments)
    state = Balmora::State.new()
    state.instance_variable_set(:@options, options)
    state.instance_variable_set(:@arguments, arguments)

    config = Balmora::Config.create(options[:config])
    config.load()

    state.instance_variable_set(:@config, config)

    constants = @@constants.clone()
    Balmora.constants.each() { |constant|
      if !constants.include?(constant)
        constants.push(constant)
      end
    }

    constants.delete(Balmora::Config)

    constants.each() { |constant|
      if !constant.respond_to?(:factory)
        next
      end

      name =
        constant.
        to_s().
        split('::')[1..-1].
        join('_').
        split(/(?=[A-Z])/).
        collect() { |word| word.downcase() }.
        join('_').
        to_sym()

      if name == :''
        name = :balmora
      end

      state.set(name, constant.factory(state))
    }

    config.variables = state.variables

    return state
  end

  def set(name, instance)
    if self.instance_variable_defined?(:"@#{name}")
      raise Error.new("Can not set #{name.inspect()}: variable is already set")
    end

    self.instance_variable_set(:"@#{name}", instance)
  end

  def method_missing(method, *arguments)
    if arguments.length > 1
      super(method, *arguments)
    end

    if !self.instance_variable_defined?(:"@#{method}")
      super(method, *arguments)
    end

    return self.instance_variable_get(:"@#{method}")
  end

end
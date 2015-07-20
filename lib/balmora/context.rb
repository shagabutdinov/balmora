class Balmora::Context < Balmora::Command

  def initialize(state, context)
    @state = state

    @logger = state.logger
    @shell = state.shell
    @config = state.config
    @variables = state.variables
    @balmora = state.balmora

    @context = context
  end

  def init()
    if (@context.keys() - [:context] - options()).length != 0
      raise Error.new("Unknown options #{(@context.keys() - [:context] -
        options()).inspect()}")
    end

    options().each() { |key|
      if self.instance_variable_defined?(:"@#{key}")
        raise Error.new("Can not use #{key} as option")
      end

      option = @context.fetch(key, nil)
      self.instance_variable_set(:"@#{key}", option)
    }

    verify()
  end

  def options()
    return [:operator, :value]
  end

  def verify()
    if @operator.nil?()
      raise Error.new('"operator" should be defined')
    end

    if @value.nil?()
      raise Error.new('"value" should be defined')
    end
  end

  def execute()
    result = run()

    operator = @operator

    is_not = false
    if operator.start_with?('not-')
      is_not = true
      operator = operator[4..-1]
    end

    case operator
      when 'match'
        return _not(is_not, result.match(@value) != nil)
      when 'equal'
        return _not(is_not, result == @value)
      when 'greater'
        return _not(is_not, result > @value)
      when 'greater-or-equal'
        return _not(is_not, result >= @value)
      when 'lesser'
        return _not(is_not, result < @value)
      when 'lesser-or-equal'
        return _not(is_not, result <= @value)
    end

    raise Error.new("Unknown operator #{operator}")
  rescue => error
    @logger.error("#{error.inspect()}; failed to run " +
      "context: #{@context.inspect()}")

    raise error
  end

  def _not(is_not, result)
    if is_not
      return !result
    end

    return result
  end

  def run()
    raise Error.new("run should be implemented in subclass")
  end

  def option(option)
    return @variables.inject(self.instance_variable_get(:"@#{option}"))
  end


end
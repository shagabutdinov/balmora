class Balmora::Contexts

  def self.factory(state)
    return self.new(state.logger, state.extension, state.variables, state)
  end

  def initialize(logger, extension, variables, state)
    @state = state
    @logger = logger
    @extension = extension
    @variables = variables
  end

  def check(context)
    if context.nil?()
      return true
    end

    if context.instance_of?(::Array)
      return _check_array(context)
    end

    if context.instance_of?(::String)
      context = {
        context: 'exec-result',
        exec: context,
        operator: 'equal',
        value: 0,
      }
    end


    context_class = @extension.get(Balmora::Context, context[:context])
    context_instance = context_class.new(@state, context)
    context_instance.init()

    if !(context_class < Balmora::Context)
      raise Error.new("Context #{context_class} should be subclass of context")
    end

    context_instance.verify()
    result = context_instance.execute()
    return result
  end

  def _check_array(contexts)
    operator = :and
    result = true
    contexts.each() { |context|
      if context == 'or'
        operator = :or
        next
      end

      if operator == :or
        result = result || check(context)
        operator = :and
      else
        if !result
          next
        end

        result = result && check(context)
      end
    }

    return result
  end

end

# [
#   {"context": "test -e folder/file1; echo $?", "operator": "equal", "value": "0"},
#   "or",
#   {"context": "test -e folder/file2; echo $?", "operator": "equal", "value": "0"},
# ]
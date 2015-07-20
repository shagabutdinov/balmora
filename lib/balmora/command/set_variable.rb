class Balmora::Command::SetVariable < Balmora::Command

  class Error < StandardError; end

  def init()
    super()

    @variable = option(:variable)
    @value = option(:value)
  end

  def options()
    return super().concat([:variable, :value])
  end

  def verify()
    if @variable.nil?()
      raise Error.new('"variable" should be defined')
    end

    if @value.nil?()
      raise Error.new('"value" should be defined')
    end
  end

  def run()
    parts = @variable.split('.').collect() { |part| part.to_sym() }
    @config.config[:variables] ||= {}
    parent = parts[0...-1].inject(@config.config[:variables]) { |current, variable|
      if !current.instance_of?(::Hash)
        raise Error.new("wrong variable name #{@variable}: target is not hash")
      end

      current[variable] ||= {}
      next current[variable]
    }

    parent[parts[-1]] = @value
  end

end
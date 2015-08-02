class Balmora::Context::Value < Balmora::Context

  def options()
    return super().concat([:value])
  end

  def verify()
    if !@value
      raise Error.new('"value" should be defined')
    end

    super()
  end

  def run()
    return @variables.inject(@value)
  end

end
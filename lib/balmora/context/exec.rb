class Balmora::Context::Exec < Balmora::Context

  def options()
    return super().concat([:exec])
  end

  def verify()
    if !@exec
      raise Error.new('"exec" should be defined')
    end

    super()
  end

  def run()
    return @shell.run!(_exec(), verbose: false).rstrip()
  end

  def _exec()
    exec = option(:exec)
    if exec.instance_of?(::String)
      exec = [@shell.expression(exec)]
    end
  end

end
class Balmora::Command::Exec < Balmora::Command

  class Error < StandardError; end

  def options()
    return super().concat([:exec])
  end

  def verify()
    if @exec.nil?()
      raise Error.new('"exec" should be defined')
    end
  end

  def run()
    exec = option(:exec)
    if !exec.instance_of?(::Array)
      exec = [@shell.expression(exec)]
    end

    @shell.system(exec, change: true)
  end

end
class Balmora::Context::ExecResult < Balmora::Context::Exec

  def run()
    return @shell.run(_exec(), verbose: false)[0]
  end

end
class Balmora::Command::Commands < Balmora::Command

  def options()
    return super().concat([:commands])
  end

  def verify()
    if @commands.nil?()
      raise Error.new('"commands" should be set')
    end
  end

  def run()
    @balmora.run_commands(@state, @commands)
  end

  def _installed()
    return @shell.run!(['pacman', '-Q'], verbose: false).split("\n")
  end

end
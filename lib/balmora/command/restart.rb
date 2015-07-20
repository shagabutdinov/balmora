class Balmora::Command::Restart < Balmora::Command

  class Error < StandardError; end

  def verify()
    return true
  end

  def run()
    raise Balmora::Restart.new()
  end

end
class Balmora::Command::ReloadConfig < Balmora::Command

  class Error < StandardError; end

  def verify()
    return true
  end

  def run()
    @config.load()
  end

end
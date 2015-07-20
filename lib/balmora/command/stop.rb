class Balmora::Command::Stop < Balmora::Command

  class Error < StandardError; end

  def options()
    return super().concat([:status])
  end

  def verify()
    return true
  end

  def run()
    raise Balmora::Stop.new(nil, @status)
  end

end
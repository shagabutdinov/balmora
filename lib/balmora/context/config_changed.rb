class Balmora::Context::ConfigChanged < Balmora::Context

  def run()
    if @config.old.nil?() || @config.config.nil?()
      return @config.config == @config.old
    end

    return JSON.generate(@config.config) != JSON.generate(@config.old)
  end

end
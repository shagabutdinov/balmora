require 'logger'

class Balmora::Logger < Logger

  def self.factory(state)
    logger = self.new(STDOUT)

    if state.options[:debug] == true && state.options[:quite] == true
      raise Error.new("Options --quite and --verbose can not be set " +
        "simulataneously")
    end


    if state.options[:verbose] == true
      logger.level = ::Logger::DEBUG
    elsif state.options[:quiet] != true
      logger.level = ::Logger::INFO
    else
      logger.level = ::Logger::ERROR
    end

    return logger
  end

end
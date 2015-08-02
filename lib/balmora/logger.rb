require 'logger'
require 'term/ansicolor'

class Balmora::Logger < Logger

  def self.factory(state)
    logger = self.new(STDOUT)

    logger.formatter = proc { |severity, _, _, msg|
      if severity == 'DEBUG'
        puts(Term::ANSIColor.blue() { msg })
      elsif severity == 'INFO'
        puts(Term::ANSIColor.green() { msg })
      elsif severity == 'ERROR'
        puts(Term::ANSIColor.red() { msg })
      end
    }

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
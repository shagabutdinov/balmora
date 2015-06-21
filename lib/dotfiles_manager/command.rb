class DotfilesManager::Command

  attr_accessor :entry
  attr_accessor :command

  def initialize(manager)
    @manager = manager
  end

  def pull(options)
    _run(options)
  end

  def push(options)
    _run(options)
  end

  def _run(options)
    if options[:verbose] == true
      puts(@command)
    end

    if system(@command) != 0
      raise DotfilesManager::RunError.new("Failed to execute command " +
        " #{@command}")
    end
  end

end
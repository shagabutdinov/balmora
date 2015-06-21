class DotfilesManager::RubyScript

  attr_accessor :entry
  attr_accessor :script

  def initialize(manager)
    @manager = manager
  end

  def pull(options)
    eval(@script)
  end

  def push(options)
    eval(@script)
  end

end
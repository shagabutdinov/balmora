class DotfilesManager::PackagePacman

  attr_accessor :entry
  attr_accessor :packages

  def initialize(manager)
    @manager = manager
  end

  def pull(options)
    _install()
  end

  def push(options)
    _install()
  end

  def _install()
    @manager.run('sudo', 'pacman', '--noconfirm', '-Sy', '--needed', *@packages)
  end

end
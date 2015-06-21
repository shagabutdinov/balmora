class DotfilesManager::PackagePacmanKey

  attr_accessor :entry
  attr_accessor :keys

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
    @keys.each() { |key|
      begin
        @manager.run('sudo', 'pacman-key', '-f', key)
      rescue DotfilesManager::RunError
        @manager.run('sudo', 'pacman-key', '-r', key)
        @manager.run('sudo', 'pacman-key', '--lsign-key', key)
      end
    }
  end

end
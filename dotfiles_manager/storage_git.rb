
class DotfilesManager::StorageGit

  attr_accessor :entry
  attr_accessor :name

  def initialize(manager)
    @manager = manager
  end

  def _get_target_path()
    storage = @storage || @manager.config.get(:default_storage)
    target = File.join(DotfilesManager::PATH, storage)
    path = @path

    if path.start_with?('/')
      target = File.join(target, '.root')
    elsif path.start_with?('~/')
      path = path[2..-1]
    else
      raise "File path must start with \"/\" or \"~/\" for entry #{entry}"
    end

    target = File.join(target, path)
  end

  def pull(options)
    Dir.chdir(File.join(DotfilesManager::PATH, @name)) {
      @manager.run('git', 'pull')
    }
  end

  def push(options)
    Dir.chdir(File.join(DotfilesManager::PATH, @name)) {
      message =
        DotfilesManager::Utility.
        get_console_option(options, ['m', 'message']) ||
        (raise "Message (flag \"--message\" or \"-m\") should be specified " +
          "in arguments for storage-git.push")
      @manager.run('git', 'add', '.')
      @manager.run('git', 'commit', '-m', message)
      @manager.run('git', 'push')
    }
  end

end
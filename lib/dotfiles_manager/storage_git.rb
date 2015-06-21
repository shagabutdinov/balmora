
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

  def _get_storage_path()
    return File.join(DotfilesManager::PATH, @name)
  end

  def pull(options)
    path = _get_storage_path()
    if File.exists(File.join(path, '.git'))
      Dir.chdir(path) {
        @manager.run('git', 'pull')
      }
    else
      url = @manager.config.get([:storages, @name.to_sym(), :url])
      @manager.run('git', 'clone', url, path)
    end
  end

  def push(options)
    path = File.join(DotfilesManager::PATH, @name)

    Dir.chdir(path) {
      if !File.exists?(path)
        @manager.run('git', 'init')
      end

      message =
        DotfilesManager::Utility.
        get_console_option(options, ['m', 'message']) ||
        (raise "Message (flag \"--message\" or \"-m\") should be specified " +
          "in command line arguments for entry #{@entry}")

      @manager.run('git', 'add', '.')
      if @manager.run('git', 'status', '--short').strip() != ''
        @manager.run('git', 'commit', '-m', message)
      end

      @manager.run('git', 'push')
    }
  end

end
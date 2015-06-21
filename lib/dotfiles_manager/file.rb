require 'shellwords'

class DotfilesManager::File

  attr_accessor :entry
  attr_accessor :path, :storage

  def initialize(manager)
    @manager = manager
  end

  def _get_storage_path()
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
    _replace_file(_get_storage_path(), File.expand_path(@path))
  end

  def push(options)
    _replace_file(File.expand_path(@path), _get_storage_path())
  end

  def _md5sum(file)
    escaped = Shellwords.escape(file)
    if `#{_sudo(file)} stat -c "%F" #{escaped}`.strip() == 'regular file'
      result = `#{_sudo(file)} md5sum #{escaped}`;
    else
      result = `\
        #{_sudo(file)} find #{escaped} -type f -exec md5sum {} \; | \
        sort -k 34 | \
        md5sum \
      `
    end

    if $? != 0
      raise "Failed to get md5 sum of file #{file}"
    end

    result = result.strip().split(' ')[0]
    return result
  end

  def _sudo(file)
    sudo = ''
    if file.start_with?('/')
      sudo = 'sudo'
    end

    return sudo
  end

  def _replace_file(source, target)
    if _md5sum(source) == _md5sum(target)
      return
    end

    @manager.run('mkdir', '-p', File.dirname(target))

    sudo = []
    if target.start_with?('/')
      sudo.push('sudo')
    end

    if File.exist?(source) && File.exist?(target)
      @manager.run(*sudo, 'rm', '-rf', target)
    end

    @manager.run(*sudo, 'cp', '-R', source, target)
  end

end
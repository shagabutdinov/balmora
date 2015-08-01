class Balmora::Command::File < Balmora::Command

  class Error < StandardError; end

  def self.resolve_path(shell, source, storage, path)
    if !source.nil?()
      return shell.expand(source)
    end

    storage = shell.expand(storage)

    if path.start_with?('~/')
      result = ::File.join(storage, path[1..-1])
    elsif path.start_with?('/')
      result = ::File.join(storage, path[1..-1])
    else
      result = ::File.join(storage, path)
    end

    return result
  end

  def init()
    super()

    @action = @variables.inject(@action)
    @file = @variables.inject(@file)
    @source = @variables.inject(@source)
    @storage = @variables.inject(@storage)
  end

  def options()
    return super().concat([:file, :source, :storage, :action, :always,
      :options])
  end

  def run()
    if  @always == true || _source_equals_to_target?()
      return nil
    end

    _create_target_path()
    _copy_file()
  end

  def verify()
    if @file.nil?()
      raise Error.new('"file" should be defined')
    end

    if !@storage.nil?() && !@source.nil?()
      raise Error.new('"storage" and "source" could not be defined together')
    end

    if @storage.nil?() && @source.nil?()
      raise Error.new('"storage" or "source" should be defined')
    end

    if @action.nil?()
      raise Error.new('"action" should be set')
    end

    if !['pull', 'push'].include?(@action)
      Error.new("Unknown action #{@action.inspect()}")
    end
  end

  protected

  def _create_target_path()
    check = ['test', '-e', ::File.dirname(_target_path())]
    if @shell.run(check, verbose: false)[0] == 0
      return
    end

    mkdir = ['mkdir', '-p', ::File.dirname(_target_path())]
    @shell.run!(mkdir, change: true)
  end

  def _copy_file()
    @shell.run!(['cp', option(:options) || '-T', _source_path(),
      _target_path()], change: true)
  end

  def _source_equals_to_target?()
    command = [
      'test', '-e', _source_path(), _expr('&&'),
      *@shell.sudo(), 'test', '-e', _target_path(), _expr('&&'),
      _expr('[ "$('), *@shell.sudo(), *_source_contents(), _expr('| md5sum'),
        _expr(')" = '),
      _expr('"$('), *@shell.sudo(), *_target_contents(), _expr('| md5sum)" ]'),
    ]

    return @shell.run(command, verbose: false)[0] == 0
  end

  def _source_contents()
    return ['cat', _source_path()]
  end

  def _target_contents()
    return ['cat', _target_path()]
  end

  def _source_path()
    return _files()[0]
  end

  def _target_path()
    return _files()[1]
  end

  def _expr(expression)
    return @shell.expression(expression)
  end

  private

  def _files()
    if @action == 'pull'
      return _resolve_source_path(), @shell.expand(@file)
    else
      return @shell.expand(@file), _resolve_source_path()
    end
  end

  def _resolve_source_path()
    return File.resolve_path(@shell, @source, @storage, @file)
  end

end
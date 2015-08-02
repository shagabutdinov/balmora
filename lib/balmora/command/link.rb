class Balmora::Command::Link < Balmora::Command

  class Error < StandardError; end

  def init()
    super()

    @link = @variables.inject(@link)
    @source = @variables.inject(@source)
    @storage = @variables.inject(@storage)
  end

  def options()
    return super().concat([:link, :source, :storage])
  end

  def run()
    if _exists?(_target())
      if _link_exists?()
        return
      end

      if !_exists?(_source())
        @shell.run!(['mkdir', '-p', ::File.dirname(_source())], change: true)
        @shell.run!(['mv', _target(), _source()], change: true)
      elsif _equals?(_source(), _target())
        @shell.run!(['rm', '-rf', _target()], change: true)
      end
    end

    _create_target_path()
    @shell.run!(['ln', @options || '-s', _source(), _target()], change: true)
  end

  def _exists?(file)
    status, _ = @shell.run(['test', '-e', file], verbose: false)
    return status == 0
  end

  def _link_exists?(d = false)
    stat_status, stat_result = @shell.run(['stat', _target()],
      verbose: false)

    if stat_status != 0
      return false
    end

    if d
      p([_target, stat_status, stat_result])
    end

    if !stat_result.include?(_source())
      return false
    end

    return true
  end

  def verify()
    if @link.nil?()
      raise Error.new('"link" should be defined')
    end

    if !@storage.nil?() && !@source.nil?()
      raise Error.new('"storage" and "source" could not be defined together')
    end

    if @storage.nil?() && @source.nil?()
      raise Error.new('"storage" or "source" should be defined')
    end
  end

  def _equals?(file1, file2)
    command = [
      'test', '-e', file1, _expr('&&'),
      *@shell.sudo(), 'test', '-e', file2, _expr('&&'),
      _expr('[ "$('), *@shell.sudo(), 'cat', file1, _expr('| md5sum'),
        _expr(')" = '),
      _expr('"$('), *@shell.sudo(), 'cat', file2, _expr('| md5sum)" ]')
    ]

    return @shell.run(command, verbose: false)[0] == 0
  end

  protected

  def _expr(string)
    return @shell.expression(string)
  end

  def _create_target_path()
    @shell.run!(
      ['mkdir', '-p', ::File.dirname(@shell.expand(@link))],
      verbose: false
    )
  end

  def _source()
    return Balmora::Command::File.resolve_path(@shell, @source, @storage, @link)
  end

  def _target()
    return @shell.expand(@link)
  end

end
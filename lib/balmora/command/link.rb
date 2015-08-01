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
    if _link_exists?()
      return
    end

    _create_target_path()
    _create_link()
  end

  def _link_exists?()
    stat_status, stat_result = @shell.run(['stat', @shell.expand(@link)],
      verbose: false)

    if stat_status != 0
      return false
    end

    link = @shell.expand(Regexp.escape(@link))
    path = Regexp.escape(_source_path())
    if !stat_result.match(/‘#{link}’ -> ‘#{path}’/)
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

  protected

  def _create_target_path()
    @shell.run!(
      ['mkdir', '-p', ::File.dirname(@shell.expand(@link))],
      verbose: false
    )
  end

  def _create_link()
    return @shell.run(['ln', @options || '-s', _source_path(), @link])
  end

  def _source_path()
    return Balmora::Command::File.resolve_path(@shell, @source, @storage, @link)
  end
end
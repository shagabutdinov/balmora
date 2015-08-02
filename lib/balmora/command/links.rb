class Balmora::Command::Links < Balmora::Command

  class Error < StandardError; end

  def init()
    super()

    @links = @variables.inject(@links)
    @storage = @variables.inject(@storage)
  end

  def options()
    return super().concat([:links, :storage])
  end

  def verify()
    if @links.nil?()
      raise Error.new('"links" should be defined')
    end

    if @storage.nil?()
      raise Error.new('"storage" should be defined')
    end
  end

  def run()
    @links.each() { |link|
      command = _get_command(link)
      @balmora.run_command(@state, command)
    }
  end

  def _get_command(link)
    command = (@options || {}).merge(command: 'link', link: link)

    if link.instance_of?(::Hash)
      command.merge!(link)
    end

    command.merge!(storage: @storage)

    return command
  end

end
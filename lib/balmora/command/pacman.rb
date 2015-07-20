class Balmora::Command::Pacman < Balmora::Command

  def initialize(state, command)
    super(state, command)
    @bin = ['sudo', 'pacman']
  end

  def init()
    super()
    @action = @variables.inject(@action)
    @packages = @variables.inject(@packages)
    @synchronize = @variables.inject(@synchronize)
  end

  def options()
    return super().concat([:action, :packages, :synchronize])
  end

  def verify()
    if @action.nil?()
      raise Error.new('"action" should be set')
    end

    if !['install', 'update', 'remove'].include?(@action)
      raise Error.new('wrong "action" value; allowed values: install, ' +
        'update, remove')
    end

    if @packages.nil?() || @packages.empty?()
      raise Error.new('"packages" should be set')
    end
  end

  def run()
    command = '-S'

    if @synchronize != false
      command += 'y'
    end

    if @action == 'install'
      packages = @packages - _installed()
    elsif @action == 'update'
      packages = @packages
    elsif @action == 'remove'
      packages = @packages & _installed()
      command = '-R'
    else
      raise Error.new("Wrong action #{@action.inspect()}")
    end

    if packages.length == 0
      return
    end

    @shell.system([*@bin, command, *packages, '--noconfirm'])
  end

  def _installed()
    packages =
      @shell.
      run!(['pacman', '-Q'], verbose: false).
      split("\n").
      collect() { |package|
        package.split(' ')[0]
      }

    return packages
  end

end
module Balmora::Extension::FileSecret

  def options()
    return super() + [:password]
  end

  def _copy_file()
    if @action == 'pull'
      @shell.run!(_source_contents() + [_expr('|'), *@shell.sudo(), 'tee',
        _target_path()])
    else
      @shell.run!(['cat', _source_path(), _expr('|'), *_encrypt(), _expr('|'),
        *@shell.sudo(), 'tee', _target_path()])
    end
  end

  def _source_contents()
    command = super()

    if @action == 'pull'
      command += [_expr('|')] + _decrypt()
    end

    return command
  end

  def _target_contents()
    command = super()

    if @action == 'push'
      command += [_expr('|')] + _decrypt()
    end

    return command
  end

  def _decrypt()
    return ['openssl', 'enc', '-aes-256-cbc', '-d', '-pass', option(:password)]
  end

  def _encrypt()
    return ['openssl', 'enc', '-aes-256-cbc', '-e', '-pass', option(:password)]
  end

end
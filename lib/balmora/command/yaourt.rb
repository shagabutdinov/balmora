require 'balmora/command/pacman'

class Balmora::Command::Yaourt < Balmora::Command::Pacman

  def initialize(state, command)
    super(state, command)
    @bin = ['yaourt']
  end

end
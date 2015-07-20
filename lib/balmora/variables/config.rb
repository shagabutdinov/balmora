class Balmora::Variables::Config

  def self.factory(state)
    return state.config.get([], variables: false)
  end

end
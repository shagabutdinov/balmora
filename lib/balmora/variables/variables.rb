class Balmora::Variables::Variables

  def self.factory(state)
    return state.config.get([:variables], variables: false)
  end

end
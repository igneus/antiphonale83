module Antiphonal
  module Helpers
    extend self

    def roman(int)
      [nil, 'I', 'II', 'III', 'IV'][int]
    end
  end
end

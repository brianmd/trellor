require 'virtus'

module Trellor

  class Base
    include Virtus.model

    attribute :id, String
    attribute :name, String
    # children is an ordered colleciton
    attribute :children, Array[Base]
  end

  class Board < Base
  end

  class List < Base
  end

  class Card < Base
    attribute :description, String
  end

end


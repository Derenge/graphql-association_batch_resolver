# frozen_string_literal: true

class Game < ActiveRecord::Base
  has_and_belongs_to_many :players
end

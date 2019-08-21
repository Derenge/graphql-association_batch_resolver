# frozen_string_literal: true

class Player < ActiveRecord::Base
  belongs_to :team
  has_one :rank

  has_and_belongs_to_many :games
end

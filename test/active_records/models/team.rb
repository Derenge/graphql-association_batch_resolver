# frozen_string_literal: true

class Team < ActiveRecord::Base
  has_many :players
  has_many :ranks, through: :players
end

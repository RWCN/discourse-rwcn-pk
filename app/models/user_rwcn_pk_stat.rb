# frozen_string_literal: true
class UserRwcnPkStat < ActiveRecord::Base
  self.primary_key = :user_id
  belongs_to :user

  validates :level,
            :exp,
            :skill_point,
            :health,
            :attack,
            :defense,
            :speed,
            :miss,
            :crit,
            presence: true

  validates :level,
            :exp,
            :skill_point,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
            }

  validates :health,
            :attack,
            :defense,
            :speed,
            :miss,
            :crit,
            numericality: {
              greater_than_or_equal_to: 0,
            }
end

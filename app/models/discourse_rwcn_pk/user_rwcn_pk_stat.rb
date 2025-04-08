# frozen_string_literal: true
module ::DiscourseRwcnPk
  class UserRwcnPkStat < ActiveRecord::Base
    self.table_name = "user_rwcn_pk_stats"
    self.primary_key = :user_id
  
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
  
    validates :defense, numericality: { greater_than_or_equal_to: 0 }
  
    validates :attack, :speed, :miss, :health, :crit, numericality: { greater_than: 0 }
  
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

    def self.create_stat!(user_id)
      DiscourseRwcnPk::UserRwcnPkStat.create!(
        user_id: user_id,
        level: 1,
        exp: 0,
        skill_point: 0,
        health: 100,
        attack: 10,
        defense: 0,
        speed: 10,
        miss: 5,
        crit: 5,
      )
    end
  
    def username
      User.find(self.user_id).username
    end
  
    def display_name
      User.find(self.user_id).display_name
    end
  end
end
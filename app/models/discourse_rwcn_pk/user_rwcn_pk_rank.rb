# frozen_string_literal: true

module ::DiscourseRwcnPk
  class UserRwcnPkRank < ActiveRecord::Base
    self.table_name = "user_rwcn_pk_ranks"
    self.primary_key = :user_id
  
    validates :rank_, :win, presence: true
  
    validates :rank_, :win, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    def self.create_rank!(user_id)
      next_rank = (DiscourseRwcnPk::UserRwcnPkRank.maximum(:rank_) || 0) + 1
      DiscourseRwcnPk::UserRwcnPkRank.create!(
        user_id: user_id, 
        rank_: next_rank, 
        win: 0, 
        day_try: 10, 
        last_battle_date: Date.current
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

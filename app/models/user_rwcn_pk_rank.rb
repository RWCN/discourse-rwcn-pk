# frozen_string_literal: true
class UserRwcnPkRank < ActiveRecord::Base
  self.primary_key = :user_id
  belongs_to :user

  validates :rank_, :win, presence: true

  validates :rank_, :win, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

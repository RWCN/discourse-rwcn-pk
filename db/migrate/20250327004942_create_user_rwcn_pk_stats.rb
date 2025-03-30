# frozen_string_literal: true
class CreateUserRwcnPkStats < ActiveRecord::Migration[7.2]
  def change
    create_table :user_rwcn_pk_stats, id: false, primary_key: :user_id do |t|
      t.integer :user_id, null: false
      t.integer :level, null: false
      t.integer :exp, null: false
      t.integer :skill_point, null: false
      t.float :health, null: false
      t.float :attack, null: false
      t.float :defense, null: false
      t.float :speed, null: false
      t.float :miss, null: false
      t.float :crit, null: false

      t.timestamps
    end
  end
end

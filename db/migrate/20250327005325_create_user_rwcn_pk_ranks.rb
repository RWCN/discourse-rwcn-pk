# frozen_string_literal: true
class CreateUserRwcnPkRanks < ActiveRecord::Migration[7.2]
  def change
    create_table :user_rwcn_pk_ranks, id: false, primary_key: :user_id do |t|
      t.integer :user_id, null: false
      t.integer :rank_, null: false
      t.integer :win, null: false
      t.integer :day_try, null: false
      t.date :last_battle_date, null: false

      t.timestamps
    end
  end
end

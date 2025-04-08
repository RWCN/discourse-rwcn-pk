# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseRwcnPk::UserRwcnPkRank, type: :model do
  fab!(:user)
  let!(:user_1) { Fabricate(:user) }
  
  it "can create rank for single" do
    expect { DiscourseRwcnPk::UserRwcnPkRank.create_rank!(user.id) }.not_to raise_error
  end

  it "can create rank for users" do
    expect { DiscourseRwcnPk::UserRwcnPkRank.create_rank!(user.id) }.not_to raise_error
    expect { DiscourseRwcnPk::UserRwcnPkRank.create_rank!(user_1.id) }.not_to raise_error
    
    expect(DiscourseRwcnPk::UserRwcnPkRank.find(user.id).rank_).to eq(1)
    expect(DiscourseRwcnPk::UserRwcnPkRank.find(user_1.id).rank_).to eq(2)
  end

  context "with default rank" do
    before do
      DiscourseRwcnPk::UserRwcnPkRank.create_rank!(user.id)
    end
  
    it "can get username" do
      rank = DiscourseRwcnPk::UserRwcnPkRank.find(user.id)
      expect(rank.username).to eq(user.username)
    end
  end
end

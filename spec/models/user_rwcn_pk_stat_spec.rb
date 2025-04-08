# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseRwcnPk::UserRwcnPkStat, type: :model do
  fab!(:user)

  it "can create stat" do
    expect { DiscourseRwcnPk::UserRwcnPkStat.create_stat!(user.id) }.not_to raise_error
  end

  context "with default stat" do
    before do
      DiscourseRwcnPk::UserRwcnPkStat.create_stat!(user.id)
    end

    it "can get username" do
      stats = DiscourseRwcnPk::UserRwcnPkStat.find(user.id)
      expect(stats.username).to eq(user.username)
    end
  end

end

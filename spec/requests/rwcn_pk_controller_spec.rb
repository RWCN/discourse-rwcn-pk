# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseRwcnPk::RwcnPkController do
  fab!(:admin)
  fab!(:user)
  let!(:user_1) { Fabricate(:user) }

  before do
    SiteSetting.discourse_rwcn_pk_enabled = true
  end

  context "as user" do
    before do
      sign_in(user)
    end

    it "can create" do
      post "/rwcn-pk/create.json"
      expect(response).to have_http_status(:no_content)
    end
  end

  context "as users" do
    before do
      DiscourseRwcnPk::UserRwcnPkRank.create_rank!(user.id)
      DiscourseRwcnPk::UserRwcnPkStat.create_stat!(user.id)
      DiscourseRwcnPk::UserRwcnPkRank.create_rank!(user_1.id)
      DiscourseRwcnPk::UserRwcnPkStat.create_stat!(user_1.id)

      sign_in(user)
    end

    context "with lower rank" do
      before do
        DiscourseRwcnPk::UserRwcnPkRank.find(user.id).update!(rank_: 2)
        DiscourseRwcnPk::UserRwcnPkRank.find(user_1.id).update!(rank_: 1)
      end

      it "can pk" do
        post "/rwcn-pk/challenge.json", params: { username: user_1.username  }
        expect(response).to have_http_status :ok
      end
    end

    context "with higher rank" do
      before do
        DiscourseRwcnPk::UserRwcnPkRank.find(user.id).update!(rank_: 1)
        DiscourseRwcnPk::UserRwcnPkRank.find(user_1.id).update!(rank_: 2)
      end

      it "cannot pk with lower rank" do
        post "/rwcn-pk/challenge.json", params: { username: user_1.username  }
        expect(response).to have_http_status :bad_request
      end
    end
  end
end

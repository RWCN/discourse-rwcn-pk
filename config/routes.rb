# frozen_string_literal: true

DiscourseRwcnPk::Engine.routes.draw do
  get "/" => "rwcn_pk#index"
  get "rank.json" => "rwcn_pk#rank"
  get "current_rank.json" => "rwcn_pk#current_rank"
  get "current_stat.json" => "rwcn_pk#current_stat"

  post "create.json" => "rwcn_pk#create"
  post "challenge.json" => "rwcn_pk#challenge"
  post "alloc_sp.json" => "rwcn_pk#alloc_sp"

  scope "admin" do
    post "change" => "rwcn_pk#admin_change", :constraints => AdminConstraint.new
    post "clear_all" => "rwcn_pk#admin_clear_all", :constraints => AdminConstraint.new
    post "reset_all_skillpoint/v1" => "rwcn_pk#admin_reset_all_skillpoint_v1", :constraints => AdminConstraint.new
  end
end

Discourse::Application.routes.draw do
  mount ::DiscourseRwcnPk::Engine, at: "rwcn-pk"

  get "/admin/plugins/rwcn-pk" => "admin/plugins#index", :constraints => AdminConstraint.new
end

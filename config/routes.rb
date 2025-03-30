# frozen_string_literal: true

DiscourseRwcnPk::Engine.routes.draw do
  get "/" => "rwcn_pk#index"
  get "rank.json" => "rwcn_pk#rank"
  get "current_rank.json" => "rwcn_pk#current_rank"
  get "current_stat.json" => "rwcn_pk#current_stat"

  post "create.json" => "rwcn_pk#create"
  post "challenge.json" => "rwcn_pk#challenge"
  post "alloc_sp.json" => "rwcn_pk#alloc_sp"

  post "admin/change" => "rwcn_pk#admin_change", :constraints => StaffConstraint.new
end

Discourse::Application.routes.draw do
  mount ::DiscourseRwcnPk::Engine, at: "rwcn-pk"

  get "/admin/plugins/rwcn-pk" => "admin/plugins#index", :constraints => StaffConstraint.new
end

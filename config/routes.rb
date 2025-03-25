# frozen_string_literal: true

DiscourseRwcnPk::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DiscourseRwcnPk::Engine, at: "discourse-rwcn-pk" }

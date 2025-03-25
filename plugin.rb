# frozen_string_literal: true

# name: discourse-rwcn-pk
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_rwcn_pk_enabled

module ::DiscourseRwcnPk
  PLUGIN_NAME = "discourse-rwcn-pk"
end

require_relative "lib/discourse_rwcn_pk/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end

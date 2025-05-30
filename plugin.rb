# frozen_string_literal: true

# name: discourse-rwcn-pk
# about: TODO
# meta_topic_id: TODO
# version: 0.2.4
# authors: zerodegress <zerodegress@outlook.com>
# url: https://github.com/RWCN/discourse-rwcn-pk
# required_version: 2.7.0

enabled_site_setting :discourse_rwcn_pk_enabled

register_asset "stylesheets/discourse-rwcn-pk.scss"

add_admin_route "rwcn_pk.title", "rwcn-pk"

module ::DiscourseRwcnPk
  PLUGIN_NAME = "discourse-rwcn-pk"
end

require_relative "lib/discourse_rwcn_pk/engine"
require_relative "lib/discourse_rwcn_pk/battle"
require_relative "lib/discourse_rwcn_pk/player"

after_initialize do
  # Code which should run after Rails has finished booting
end

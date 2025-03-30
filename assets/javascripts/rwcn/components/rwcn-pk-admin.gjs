import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export class RwcnPkAdmin extends Component {
  @tracked userId;
  @tracked rank;

  constructor() {
    super(...arguments);
  }

  @action
  updateUserId(userId) {
    this.userId = userId;
  }

  @action
  updateRank(rank) {
    this.rank = rank;
  }

  @action
  async submit() {
    await ajax("/rwcn-pk/admin/change", {
      type: "POST",
      data: {
        user_id: this.userId,
        rank: this.rank,
      },
    });
  }

  @action
  async clearAllData() {
    await ajax("/rwcn-pk/admin/clear_all", {
      type: "POST",
    });
  }

  <template>
    <div class="rwcn-rank-admin">
      <!-- 头部操作栏 -->
      <div class="admin-header">
        <h1 class="admin-title">{{i18n "rwcn_pk.admin.data_manage"}}</h1>
        <DButton
          @class="danger-btn"
          @action={{this.clearAllData}}
          @label="rwcn_pk.admin.clear_all_data"
        />
      </div>

      <!-- 主内容区 -->
      <div class="admin-content">
        <p>{{i18n "rwcn_pk.admin.other_manage"}}</p>
      </div>
    </div>
  </template>
}

export default RwcnPkAdmin;

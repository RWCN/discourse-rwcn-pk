import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import TextField from "discourse/components/text-field";
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

  <template>
    <div class="rwcn-rank-admin">
      <div>{{i18n "rwcn_pk.admin.user_id"}}</div>
      <TextField
        @type="number"
        @value={{this.userId}}
        @placeholderKey="rwcn_pk.admin.user_id_placeholder"
        @onChange={{this.updateUserId}}
      />
      <div>{{i18n "rwcn_pk.admin.rank"}}</div>
      <TextField
        @type="number"
        @value={{this.rank}}
        @placeholderKey="rwcn_pk.admin.rank_placeholder"
        @onChange={{this.updateRank}}
      />
      <div><DButton
          @action={{this.submit}}
          @label="rwcn_pk.admin.submit"
          @icon="eye"
          @id="rwcn-pk-admin-submit"
        /></div>

    </div>
  </template>
}

export default RwcnPkAdmin;

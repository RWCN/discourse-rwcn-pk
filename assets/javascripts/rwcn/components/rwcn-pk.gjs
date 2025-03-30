import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/avatar";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

export class RwcnPk extends Component {
  @tracked loading = false;
  @tracked currentRank = undefined;
  @tracked currentStat = undefined;
  @tracked
  skillsToAlloc = {
    attack: 0,
    health: 0,
    defense: 0,
    speed: 0,
  };
  @tracked challengableRank = [];
  @tracked top10Rank = [];
  @tracked rank = [];
  @tracked battle = undefined;
  @tracked playingBattle = false;
  @tracked battleLogProgress = 0;
  @tracked healths = [];

  previewSkill = (skill) => this.currentStat[skill] + this.skillsToAlloc[skill];

  translateLog = (log) => {
    switch (log.type) {
      case "info":
        return i18n(`rwcn_pk.battle.info.${log.info}`);
      case "attack": {
        const [fromName, toName] =
          this.battle.guest.username === log.from
            ? [this.battle.guest.name, this.battle.master.name]
            : [this.battle.master.name, this.battle.guest.name];
        if (log.crit) {
          return htmlSafe(
            i18n("rwcn_pk.battle.crit", {
              from_name: fromName,
              to_name: toName,
              damage: log.damage,
            })
          );
        } else if (log.miss) {
          return htmlSafe(
            i18n("rwcn_pk.battle.miss", {
              from_name: fromName,
              to_name: toName,
            })
          );
        } else {
          return htmlSafe(
            i18n("rwcn_pk.battle.attack", {
              from_name: fromName,
              to_name: toName,
              damage: log.damage,
            })
          );
        }
      }
    }
  };

  slicedLog = () =>
    this.battle.log.slice(0, this.battleLogProgress + 1).reverse();

  currentHealthStyles = () => [
    htmlSafe(
      `width:${
        (this.healths[0][this.battleLogProgress] / this.battle.guest.health) *
        100
      }%;`
    ),
    htmlSafe(
      `width:${
        (this.healths[1][this.battleLogProgress] / this.battle.master.health) *
        100
      }%;`
    ),
  ];

  currentGuestHealthStyle = () => this.currentHealthStyles()[0];
  currentMasterHealthStyle = () => this.currentHealthStyles()[1];

  constructor() {
    super(...arguments);
    this.#fetchRank();
  }

  get noSkillPointAvailable() {
    return this.currentStat.skill_point - this.allocedSkillPoint <= 0;
  }

  get noAllocedSkillPoint() {
    return this.allocedSkillPoint <= 0;
  }

  get availableSkillPoint() {
    return this.currentStat.skill_point - this.allocedSkillPoint;
  }

  get currentExpBarProgressStyle() {
    return htmlSafe(`width:${(this.currentStat.exp / 20) * 100}%`);
  }

  get notPlayingBattle() {
    return !this.playingBattle;
  }

  get battleWin() {
    return this.battle.result === "win";
  }

  get battleLose() {
    return this.battle.result === "lose";
  }

  get battleDraw() {
    return this.battle.result === "draw";
  }

  get allocedSkillPoint() {
    return (
      this.skillsToAlloc.attack +
      this.skillsToAlloc.health +
      this.skillsToAlloc.defense +
      this.skillsToAlloc.speed
    );
  }

  #computeHealths() {
    const battle = this.battle;
    const ctx = battle.log;
    const [guestHealth, masterHealth] = ctx.reduce(
      (acc, cur) => {
        switch (cur.type) {
          case "attack": {
            const damage = cur.damage || 0;
            switch (cur.to) {
              case battle.guest.username:
                return {
                  result: [
                    [...acc.result[0], acc.last[0] - damage],
                    [...acc.result[1], acc.last[1]],
                  ],
                  last: [acc.last[0] - damage, acc.last[1]],
                };
              case battle.master.username:
                return {
                  result: [
                    [...acc.result[0], acc.last[0]],
                    [...acc.result[1], acc.last[1] - damage],
                  ],
                  last: [acc.last[0], acc.last[1] - damage],
                };
              default:
                return {
                  result: [
                    [...acc.result[0], acc.last[0]],
                    [...acc.result[1], acc.last[1]],
                  ],
                  last: acc.last,
                };
            }
          }
          default:
            return {
              result: [
                [...acc.result[0], acc.last[0]],
                [...acc.result[1], acc.last[1]],
              ],
              last: acc.last,
            };
        }
      },
      {
        result: [[], []],
        last: [battle.guest.health, battle.master.health],
      }
    ).result;
    return [guestHealth, masterHealth];
  }

  @bind
  async #fetchRank() {
    this.loading = true;
    await ajax("/rwcn-pk/create.json", { type: "POST" });
    this.currentRank = await ajax("/rwcn-pk/current_rank.json");
    this.currentStat = await ajax("/rwcn-pk/current_stat.json");
    this.challengableRank = (
      await ajax(
        `/rwcn-pk/rank.json?start=${this.currentRank.rank - 5}&end=${
          this.currentRank.rank
        }`
      )
    )["rank"];
    this.top10Rank = (await ajax("/rwcn-pk/rank.json?start=1&end=10"))["rank"];
    this.rank = this.top10Rank.concat(this.challengableRank).reduce(
      (acc, obj) => {
        const key = obj.username;
        if (!acc.seen.has(key)) {
          acc.seen.add(key);
          acc.result.push(obj);
        }
        return acc;
      },
      { seen: new Set(), result: [] }
    ).result;
    this.loading = false;
  }

  canChallenge(currentRank, username, rank) {
    return (
      currentRank.username !== username &&
      currentRank.rank > rank &&
      Math.abs(currentRank.rank - rank) <= 5
    );
  }

  @action
  async challenge(username) {
    const result = await ajax("/rwcn-pk/challenge.json", {
      type: "POST",
      data: { username },
    });
    this.battleLogProgress = 0;
    this.battle = result;
    this.healths = this.#computeHealths();
    setTimeout(() => {
      const battleArea = document.getElementById("rwcn-pk-battle-area");
      battleArea.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    }, 200);
    const intervalId = setInterval(() => {
      if (this.battleLogProgress >= this.battle.log.length) {
        clearInterval(intervalId);
        this.playingBattle = false;
        this.#fetchRank().then(() => {
          setTimeout(() => {
            const skillPanel = document.getElementById("rwcn-pk-skill-panel");
            skillPanel.scrollIntoView({
              behavior: "smooth",
              block: "start",
            });
          }, 200);
        });
      }
      this.battleLogProgress += 1;
    }, 1000);
    this.playingBattle = true;
  }

  @action
  reallocSkillPoint(skill) {
    this.skillsToAlloc = {
      ...this.skillsToAlloc,
      [skill]: this.skillsToAlloc[skill] - 1,
    };
  }

  @action
  allocSkillPoint(skill) {
    this.skillsToAlloc = {
      ...this.skillsToAlloc,
      [skill]: this.skillsToAlloc[skill] + 1,
    };
  }

  @action
  async confirmSkillPoint() {
    await ajax("/rwcn-pk/alloc_sp.json", {
      type: "POST",
      data: this.skillsToAlloc,
    });
    await this.#fetchRank();
    this.skillsToAlloc = {
      attack: 0,
      health: 0,
      defense: 0,
      speed: 0,
    };
  }

  <template>
    <div class="rwcn-pk">
      {{#if this.battle}}
        {{#if this.notPlayingBattle}}
          {{#if this.battleWin}}
            <h2 class="battle-win-title">胜利！</h2>
          {{/if}}
          {{#if this.battleLose}}
            <h2 class="battle-lose-title">失败</h2>
          {{/if}}
          {{#if this.battleDraw}}
            <h2 class="battle-draw-title">平局</h2>
          {{/if}}
        {{/if}}
        <!-- 战斗区域 -->
        <div id="rwcn-pk-battle-area" class="battle-area">
          <div class="fighter">
            <div class="avatar">
              {{avatar this.battle.guest imageSize="medium"}}
            </div>
            <div class="username">
              <div class="level">Lv.{{this.battle.guest.level}}</div>
              <div class="name">{{this.battle.guest.name}}</div>
            </div>
            <div class="health-bar">
              <div
                class="health-value"
                style={{(this.currentGuestHealthStyle)}}
              ></div>
            </div>
          </div>

          <div class="fighter">
            <div class="avatar">
              {{avatar this.battle.master imageSize="medium"}}
            </div>
            <div class="username">
              <div class="level">Lv.{{this.battle.master.level}}</div>
              <div class="name">{{this.battle.master.name}}</div>

            </div>
            <div class="health-bar">
              <div
                class="health-value"
                style={{(this.currentMasterHealthStyle)}}
              ></div>
            </div>
          </div>
          <div class="battle-log">
            {{#each (this.slicedLog) as |_log|}}
              <div class="log-entry">{{(this.translateLog _log)}}</div>
            {{/each}}
          </div>
        </div>
      {{/if}}

      <!-- 排行榜 -->
      <ConditionalLoadingSpinner @condition={{this.loading}}>
        <div class="player-status">
          <div class="level-box">
            <div class="level-badge">Lv.{{this.currentStat.level}}</div>
            <div class="exp-bar">
              <div
                class="exp-progress"
                style={{this.currentExpBarProgressStyle}}
              ></div>
              <div class="exp-text">{{this.currentStat.exp}}/20</div>
            </div>
          </div>
          <div class="player-name">{{this.currentRank.name}}</div>
        </div>

        <div id="rwcn-pk-skill-panel" class="skill-panel">
          <div class="skill-header">
            <h2>{{i18n "rwcn_pk.skill_point_allocation"}}</h2>
            <div class="skill-points">{{i18n
                "rwcn_pk.remained_skill_point"
              }}<span>{{this.availableSkillPoint}}</span></div>
          </div>

          <div class="skill-item">
            <div class="skill-icon"></div>
            <div class="skill-info">
              <div class="skill-name">{{i18n "rwcn_pk.skill.health_buff"}}</div>
              <div class="skill-desc">{{i18n
                  "rwcn_pk.skill.health_buff_desc"
                }}</div>
            </div>
            <div class="skill-controls">
              <DButton
                @class="skill-button"
                @icon="minus"
                @disabled={{this.noAllocedSkillPoint}}
                @action={{fn this.reallocSkillPoint "health"}}
              />
              <div class="skill-level">{{(this.previewSkill "health")}}</div>
              <DButton
                @class="skill-button"
                @icon="plus"
                @disabled={{this.noSkillPointAvailable}}
                @action={{fn this.allocSkillPoint "health"}}
              />
            </div>
          </div>

          <div class="skill-item">
            <div class="skill-icon"></div>
            <div class="skill-info">
              <div class="skill-name">{{i18n
                  "rwcn_pk.skill.defense_buff"
                }}</div>
              <div class="skill-desc">{{i18n
                  "rwcn_pk.skill.defense_buff_desc"
                }}</div>
            </div>
            <div class="skill-controls">
              <DButton
                @class="skill-button"
                @icon="minus"
                @disabled={{this.noAllocedSkillPoint}}
                @action={{fn this.reallocSkillPoint "defense"}}
              />
              <div class="skill-level">{{(this.previewSkill "defense")}}</div>
              <DButton
                @class="skill-button"
                @icon="plus"
                @disabled={{this.noSkillPointAvailable}}
                @action={{fn this.allocSkillPoint "defense"}}
              />
            </div>
          </div>

          <div class="skill-item">
            <div class="skill-icon"></div>
            <div class="skill-info">
              <div class="skill-name">{{i18n "rwcn_pk.skill.attack_buff"}}</div>
              <div class="skill-desc">{{i18n
                  "rwcn_pk.skill.attack_buff_desc"
                }}</div>
            </div>
            <div class="skill-controls">
              <DButton
                @class="skill-button"
                @icon="minus"
                @disabled={{this.noAllocedSkillPoint}}
                @action={{fn this.reallocSkillPoint "attack"}}
              />
              <div class="skill-level">{{(this.previewSkill "attack")}}</div>
              <DButton
                @class="skill-button"
                @icon="plus"
                @disabled={{this.noSkillPointAvailable}}
                @action={{fn this.allocSkillPoint "attack"}}
              />
            </div>
          </div>

          <div class="skill-item">
            <div class="skill-icon"></div>
            <div class="skill-info">
              <div class="skill-name">{{i18n "rwcn_pk.skill.speed_buff"}}</div>
              <div class="skill-desc">{{i18n
                  "rwcn_pk.skill.speed_buff_desc"
                }}</div>
            </div>
            <div class="skill-controls">
              <DButton
                @class="skill-button"
                @icon="minus"
                @disabled={{this.noAllocedSkillPoint}}
                @action={{fn this.reallocSkillPoint "speed"}}
              />
              <div class="skill-level">{{(this.previewSkill "speed")}}</div>
              <DButton
                @class="skill-button"
                @icon="plus"
                @disabled={{this.noSkillPointAvailable}}
                @action={{fn this.allocSkillPoint "speed"}}
              />
            </div>
          </div>
          <DButton
            @label="rwcn_pk.alloc_skill_confirm"
            @action={{this.confirmSkillPoint}}
          />
        </div>
        <div class="rankings">
          <h2>{{i18n "rwcn_pk.rank_top10"}}</h2>
          {{#if this.rank}}
            <table class="rank-table">
              <thead>
                <tr>
                  <th>{{i18n "rwcn_pk.rank_pos"}}</th>
                  <th>{{i18n "rwcn_pk.player_name"}}</th>
                  <th>{{i18n "rwcn_pk.win_count"}}</th>
                  <th>{{i18n "rwcn_pk.challenge"}}</th>
                </tr>
              </thead>
              <tbody>
                {{#each this.rank as |userRank|}}
                  <tr>
                    <td>{{userRank.rank}}</td>
                    <td>
                      {{avatar userRank imageSize="tiny"}}
                      <span class="level">Lv.{{userRank.level}}</span>
                      {{userRank.name}}
                    </td>
                    <td>{{userRank.win}}</td>
                    <td>
                      {{#if
                        (this.canChallenge
                          this.currentRank userRank.username userRank.rank
                        )
                      }}
                        <DButton
                          @label="rwcn_pk.challenge"
                          @action={{fn this.challenge userRank.username}}
                        />
                      {{/if}}
                    </td>
                  </tr>
                {{/each}}
              </tbody>
            </table>
          {{else}}
            {{i18n "rwcn_pk.empty_rank"}}
          {{/if}}
        </div>
      </ConditionalLoadingSpinner>
    </div>
  </template>
}

export default RwcnPk;

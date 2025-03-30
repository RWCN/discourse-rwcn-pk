# frozen_string_literal: true

module ::DiscourseRwcnPk
  class RwcnPkController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      render json: {}
    end

    def create
      current_user_id = current_user.id

      if !UserRwcnPkRank.exists?(current_user_id)
        UserRwcnPkRank.create(
          user_id: current_user_id,
          rank_: (UserRwcnPkRank.maximum(:rank_) || 0) + 1,
          win: 0,
          day_try: 10,
          last_battle_date: Date.current,
        )
      end

      if UserRwcnPkRank.find(current_user_id).last_battle_date != Date.current
        UserRwcnPkRank.find(current_user_id).update!(day_try: 10, last_battle_date: Date.current)
      end

      if !UserRwcnPkStat.exists?(current_user_id)
        UserRwcnPkStat.create(
          user_id: current_user_id,
          level: 1,
          exp: 0,
          skill_point: 0,
          health: 100,
          attack: 10,
          defense: 0,
          speed: 10,
          miss: 5,
          crit: 5,
        )
      end

      render json: {}
    end

    def rank
      params = rank_params
      start = params.fetch(:start, 1).to_i
      end_ = params.fetch(:end, 100).to_i
      rank =
        UserRwcnPkRank
          .select(:user_id, :rank_, :win)
          .where(rank_: start..end_)
          .order(:rank_)
          .limit(100)
      render json: {
               rank:
                 rank.map do |r|
                   user = User.find(r.user_id)
                   {
                     username: user.username,
                     name: user.display_name,
                     avatar_template: user.avatar_template_url,
                     rank: r.rank_,
                     win: r.win,
                     level: UserRwcnPkStat.find(r.user_id).level,
                   }
                 end,
             }
    end

    def current_rank
      current_user_id = current_user.id
      current_username = current_user.username
      current_user_q = UserRwcnPkRank.find(current_user_id)
      current_user_rank = current_user_q.rank_
      current_user_stat = UserRwcnPkStat.find(current_user_id)

      render json: {
               rank: current_user_rank,
               username: current_username,
               name: current_user.display_name,
               avatar_template: current_user.avatar_template,
               win: current_user_q.win,
               day_try: current_user_q.day_try,
               level: current_user_stat.level,
               exp: current_user_stat.exp,
             }
    end

    def current_stat
      current_user_id = current_user.id
      current_username = current_user.username
      user_stat = UserRwcnPkStat.find(current_user_id)

      render json: {
               username: current_username,
               level: user_stat.level,
               exp: user_stat.exp,
               skill_point: user_stat.skill_point,
               attack: user_stat.attack,
               health: user_stat.health,
               defense: user_stat.defense,
               speed: user_stat.speed,
               miss: user_stat.miss,
               crit: user_stat.crit,
             }
    end

    def alloc_sp
      params = alloc_sp_params
      user_stat = UserRwcnPkStat.find(current_user.id)
      health = params[:health].to_i
      defense = params[:defense].to_i
      attack = params[:attack].to_i
      speed = params[:speed].to_i

      render status: :bad_request if health < 0 || defense < 0 || attack < 0 || speed < 0
      render status: :bad_request if !(health > 0 || defense > 0 || attack > 0 || speed > 0)

      if user_stat.skill_point < health + defense + attack + speed
        render head: :bad_request
      else
        user_stat.update!(
          health: user_stat.health + health,
          defense: user_stat.defense + defense,
          attack: user_stat.attack + attack,
          speed: user_stat.speed + speed,
          skill_point: user_stat.skill_point - (health + defense + attack + speed),
        )
        render json: {}
      end
    end

    def available_challenge_targets
      current_user_id = current_user.id
      current_user_rank = UserRwcnPkRank.select(:rank_).find(current_user_id).rank_
      available =
        UserRwcnPkRank
          .where.not(user_id: current_user_id)
          .where(rank_: current_user_rank..(current_user_rank - 5))
          .pluck(:user_id)
          .map { |user_id| User.find(user_id).username }

      render json: { targets: available }
    end

    def challenge
      current_user_id = current_user.id
      current_user_rank = UserRwcnPkRank.find(current_user_id)
      return render status: :bad_request, json: { err: "try" } if current_user_rank.day_try <= 0
      target_username = challenge_params[:username]
      target_user_id = User.find_by(username: target_username).id
      target_user_rank = UserRwcnPkRank.find(target_user_id)
      if (current_user_rank.rank_ - target_user_rank.rank_) <= 0
        return render status: :bad_request, json: { err: "rank" }
      end
      current_user_rank.update!(day_try: current_user_rank.day_try - 1)
      render json: pk(target_user_id, current_user_id)
    end

    def admin_change
      params = admin_change_params
      user_id = params[:user_id].to_i
      rank = params[:rank].to_i

      UserRwcnPkRank.find(user_id).update(rank_: rank)

      render json: {}
    end

    def admin_clear_all
      UserRwcnPkRank.update_all(win: 0, day_try: 10, last_battle_date: Date.current)

      UserRwcnPkStat.update_all(
        level: 1,
        exp: 0,
        skill_point: 0,
        health: 100,
        attack: 10,
        defense: 0,
        speed: 10,
        miss: 5,
        crit: 5,
      )
    end

    private

    def rank_params
      params.permit(:start, :end)
    end

    def alloc_sp_params
      params.permit(:health, :defense, :attack, :speed)
    end

    def admin_change_params
      params.permit(:user_id, :rank)
    end

    def challenge_params
      params.permit(:username)
    end

    def pk(master_user_id, guest_user_id)
      master_username = User.find(master_user_id).username
      guest_username = User.find(guest_user_id).username

      rng = Random.new

      last_rank = UserRwcnPkRank.maximum(:rank_) || 1
      last_rank += 1 if last_rank != 1

      guest_rank = UserRwcnPkRank.find(guest_user_id)
      guest_rank_rank = guest_rank.rank_

      master_rank = UserRwcnPkRank.find(master_user_id)
      master_rank_rank = master_rank.rank_

      master = UserRwcnPkStat.find(master_user_id)
      guest = UserRwcnPkStat.find(guest_user_id)

      battle_log = []

      master_health = master.health
      guest_health = guest.health

      cycle = 0

      battle_log.push type: "info", info: "battle_start"

      until master_health <= 0 || guest_health <= 0 || cycle >= 500
        # guest first
        # miss
        if rng.rand(100) < master.miss
          battle_log.push type: "attack", miss: true, from: guest_username, to: master_username
        else
          # crit
          if rng.rand(100) < guest.crit
            damage = guest.attack * 2 - master.defense
            damage = 1 if damage <= 0
            master_health -= damage
            battle_log.push type: "attack",
                            crit: true,
                            damage: damage,
                            from: guest_username,
                            to: master_username
            # normal
          else
            damage = guest.attack * 1 - master.defense
            damage = 1 if damage <= 0
            master_health -= damage
            battle_log.push type: "attack",
                            damage: damage,
                            from: guest_username,
                            to: master_username
          end
        end

        break if master_health <= 0 || guest_health <= 0

        # then master
        # miss
        if rng.rand(100) < guest.miss
          battle_log.push type: "attack", miss: true, from: master_username, to: guest_username
        else
          # crit
          if rng.rand(100) < master.crit
            damage = master.attack * 2 - guest.defense
            damage = 1 if damage <= 0
            guest_health -= damage
            battle_log.push type: "attack",
                            crit: true,
                            damage: damage,
                            from: master_username,
                            to: guest_username
            # normal
          else
            damage = master.attack * 1 - guest.defense
            damage = 1 if damage <= 0
            guest_health -= damage
            battle_log.push type: "attack",
                            damage: damage,
                            from: master_username,
                            to: guest_username
          end
        end

        cycle += 1
      end

      if master_health <= 0
        result = "win"
      elsif guest_health <= 0
        result = "lose"
      else
        result = "draw"
      end

      case result
      when "win"
        temp_rank = guest_rank_rank
        guest_rank.update!(win: guest_rank.win + 1, rank_: master_rank_rank)
        master_rank.update!(rank_: temp_rank)
      end
      exp = guest.exp + 5
      if exp >= 20
        guest.update!(level: guest.level + 1, exp: exp - 20, skill_point: guest.skill_point + 5)
      else
        guest.update!(exp: exp)
      end

      battle_log.push type: "info", info: "battle_end"

      master_user = User.find(master_user_id)
      guest_user = User.find(guest_user_id)
      {
        result: result,
        log: battle_log,
        master: {
          username: master_user.username,
          name: master_user.display_name,
          avatar_template: master_user.avatar_template,
          health: master.health,
          level: master.level,
        },
        guest: {
          username: guest_user.username,
          name: guest_user.display_name,
          avatar_template: guest_user.avatar_template,
          health: guest.health,
          level: guest.level,
        },
      }
    end
  end
end

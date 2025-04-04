# frozen_string_literal: true
module ::DiscourseRwcnPk
  class Player
    attr_reader :name, :max_health, :health, :attack, :defense, :speed, :crit, :miss
    attr_writer :health

    def initialize(name, stats)
      @name = name
      @max_health = stats[:health]
      @health = stats[:health]
      @attack = stats[:attack]
      @defense = stats[:defense]
      @speed = stats[:speed]
      @crit = stats[:crit]
      @miss = stats[:miss]
    end

    def dead?
      @health <= 0
    end

    def battle(player, rng)
      if !rng
        rng = Random.new
      end
      logs = []
      if player.speed <= 0 || (@speed > 0 && rng.rand(@speed) > rng.rand(player.speed))
        logs.concat battle_l(player, rng)
        if player.dead? || dead?
          return logs
        end
        logs.concat battle_r(player, rng)
      else
        logs.concat battle_r(player, rng)
        if player.dead? || dead?
          return logs
        end
        logs.concat battle_l(player, rng)
      end
      logs
    end

    private

    def battle_l(player, rng)
      logs = []
      if rng.rand(100) < player.miss
        logs.push type: "attack", miss: true, from: @name, to: player.name
      else
        damage = @attack
        crit = false
        if rng.rand(100) < @crit
          damage *= 2
          crit = true
        end
        damage -= player.defense
        player.health -= damage
        if crit
          logs.push type: "attack", crit: true, damage: damage, from: @name, to: player.name
        else
          logs.push type: "attack", damage: damage, from: @name, to: player.name
        end
      end
      logs
    end

    def battle_r(player, rng)
      logs = []
      if rng.rand(100) < @miss
        logs.push type: "attack", miss: true, from: player.name, to: @name
      else
        damage = player.attack
        crit = false
        if rng.rand(100) < player.crit
          damage *= 2
          crit = true
        end
        damage -= @defense
        @health -= damage
        if crit
          logs.push type: "attack", crit: true, damage: damage, from: player.name, to: @name
        else
          logs.push type: "attack", damage: damage, from: player.name, to: @name
        end
      end
      logs
    end
  end
end
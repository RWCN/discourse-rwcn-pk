# frozen_string_literal: true
module ::DiscourseRwcnPk
  class Player
    attr_reader :name, :max_health, :attack, :defense, :speed, :crit, :miss
    attr_accessor :health, :defense_weaken

    def initialize(name, stats)
      @name = name
      @max_health = stats[:health]
      @health = stats[:health]
      @attack = stats[:attack]
      @defense = stats[:defense]
      @defense_weaken = 0
      @speed = stats[:speed]
      @crit = stats[:crit]
      @miss = stats[:miss]
    end

    def dead?
      @health <= 0
    end

    def battle(player, **opts)
      rng = opts[:rng]
      if !rng
        rng = Random.new
      end
      logs = []
      if player.speed <= 0 || (@speed > 0 && rng.rand(@speed) > rng.rand(player.speed))
        logs.concat self.do_attack(player, rng: rng)
        if player.dead? || dead?
          return logs
        end
        logs.concat player.do_attack(self, rng: rng)
      else
        logs.concat player.do_attack(self, rng: rng)
        if player.dead? || dead?
          return logs
        end
        logs.concat self.do_attack(player, rng: rng)
      end
      logs
    end

    def do_attack(player, **opts)
      logs = []
      rng = opts[:rng]
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
        damage = 1 if damage <= 0
        player.health -= damage
        if crit
          logs.push type: "attack", crit: true, damage: damage, from: @name, to: player.name
        else
          logs.push type: "attack", damage: damage, from: @name, to: player.name
        end
      end
      logs
    end
  end
end
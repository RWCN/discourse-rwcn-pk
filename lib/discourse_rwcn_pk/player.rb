# frozen_string_literal: true
module ::DiscourseRwcnPk
  class Player
    attr_reader :name, :max_health, :attack, :max_defense, :speed, :crit, :miss
    attr_accessor :health, :defense

    def initialize(name, stats)
      @name = name
      @max_health = stats[:health]
      @health = stats[:health]
      @attack = stats[:attack]
      @defense = stats[:defense]
      @max_defense = stats[:defense]
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

      dice = rng.rand(100)

      if dice < player.miss
        logs.push type: "attack", miss: true, from: @name, to: player.name
      else
        damage = @attack
        crit = false
        if dice < @crit
          damage *= 2
          crit = true
        end
        damage -= player.defense
        damage = 1 if damage <= 0
        can_defense_weaken = damage < 5
        player.health -= damage
        msg = { type: "attack", damage: damage, from: @name, to: player.name }
        if crit
          msg[:crit] = true
          if can_defense_weaken
            player.defense -= 20 * player.defense / 100 
            player.defense = @attack - 5 if (@attack - player.defense) <= 5
          end
        else
          if can_defense_weaken
            player.defense -= 10 * player.defense / 100 
            player.defense = @attack - 5 if (@attack - player.defense) <= 5
          end
        end
        logs.push msg
      end
      logs
    end
  end
end
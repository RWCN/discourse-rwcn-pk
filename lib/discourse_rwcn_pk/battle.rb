# frozen_string_literal: true
module ::DiscourseRwcnPk
  class Battle
    attr_reader :round
    
    def initialize(guest, master)
      @round = 0
      @master = master
      @guest = guest
    end

    def pk
      logs = []
      rng = Random.new
      until @guest.dead? || @master.dead? || @round > 500
        logs.concat @guest.battle(@master, rng)
        @round += 1
      end
      if @master.dead?
        result = "win"
      elsif @guest.dead?
        result = "lose"
      else
        result = "draw"
      end
      {
        result: result,
        log: logs,
      }
    end
  end
end
# frozen_string_literal: true

describe DiscourseRwcnPk::Player do
  describe "#battle" do
    context "with no crit and miss" do
      before do
        @guest = described_class.new "guest", health: 100, attack: 10, defense: 0, crit: 0, speed: 10, miss: 0
        @master = described_class.new "master", health: 100, attack: 10, defense: 0, crit: 0, speed: 0, miss: 0
      end
      it "do damages" do
        rng = Random.new
        logs = @guest.battle @master, rng: rng
        expect(logs).to eq([
          {type: "attack", damage: 10, from: "guest", to: "master"},
          {type: "attack", damage: 10, from: "master", to: "guest"},
        ])
      end
    end

    context "with crit but without miss" do
      before do
        @guest = described_class.new "guest", health: 100, attack: 10, defense: 0, crit: 100, speed: 10, miss: 0
        @master = described_class.new "master", health: 100, attack: 10, defense: 400, crit: 5, speed: 0, miss: 0
      end
      
      it "weaken defense" do
        rng = Random.new
        @guest.battle @master, rng: rng
        expect(@master.defense).not_to eq(400)
      end
    end
  end
end
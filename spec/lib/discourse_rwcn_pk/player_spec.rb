# frozen_string_literal: true

describe DiscourseRwcnPk::Player do
  describe "#battle" do
    context "with no crit and miss" do
      it "do damages" do
        guest = described_class.new "guest", health: 100, attack: 10, defense: 0, crit: 0, speed: 10, miss: 0
        master = described_class.new "master", health: 100, attack: 10, defense: 0, crit: 0, speed: 0, miss: 0
        rng = Random.new
        logs = guest.battle master, rng: rng
        expect(logs).to eq([
          {type: "attack", damage: 10, from: "guest", to: "master"},
          {type: "attack", damage: 10, from: "master", to: "guest"},
        ])
      end
    end
  end
end
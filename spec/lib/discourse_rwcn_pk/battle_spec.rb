# frozen_string_literal: true

describe DiscourseRwcnPk::Battle do
  describe "#pk" do
    context "with no crit and miss" do
      it "do damages" do
        guest = DiscourseRwcnPk::Player.new "guest", health: 50, attack: 10, defense: 0, crit: 0, speed: 10, miss: 0
        master = DiscourseRwcnPk::Player.new "master", health: 125, attack: 10, defense: 0, crit: 0, speed: 0, miss: 0
        battle = described_class.new guest, master
        res = battle.pk
        expect(res[:result]).to eq("lose")
        expect(battle.round).to eq(5)
      end
    end
  end
end
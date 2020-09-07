module BCDice
  module DiceTable
    # D66を振って出目を昇順/降順にして表を参照する
    class D66Table
      # @param [String] name 表の名前
      # @param [Symbol] sort_type 出目入れ替えの方式 BCDice::D66SortType
      # @param [Hash] items 表の項目 Key は数値
      def initialize(name, sort_type, items)
        @name = name
        @sort_type = sort_type
        @items = items.freeze
      end

      # 表を振る
      # @param randomizer [#roll_barabara] ランダマイザ
      # @return [String] 結果
      def roll(randomizer)
        dice = randomizer.roll_barabara(2, 6)

        case @sort_type
        when D66SortType::ASC
          dice.sort!
        when D66SortType::DESC
          dice.sort!.reverse!
        end

        key = dice[0] * 10 + dice[1]
        chosen = @items[key]
        chosen = chosen.roll(randomizer) if chosen.respond_to?(:roll)
        return RollResult.new(@name, key, chosen)
      end
    end
  end
end

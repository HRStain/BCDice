# frozen_string_literal: true

module BCDice
  module GameSystem
    class Avandner < Base
      # ゲームシステムの識別子
      ID = 'Avandner'

      # ゲームシステム名
      NAME = '黒絢のアヴァンドナー'

      # ゲームシステム名の読みがな
      SORT_KEY = 'こつけんのあうあんとなあ'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~MESSAGETEXT
        ・調査判定：nAVm[Cx]
        ・命中判定：nAVm*p[+t][Cx]
        []内は省略可能。

        クリティカルヒットの分だけ、自動で振り足し処理を行います。0
        「n」でダイス数を指定。
        「m」で目標値を指定。省略は出来ません。
        「Cx」でクリティカル値を指定。省略時は「1」、最大値は「2」、「0」でクリティカル無し。
        「p」で攻撃力を指定。「*」は「x」でも可。
        「+t」でクリティカルトリガーを指定。省略可能です。
        攻撃力指定で命中判定となり、成功数ではなく、ダメージを結果表示します。

        【書式例】
        ・5AV3 → 5d10で目標値3。
        ・6AV2C0 → 6d10で目標値2。クリティカル無し。
        ・4AV3*5 → 4d10で目標値3、攻撃力5の命中判定。
        ・7AV2x10 → 7d10で目標値2、攻撃力10の命中判定。
        ・8av4*7+10 → 8d10で目標値4、攻撃力7、クリティカルトリガー10の命中判定。
      MESSAGETEXT

      register_prefix('\d+AV')

      def initialize(command)
        super(command)
        @sort_add_dice = true # ダイスのソート有
      end

      def eval_game_system_specific_command(command)
        # AVコマンド：調査判定, 成功判定
        if command =~ /(\d+)AV(\d+)((x|\*)(\d+))?(\+(\d+))?(C(\d+))?$/i
          diceCount = Regexp.last_match(1).to_i
          target = Regexp.last_match(2).to_i
          damage = (Regexp.last_match(5) || 0).to_i
          criticalTrigger = (Regexp.last_match(7) || 0).to_i
          criticalNumber = (Regexp.last_match(9) || 1).to_i.clamp(0, 2)
          return checkRoll(diceCount, target, damage, criticalTrigger, criticalNumber)
        end

        return nil
      end

      def checkRoll(diceCount, target, damage, criticalTrigger, criticalNumber)
        totalSuccessCount = 0
        totalCriticalCount = 0
        text = ""

        rollCount = diceCount

        while rollCount > 0
          diceArray = @randomizer.roll_barabara(rollCount, 10).sort
          diceText = diceArray.join(",")

          successCount = diceArray.count { |i| i <= target }
          criticalCount = diceArray.count { |i| i <= criticalNumber }

          totalSuccessCount += successCount
          totalCriticalCount += criticalCount

          text += "+" unless text.empty?
          text += "#{successCount}[#{diceText}]"

          rollCount = criticalCount
        end

        result = ""
        isDamage = (damage != 0)

        if isDamage
          totalDamage = totalSuccessCount * damage + totalCriticalCount * criticalTrigger

          result += "(#{diceCount}D10\<\=#{target}) ＞ #{text} ＞ Hits：#{totalSuccessCount}*#{damage}"
          result += " + Trigger：#{totalCriticalCount}*#{criticalTrigger}" if  criticalTrigger > 0
          result += " ＞ #{totalDamage}ダメージ"
        else
          result += "(#{diceCount}D10\<\=#{target}) ＞ #{text} ＞ 成功数：#{totalSuccessCount}"
        end

        result += " / #{totalCriticalCount}クリティカル" if totalCriticalCount > 0

        return result
      end
    end
  end
end

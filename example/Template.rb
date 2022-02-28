# frozen_string_literal: true

module BCDice
  module GameSystem
    class Template < Base
      # ゲームシステムの識別子
      ID = "OnseTool"

      # ゲームシステム名
      NAME = "オンセツールTRPG"

      # ゲームシステム名の読みがな
      SORT_KEY = "おんせつうるTRPG"

      HELP_MESSAGE = <<~TEXT
        ■ 判定 (nOT>=x)
          nD6のダイスロールをして、その合計が x を超えていたら成功。
          出目6が2個以上あればクリティカル。出目が全て1ならファンブル。

        ■ 表
        - オンセツール決定表 (TOOLS)
      TEXT

      register_prefix()

      def eval_game_system_specific_command(command)
        return nil
      end
    end
  end
end

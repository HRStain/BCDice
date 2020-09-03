# frozen_string_literal: true

module BCDice
  module GameSystem
    class StratoShout < Base
      # ゲームシステムの識別子
      ID = 'StratoShout'

      # ゲームシステム名
      NAME = 'ストラトシャウト'

      # ゲームシステム名の読みがな
      SORT_KEY = 'すとらとしやうと'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~INFO_MESSAGE_TEXT

        VOT, GUT, BAT, KEYT, DRT: (ボーカル、ギター、ベース、キーボード、ドラム)トラブル表
        EMO: 感情表
        AT[1-6]: 特技表(空: ランダム 1: 主義 2: 身体 3: モチーフ 4: エモーション 5: 行動 6: 逆境)
        SCENE, MACHI, GAKKO, BAND: (汎用、街角、学校、バンド)シーン表 接近シーンで使用
        TENKAI: シーン展開表 奔走シーン 練習シーンで使用

        []内は省略可　D66入れ替えあり
      INFO_MESSAGE_TEXT

      setPrefixes([
        'VOT',
        'GUT',
        'BAT',
        'KEYT',
        'DRT',
        'EMO',
        'AT[1-6]?',
        'SCENE',
        'MACHI',
        'GAKKO',
        'BAND',
        'TENKAI'
      ])

      def initialize
        super

        @sort_add_dice = true
        @d66Type = 2
      end

      def check_2D6(total, dice_total, _dice_list, cmp_op, target)
        return '' if target == '?'
        return '' unless cmp_op == :>=

        if dice_total <= 2
          " ＞ ファンブル！ (ドラマフェイズ: 【ディスコード】+2 / ライブフェイズ: 【コンディション】-2)"
        elsif dice_total >= 12
          " ＞ スペシャル！ (【コンディション】+2)"
        elsif total >= target
          " ＞ 成功"
        else
          " ＞ 失敗"
        end
      end

      def rollDiceCommand(command)
        case command.upcase
        when 'VOT'
          title = 'ボーカルトラブル表(P167)'
          table = [
            "歌詞を忘れてしまった！ 何も言葉が出てこない……",
            "マイクのコードに足を引っ掛けてしまった！ 危ない！",
            "マイクスタンドが倒れてしまった！",
            "音程がズレているけど、なかなか直せない！",
            "リズムがズレてきている気がする……修正できない！",
            "喉が枯れそうだ。まずい、セーブしないと……！"
          ]
          return textFrom1D6Table(title, table)
        when 'GUT'
          title = 'ギタートラブル表(P169)'
          table = [
            "やべっ、コードを間違えた！ どうにかごまかそう……",
            "ゲッ、シールド(信号を伝えるコード)が抜けちゃった！ 音が出ない！",
            "ギターの音にノイズが乗ってるような……直ってくれ……！",
            "あれ？ 今曲のどの辺りだっけ……？",
            "弦が切れてしまった！ なんて不吉な……。",
            "ピックが飛んでった！ 指で弾くしかない……！"
          ]
          return textFrom1D6Table(title, table)
        when 'BAT'
          title = 'ベーストラブル表(P171)'
          table = [
            "やべっ、コードを間違えた！ どうにかごまかそう……",
            "ゲッ、シールド(信号を伝えるコード)が抜けちゃった！ 音が出ない！",
            "ベースの音にノイズが乗ってるような……直ってくれ……！",
            "あれ？ 今曲のどの辺りだっけ……？",
            "指先の感覚が麻痺してきた。動かない……！",
            "テンポが速くなってきているけど、止まらない！"
          ]
          return textFrom1D6Table(title, table)
        when 'KEYT'
          title = 'キーボードトラブル表(P173)'
          table = [
            "指先の感覚が麻痺してきた。動かない……！",
            "音量のスライドに触れてしまった！ 爆音が出てしまう！",
            "あれ？ 今曲のどの辺りだっけ……？",
            "音の出ない鍵がある……故障！？",
            "音色を間違えた！ 元の音色は何番だっけ……！？",
            "手を置く位置が一つズレてる……！ 不協和音だ！"
          ]
          return textFrom1D6Table(title, table)
        when 'DRT'
          title = 'ドラムトラブル表(P175)'
          table = [
            "手がこんがらがってきた！ 軌道修正しないと……！",
            "あれ？ 今曲のどの辺りだっけ……？",
            "ハイハットが開かない！ ネジが緩んでるのか……！？",
            "アドリブ入れたけど、次のフレーズが思いつかない……！",
            "テンポが速くなってきているけど、止まらない！",
            "スティックが飛んでった！ 代わりはどこだっけ……。"
          ]
          return textFrom1D6Table(title, table)
        when 'EMO'
          title = '感情表(P183)'
          table = [
            "共感/不信",
            "友情/嫉妬",
            "好敵手/苛立ち",
            "不可欠/敬遠",
            "尊敬/劣等感",
            "愛情/負い目"
          ]
          return textFrom1D6Table(title, table)
        when /^AT([1-6]?)$/
          value = Regexp.last_match(1).to_i
          return getSkillList(value)
        when "SCENE"
          title = "シーン表(P199)"
          table = [
            "一人の時間。ふと過去の記憶を辿る。そういえば以前、あんなことがあったような……。",
            "どこからか、言い争っているような声が聞こえてきた。喧嘩だろうか？",
            "夜の帳が下り、辺りは静寂に包まれている。あいつは今、何をしているだろう。",
            "仲間と一緒にご飯を食べていると、会話は自然とあの話に……。",
            "笑い声に満ちた空間。ずっとこんな時間が続けばいいのに。",
            "日の当たる場所。毎日の忙しさを離れ、穏やかな時間が過ぎていく。",
            "スマートフォンに着信の通知がついていた。電話？ メッセージ？ 誰からだろう。",
            "突然、あなたのもとに来訪者が現れた。何か伝えたいことがあるようだ。",
            "誰かの忘れ物を見つけた。届けてあげたほうがいいだろうか。",
            "誰かが噂話をしている。聞くつもりはなくとも、それは勝手に耳に入ってきた。",
            "なんだか悪寒がする。なにか良くないことが起きているような……。"
          ]
          return textFrom2D6Table(title, table)
        when "MACHI"
          title = "街角シーン表(P199)"
          table = [
            "入ったことのない場所に、初めて足を踏み入れた。少し緊張してしまうな。",
            "アルバイト先。バイト仲間から、意外なことを教えられた。",
            "会話もままならないような、大音量の音楽。その場にいるだけで気分が高揚する。",
            "横断歩道で信号を待っていると、見知った人物の姿を見つけた。",
            "突然の雨に、慌てて足を早める人々。自分も早く帰らなければ。",
            "何気なく立ち寄った店の中で、知人とばったり。こんなところで何を？",
            "練習を終えて立ち寄った飲食店で、意外な人物を発見。少し様子を見てみよう。",
            "あちこちから子どもたちのはしゃぎ声が聞こえてくる。自分にもあんな頃があったんだろうか。",
            "音のない、静寂の世界。たまには音から離れるのもいいものだ。",
            "電車の中。つり革に掴まりながら揺られていると、見覚えのある乗客を見つけた。",
            "カラオケの廊下を歩いていると、どこからか聞き覚えのある声が……？"
          ]
          return textFrom2D6Table(title, table)
        when "GAKKO"
          title = "学校シーン表(P199)"
          table = [
            "校舎裏、何かを話す二人組を見かけた。一体何を話しているのだろう……？",
            "とある部室。部員たちは集中して部活に励んでいるようだが……。",
            "先生から、ターゲットについて尋ねられた。なにか気になることがあるようだ。",
            "木々の隙間から朝日差し込む通学路。ある者は忙しそうに、またある者は楽しそうに校舎へ向かっている。",
            "休み時間。教室のあちこちで飛び交う、他愛のない噂話。その中から、気になる会話が聞こえてきた。",
            "何もかもが茜色に染まる夕暮れ時。生徒たちは学業から解放され、自由に残り少ない一日を過ごしている。",
            "移動教室だ。渡り廊下から下を見ると、見覚えのある人物がいた。",
            "昼休み。生徒は思い思いの場所で昼食を取っている。さて、自分はどこで食べようか。",
            "先生から頼まれごとを引き受けてしまった。さっさと済ませてしまおう。",
            "そろそろ学校が閉まる時間だ。明かりのついている教室はもうほとんどない。",
            "スピーカーから校内放送が聞こえた。誰かを呼んでいるようだが……？"
          ]
          return textFrom2D6Table(title, table)
        when "BAND"
          title = "バンドシーン表(P199)"
          table = [
            "音楽専門のニュースサイトをチェック。大小様々な記事が投稿されている。",
            "意外なところで練習している人物を発見。少し声をかけてみようか。",
            "ちょっとした壁に衝突。誰かに相談した方がいいかも……。",
            "ライブを見るためライブハウスへとやってきた。どんなステージになるのだろう。",
            "打ち合わせに行ったライブハウス。来ているのは自分たちだけじゃないようだ。",
            "練習が終わった帰り道。あいつも練習が終わった頃だろうか。",
            "どこからか楽器の音が聞こえてくる。誰か演奏しているのだろうか。",
            "熱気のこもる部屋を出て、スタジオの待合室でクールダウン。ソファに座っているのは……。",
            "訪れた楽器店で、見知った人物を発見。何をしに来ているのだろう。",
            "最新のヒット曲が流れるCDショップの店内。次はどんな曲をやろうか……。",
            "何気なく鳴らした音から、突発セッションに発展。軽く実力を見せつけてやろう。"
          ]
          return textFrom2D6Table(title, table)
        when 'TENKAI'
          title = 'シーン展開表(P201)'
          table = [
            [11, "絶望: ステップを更に大きくする、あるいはシーンプレイヤーを破滅に追い込むような状況に陥ります。【ディスコード】+2点。"],
            [12, "崩壊: ステップによってシーンプレイヤーの大切なものが崩壊する、あるいは崩壊目前に追い込まれます。【ディスコード】+2点。"],
            [13, "断絶: シーンプレイヤーはステップによって何かと絶縁状態になります。【ディスコード】+2点。"],
            [14, "恐怖: ステップに恐怖するような出来事に遭遇します。【ディスコード】+2点。"],
            [15, "誤解: シーンプレイヤーがステップに関するなんらかの誤解を受けます。【ディスコード】+2点。"],
            [16, "試練: シーンプレイヤーはステップに関連した試練に直面します。【ディスコード】+2点。"],
            [22, "悪心: シーンプレイヤーの心に魔が差し、ステップを不合理に解決しようとします。【ディスコード】+1点。"],
            [23, "束縛: ステップに関わるなんらかに束縛され、自由な行動ができなくなります。【ディスコード】+1点。"],
            [24, "凶兆: ステップについて、悪いことが起きそうな前触れが訪れます。【ディスコード】+1点。"],
            [25, "加速: シーンプレイヤーはステップの解決に追われます。【ディスコード】+1点。"],
            [26, "日常: シーンプレイヤーはのんびりとした日常を送ります。【コンディション】+1点。"],
            [33, "休息: ステップを忘れられるような、穏やかなひとときを過ごします。【コンディション】+1点。"],
            [34, "吉兆: ステップについて、いいことが起きそうな前触れが訪れます。【コンディション】+1点。"],
            [35, "発見: シーンプレイヤーはステップについて何かを発見します。【コンディション】+1点。"],
            [36, "希望: シーンプレイヤーの中に、ステップに対して前向きに取り組む意思が生まれます。【コンディション】+1点。"],
            [44, "成長: ステップを通して、シーンプレイヤーが成長します。【コンディション】+2点。"],
            [45, "愛情: ステップを通して、シーンプレイヤーが愛情に触れます。【コンディション】+2点。"],
            [46, "朗報: ステップに関する良い知らせが舞い込みます。【コンディション】+2点。"],
            [55, "好転: ステップが良い方向に向かうような事件が起きます。【コンディション】+3点。"],
            [56, "直感: ステップを解決させる決定的な閃きを得ます。【コンディション】+3点。"],
            [66, "奇跡: ステップに関して、奇跡的な幸運が舞い込みます。【コンディション】+3点。"],
          ]
          return textFromD66Table(title, table)
          # when 'TEMP'
          #   title = '表(P)'
          #   table = [
          #     [11, ""],
          #     [12, ""],
          #     [13, ""],
          #     [14, ""],
          #     [15, ""],
          #     [16, ""],
          #     [22, ""],
          #     [23, ""],
          #     [24, ""],
          #     [25, ""],
          #     [26, ""],
          #     [33, ""],
          #     [34, ""],
          #     [35, ""],
          #     [36, ""],
          #     [44, ""],
          #     [45, ""],
          #     [46, ""],
          #     [55, ""],
          #     [56, ""],
          #     [66, ""],
          #   ]
          #   return textFromD66Table(title, table)
        end

        return nil
      end

      def textFromD66Table(title, table)
        isSwap = true
        dice = getD66(isSwap)
        number, text, = table.assoc(dice)

        return "#{title} ＞ [#{number}] ＞ #{text}"
      end

      def textFrom1D6Table(title, table1, table2 = nil)
        text1, number1 = get_table_by_1d6(table1)

        text = "#{title} ＞ "
        if table2.nil?
          text += "[#{number1}] ＞ #{text1}"
        else
          text2, number2 = get_table_by_1d6(table2)
          text += "[#{number1},#{number2}] ＞ #{text1}#{text2}"
        end

        return text
      end

      def textFrom2D6Table(title, table)
        text, number = get_table_by_2d6(table)

        return "#{title} ＞ [#{number}] ＞ #{text}"
      end

      def getSkillList(field = 0)
        title = '特技リスト'
        table = [
          ['主義', ['過去', '恋人', '仲間', '家族', '自分', '今', '理由', '夢', '世界', '幸せ', '未来']],
          ['身体', ['頭', '目', '耳', '口', '胸', '心臓', '血', '背中', '手', 'XXX', '足']],
          ['モチーフ', ['闇', '武器', '魔法', '獣', '町', '歌', '食べ物', '花', '空', '季節', '光']],
          ['エモーション', ['悲しい', '怒り', '不安', '恐怖', '驚き', '高鳴り', '情熱', '確信', '期待', '楽しい', '喜び']],
          ['行動', ['泣く', '忘れる', '消す', '壊す', '叫ぶ', '歌う', '踊る', '走る', '鳴らす', '呼ぶ', '笑う']],
          ['逆境', ['死', '喪失', '暴力', '孤独', '後悔', '実力', '退屈', '権力', '富', '恋愛', '生']],
        ]

        number1 = 0
        if field == 0
          table, number1 = get_table_by_1d6(table)
        else
          table = table[field - 1]
        end

        fieldName, table = table
        skill, number2 = get_table_by_2d6(table)

        text = title
        if field == 0
          text += " ＞ [#{number1},#{number2}]"
        else
          text += "(#{fieldName}分野) ＞ [#{number2}]"
        end

        return "#{text} ＞ 《#{skill}／#{fieldName}#{number2}》"
      end
    end
  end
end

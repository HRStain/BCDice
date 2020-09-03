# frozen_string_literal: true

module BCDice
  module GameSystem
    class Amadeus < Base
      # ゲームシステムの識別子
      ID = 'Amadeus'

      # ゲームシステム名
      NAME = 'アマデウス'

      # ゲームシステム名の読みがな
      SORT_KEY = 'あまてうす'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~INFO_MESSAGE_TEXT
        ・判定(Rx±y@z>=t)
        　能力値のダイスごとに成功・失敗の判定を行います。
        　x：能力ランク(S,A～D)　y：修正値（省略可）
        　z：スペシャル最低値（省略：6）　t：目標値（省略：4）
        　　例） RA　RB-1　RC>=5　RD+2　RS-1@5>=6
        　出力書式は
        　　(達成値)_(判定結果)[(出目)(対応するインガ)]
        　C,Dランクでは対応するインガは出力されません。
        　　出力例)　2_ファンブル！[1黒] / 3_失敗[3青]
        ・各種表
        　境遇表 ECT／関係表 RT／親心表 PRT／戦場表 BST／休憩表 BT／
        　ファンブル表 FT／致命傷表 FWT／戦果表 BRT／ランダムアイテム表 RIT／
        　損傷表 WT／悪夢表 NMT／目標表 TGT／制約表 CST／
        　ランダムギフト表 RGT／決戦戦果表 FBT／
        　店内雰囲気表 SAT／特殊メニュー表 SMT
        ・試練表（～VT）
        　ギリシャ神群 GCVT／ヤマト神群 YCVT／エジプト神群 ECVT／
        　クトゥルフ神群 CCVT／北欧神群 NCVT／中華神群 CHVT／
          ラストクロニクル神群 LCVT／ケルト神群 KCVT／ダンジョン DGVT／日常 DAVT
        ・挑戦テーマ表（～CT）
        　武勇 PRCT／技術 TCCT／頭脳 INCT／霊力 PSCT／愛 LVCT／日常 DACT
      INFO_MESSAGE_TEXT

      def initialize
        super

        @sort_add_dice = true
        @d66Type = 2
      end

      def rollDiceCommand(command)
        text = amadeusDice(command)
        return text unless text.nil?

        info = TABLES[command.upcase]
        return nil if info.nil?

        name = info[:name]
        type = info[:type]
        table = info[:table]

        text, number =
          case type
          when '1D6'
            get_table_by_1d6(table)
          when '2D6'
            get_table_by_2d6(table)
          when 'D66'
            get_table_by_d66_swap(table)
          end

        return nil if text.nil?

        return "#{name}(#{number}) ＞ #{text}"
      end

      def amadeusDice(command)
        return nil unless /^(R([A-DS])([\+\-\d]*))(@(\d))?((>(=)?)([\+\-\d]*))?(@(\d))?$/i =~ command

        commandText = Regexp.last_match(1)
        skillRank = Regexp.last_match(2)
        modifyText = Regexp.last_match(3)
        signOfInequality = (Regexp.last_match(7).nil? ? ">=" : Regexp.last_match(7))
        targetText = (Regexp.last_match(9).nil? ? "4" : Regexp.last_match(9))
        if nil | Regexp.last_match(5)
          specialNum = Regexp.last_match(5).to_i
        elsif nil | Regexp.last_match(11)
          specialNum = Regexp.last_match(11).to_i
        else
          specialNum = 6
        end

        diceCount = CHECK_DICE_COUNT[skillRank]
        modify = ArithmeticEvaluator.new.eval(modifyText)
        target = ArithmeticEvaluator.new.eval(targetText)

        _, diceText, = roll(diceCount, 6)
        diceList = diceText.split(/,/).map(&:to_i)
        specialText = (specialNum == 6 ? "" : "@#{specialNum}")

        message = "(#{commandText}#{specialText}#{signOfInequality}#{targetText}) ＞ [#{diceText}]#{modifyText} ＞ "
        diceList = [diceList.min] if skillRank == "D"
        is_loop = false
        diceList.each do |dice|
          if  is_loop
            message += " / "
          elsif diceList.length > 1
            is_loop = true
          end
          achieve = dice + modify
          result = check_success(achieve, dice, signOfInequality, target, specialNum)
          if is_loop
            message += "#{achieve}_#{result}[#{dice}#{INGA_TABLE[dice]}]"
          else
            message += "#{achieve}_#{result}[#{dice}]"
          end
        end

        return message
      end

      def check_success(total_n, dice_n, signOfInequality, diff, special_n)
        return "ファンブル！" if  dice_n == 1
        return "スペシャル！" if  dice_n >= special_n

        cmp_op = Normalize.comparison_operator(signOfInequality)
        target_num = diff.to_i

        if total_n.send(cmp_op, target_num)
          "成功"
        else
          "失敗"
        end
      end

      CHECK_DICE_COUNT = {"S" => 4, "A" => 3, "B" => 2, "C" => 1, "D" => 2}.freeze
      INGA_TABLE = [nil, "黒", "赤", "青", "緑", "白", "任意"].freeze

      TABLES =
        {
          "ECT" => {
            name: "境遇表",
            type: '1D6',
            table: [
              '告白。あなたは、神と人間（獣の子の場合は何らかの動物）が愛し合って生まれた神子です。最近になって、その事実と予言について、自分の親から知らされました。あなたに両親がいる場合、どちらかの親は義理の親となります。',
              '孤児。あなたは、親のことについて何も知りませんでした。過酷な環境で暮らすなか、あなたの兄弟姉妹が、あなたを迎えに来ました。そして、あなたが神の子どもであり、予言の持ち主だということを教えてくれました。',
              '家族。あなたは、神の子として幼い頃から生活していました。現実と＜聖地＞を行き来し、様々なことを神である親から教えてもらっています。そして、いつの日か冒険に旅立ち、英雄になる日を楽しみに待っていました。',
              '血脈。あなたの一族には、「大きな運命を持つ子が生まれる」という予言が伝わっていました。その予言の子があなたです。恐らく、あなたの遠い先祖に神がいたのでしょう。一族はあなたに大きな期待や畏怖を寄せています。',
              '加護。あなたは、その資質や才能を親神に見いだされました。そして、夢の中で親神と出会い、＜神の血＞を直接与えられました。それ以来、あなたは不思議なものが見えたり聞こえたりするようになりました。',
              '帰依。あなたは、怪物によって命の危機にさらされました。しかし、神の血を授かることによって、死の淵からよみがえりました。以来、あなたは自らを助けてくれた神に帰依し、その人生を捧げることにしました。'
            ],
          },

          "BST" => {
            name: "戦場表",
            type: '1D6',
            table: [
              '墓場。ラウンドの終了時、PCと怪物の本体は、【生命力】が1D6点減少します。また、この戦場にいる場合、PCがギフトを使用するとき、黒の領域にインガが追加で2つあるものとして扱います。',
              '市街地。すべてのPCと怪物は、与えるダメージが1D6点上昇します。また、この戦場にいる場合、PCがギフトを使用するとき、赤の領域にインガが追加で2つあるものとして扱います。',
              '水中。潜水状態にないPCは、あらゆる判定にマイナス1の修正がつきます。ラウンドの終了時、潜水状態でないPCと怪物の本体は、【生命力】が1D6点減少します。また、この戦場にいる場合、PCがギフトを使用するとき、青の領域にインガが追加で2つあるものとして扱います。',
              '森林。すべてのPCと怪物は、受けるダメージが1D6点軽減します。また、この戦場にいる場合、PCがギフトを使用するとき、緑の領域にインガが追加で2つあるものとして扱います。',
              '空中。飛行状態にないPCは、あらゆる判定にマイナス1の修正がつきます。戦闘終了時、怪物の【生命力】が1点以上残っていた場合、その戦闘中に一度も飛行状態にならなかったPCと怪物の本体は、【生命力】が［戦闘に費やした乱戦ラウンド数×3D6］点減少します。また、この戦場にいる場合、PCがギフトを使用するとき、白の領域にインガが追加で2つあるものとして扱います。',
              '平地。特に変わった効果はありません。'
            ],
          },

          "RT" => {
            name: "関係表",
            type: '1D6',
            table: [
              '恋心（プラス）／殺意（マイナス）',
              '同情（プラス）／侮蔑（マイナス）',
              '憧憬（プラス）／嫉妬（マイナス）',
              '信頼（プラス）／疑い（マイナス）',
              '共感（プラス）／不気味（マイナス）',
              '大切（プラス）／面倒（マイナス）'
            ],
          },

          "PRT" => {
            name: "親心表",
            type: '1D6',
            table: [
              'かわいい（プラス）／生意気（マイナス）',
              '期待（プラス）／脅威（マイナス）',
              '自慢（プラス）／恥（マイナス）',
              '愛情（プラス）／無関心（マイナス）',
              '有用（プラス）／心配（マイナス）',
              '過保護（プラス）／執着（マイナス）'
            ],
          },

          "FT" => {
            name: "ファンブル表",
            type: '1D6',
            table: [
              '運命の輪が回転する。運命の輪の上にある赤の領域のインガを青の領域に、青の領域のインガを緑の領域に、緑の領域のインガを白の領域に、白の領域のインガを赤の領域に、それぞれ同時に移動させる。',
              '仲間に迷惑をかけてしまう。自分以外のPC全員の【生命力】が1点減少する。',
              'この失敗は後に祟るかもしれない……。自分の【生命力】が1D6点減少する。',
              'あまりの失敗に、みんなの態度が変わる。自分に対して一番高い【想い】の値を持っているキャラクター全員の、【想い】の属性が反転する。',
              '心に大きな乱れが生まれる。自分の属性に対応した変調を受ける（黒なら絶望、赤なら憤怒、青なら臆病1、緑なら堕落、白なら恥辱）。',
              '周囲から活気が失われる。運命の輪のなかから、黒以外の領域のインガがすべて1つずつ減少する。'
            ],
          },

          "BT" => {
            name: "休憩表",
            type: 'D66',
            table: [
              [11, "土着の怪物が襲いかかってきた！　なんとか撃退するが、傷を負ってしまった。1D6点のダメージを受ける。"],
              [12, "美女の沐浴をのぞいてしまった。1D6を振る。1～2なら「堕落」、3～4なら「恥辱」、5～6なら「重傷1」の変調を受ける。"],
              [13, "強欲な商人に出会う。このシーンに登場したキャラクターは、アイテムを購入することができる。ただし、すべてのアイテムの価格は通常の値段より1高い。"],
              [14, "自分の過去の話をする。なんで、こんな話しちゃったんだろう？　PCの中から、自分に対してもっとも高い【想い】を持つPC全員の、関係の属性が反転する。"],
              [15, "周囲の空気が変わった。運命の輪が動き出す予感！運命の輪の上にある赤の領域のインガを青の領域に、青の領域のインガを緑の領域に、緑の領域のインガを白の領域に、白の領域のインガを赤の領域に、それぞれ同時に移動させる。"],
              [16, "突然の空腹に襲われる。このシーン中に食事を行わなかったPCは「重傷2」の変調を受ける。この変調は、食事を行うと回復できる（ほかの方法でも回復可能）。"],
              [22, "＜絶界＞の外の世界の友人のことを思い出す。みんなは元気にしているだろうか？　この出目を振ったプレイヤーのPCは、【日常】で判定を行うことができる。成功すると、自分の変調を1つ回復するか、黒の領域からインガを1つ取り除くことができる。"],
              [23, "奇妙な商人に出会う。このシーンに登場したキャラクターは、アイテムを購入することができる。"],
              [24, "喋る動物に願いごとをされる。動物たちも、この神話災害で苦しんでいるようだ。あなたは、「この怪物の本体の【生命力】を0にする」という追加の【任務】を受けることができる。この【任務】を達成すると、追加で経験値を20点もらうことができる。"],
              [25, "素敵な夢を見る。この出目を振ったプレイヤーは、自分のPC以外の好きなキャラクター一人に対する【想い】が1点上昇する。"],
              [26, "大切な人から、あなたを心配するメールが届いていた。なんて返そう？　この出目を振ったプレイヤーのPCは、【日常】で判定を行うことができる。成功すると、自分の変調を1つ回復するか、自分の好きなパトスマークについたチェックを1つ消す。"],
              [33, "親切な商人に出会う。このシーンに登場したキャラクターは、アイテムを購入することができる。ただし、すべてのアイテムの価格は通常の値段より1低い（価格1未満にはならない）。"],
              [34, "武器の手入れを行う。この出目を振ったプレイヤーのPCは、【日常】で判定を行うことができる。成功すると、そのセッションの間、自分の武器1つの威力を1点上昇させることができる。"],
              [35, "最後に買い物をしたときに、おつりを多くもらっていたことに気がついた。1神貨を手に入れる。"],
              [36, "食事をしながら、仲間と大いに語り合う。このシーンに登場して、食事を行ったキャラクターは、自分の好きなパトスマークについたチェックを一つ消す。"],
              [44, "一眠りしてしまったのか、不思議な夢を見る。この出目を振ったプレイヤーのPCは、【霊力】で判定を行うことができる。成功すると、好きな予言カード1枚を選び、その【真実】を見ることができる。"],
              [45, "チンピラにからまれている異性の子を見つける。この出目を振ったプレイヤーのPCは、【武勇】で判定を行うことができる。成功すると、その子は、そのPCに対して【想い】を1点獲得する。この子を協力者にするなら、そのプレイヤーはその子の名前と関係を自由に決めること。"],
              [46, "心地よい風に吹かれる。運命があなたに味方してくれるような気がした。好きな領域にインガを1つ配置する。"],
              [55, "目が覚めると、枕元に贈り物が。誰からだろう……？　この出目を振ったプレイヤーのPCは、「ランダムアイテム表」を使用する。"],
              [56, "困っている神話生物を助けてあげた。【日常】で判定を行う。成功すると、次に移動判定を行うことになったとき、自動的にそれを成功にすることができる（達成値が必要な場合6として扱う）。"],
              [66, "親神が、あなたに話しかけてくる。親子の会話だ。この出目を振ったプレイヤーのPCは、【日常】で判定を行うことができる。成功すると、自分の親神に対する【想い】か、親神の自分に対する【想い】のいずれかを1点上昇する。"],
            ],
          },

          "FWT" => {
            name: "致命傷表",
            type: '1D6',
            table: [
              '絶望的な攻撃を受ける。そのキャラクターは死亡する。',
              '苦痛の悲鳴をあげ、無惨にも崩れ落ちる。そのキャラクターは行動不能になる。また、黒の領域のインガが1つ増える。',
              '攻撃を受けた武器が砕け、敵の攻撃が直撃する。そのキャラクターは行動不能になる。また、自分の武器一つを破壊する。',
              '強烈な一撃を受けて気絶する。そのキャラクターは行動不能になる。',
              '意識はあるが、立ち上がることができない。そのキャラクターは行動不能になる。次のシーンになったら【生命力】が1点に回復する。',
              '奇跡的に持ちこたえる。【生命力】1点で踏みとどまる。'
            ],
          },

          "BRT" => {
            name: "戦果表",
            type: '1D6',
            table: [
              '１神貨を獲得する。',
              '1D6神貨を獲得する。',
              '好きな領域にインガを1つ置く。',
              '黒の領域からインガを1つ取り除く。',
              '「ランダムアイテム」表で、アイテムを入手できる。',
              'PC全員、自分の人物欄の中から、パトスのチェックを1つ消すことができる。'
            ],
          },

          "RIT" => {
            name: "ランダムアイテム表",
            type: '2D6',
            table: [
              '「鎧」を1個獲得する。',
              '「手がかり」を1個獲得する。',
              '「お洒落」を1個獲得する。',
              '「護符」を1個獲得する。',
              '「甘露」を1個獲得する。',
              '「食料」を1D6個獲得する。',
              '「お香」を1個獲得する。',
              '「供物」を1個獲得する。',
              '「霊薬」を1個獲得する。',
              '「ごちそう」を1個獲得する。',
              '「爆弾」を1個獲得する。'
            ],
          },

          "WT" => {
            name: "損傷表",
            type: '1D6',
            table: [
              '自分の【生命力】を1D6点減少する。',
              '1D6神貨を失う。',
              '黒の領域にインガを1つ置く。',
              '「臆病2」の変調を受ける。',
              '「重傷3」の変調を受ける。',
              '自分の人物欄のもっとも高い【想い】1つを選び、それを1点減少する。'
            ],
          },

          "NMT" => {
            name: "悪夢表",
            type: '1D6',
            table: [
              '絶望の闇に視界を遮断される。背後に怪物の気配を感じたと思ったときは遅かった。卑劣な攻撃があなたを襲う。好きな能力値で判定を行う。失敗すると死亡する。',
              '絶望の闇の中、悲痛な叫びが聞こえてくる。事件の被害者たちだろうか。あなたは、救えなかったのだ。【日常】で判定を行う。失敗すると、「絶望」の呪いを受ける。',
              '絶望の闇の中で怪物の笑いがこだまする。それは嘲りの笑いだった。怪物や仲間たち……何より自分への怒りがわき上がる。【日常】で判定を行う。失敗すると、「憤怒」の呪いを受ける。',
              '絶望の闇の中に一人取り残される。誰もあなたに気づかない。孤独に耐えながら、何とか日常へ帰還したが……そのときの恐怖がぬぐえない。【日常】で判定を行う。失敗すると、「臆病3」の呪いを受ける。',
              '絶望の闇から帰還したあなたを待っていたのは、代わり映えのない日常だった。あなたが任務に失敗しても、世界は変わらない。なら、もう、あんな怖い目をする必要はないんじゃないか？　【日常】で判定を行う。失敗すると、「堕落」の呪いを受ける。',
              '絶望の闇の中を必死で逃げ出した。背後から仲間の声が聞こえた気がする。しかし、あなたは振り返ることができなかった。【日常】で判定を行う。失敗すると、「恥辱」の呪いを受ける。'
            ],
          },

          "TGT" => {
            name: "目標表",
            type: '1D6',
            table: [
              '悪意。PCの中でもっとも【生命力】の低いもの一人を目標に選ぶ。もっとも低い【生命力】の持ち主が複数いる場合、その中から、GMが自由に一人目標を選ぶ。',
              '狡猾。もっとも数値が高いパラグラフにいるPC一人を目標に選ぶ。全員が欄外にいる場合、欄外にいるPC全員を目標に選ぶ。',
              '非道。PCの中でもっとも低いランクの【武勇】の持ち主一人を目標に選ぶ。もっとも低いランクの持ち主が複数いる場合、その中から、もっとも低いモッドの持ち主一人を目標に選ぶ。モッドも同じ値だった場合、GMがその中から自由に一人目標を選ぶ。',
              '堅実。PCの中でもっとも低いランクの【技術】の持ち主一人を目標に選ぶ。もっとも低いランクの持ち主が複数いる場合、その中から、もっとも低いモッドの持ち主一人を目標に選ぶ。モッドも同じ値だった場合、GMがその中から自由に一人目標を選ぶ。',
              '豪快。PCの中でもっとも高いランクの【武勇】の持ち主一人を目標に選ぶ。もっとも高いランクの持ち主が複数いる場合、その中から、もっとも高いモッドの持ち主一人を目標に選ぶ。モッドも同じ値だった場合、GMがその中から自由に一人目標を選ぶ。',
              '単純。もっとも数値が低いパラグラフにいるPC一人を目標に選ぶ。全員が欄外にいる場合、欄外にいるPC全員を目標に選ぶ。'
            ],
          },

          "CST" => {
            name: "制約表",
            type: '1D6',
            table: [
              '短命',
              '誘惑',
              '悪影響',
              '束縛',
              '喧嘩',
              '干渉'
            ],
          },

          "GCVT" => {
            name: "ギリシャ神群試練表",
            type: '1D6',
            table: [
              '山の向こうから一つ目の巨人、サイクロプスがこちらを見ている。岩を投げてきた！1D6点のダメージを受ける。',
              '水音に目を向けると、アルテミスが泉で水浴びをしていた。美しい……あ、気づかれた？自分が男性なら、「重傷2」の変調を受ける。自分が女性なら、「恥辱」の変調を受ける。',
              '海を渡ろうとすると、海が渦巻き乗った船が引き寄せられていく。中心にいるのは怪物カリュブディスだ。このままだと、船ごと飲み込まれてしまう。［青の領域にあるインガの数］点ダメージを受ける。',
              'デュオニソスの女性信者、マイナスたちに取り囲まれる。彼女たちは完全に酔っ払っており、話は通じない上、酒を飲めと強要してくる。【生命力】が1点回復し、「堕落」の変調を受ける。',
              '巨大な天井を支えている巨人と出会う。巨人は「少しの間、支えるのを代わってくれないか？」と頼んでくる。断りにくい雰囲気だ……。【愛】で判定を行う。失敗すると、そのセッションの間、所持品の欄が一つ使えなくなる。その欄にアイテムが記入されていれば、それを捨てること。',
              '「あなた最近、調子に乗ってない？」アフロディーテに難癖をつけられた。「自分のことだけ見てればいいんじゃない？」鏡に映る自分が、とても美しく思えてきた。自分への【想い】が2点上昇し、それ以外の人物欄のパトスすべてにチェックを入れる。'
            ],
          },

          "YCVT" => {
            name: "ヤマト神群試練表",
            type: '1D6',
            table: [
              '空が急に暗くなる。太陽がどこにも見えない。もしかして、アマテラスが隠れてしまったのか？黒の領域にインガを一つ配置する。',
              'いつのまにか、黄泉国に迷い込んでしまっていた。周囲は黄泉軍に取り囲まれている。どうにかして、逃げなくては！移動判定を行う。失敗すると、3点のダメージを受け、もう一度「試練表」を振る。',
              '目の前の海はワニザメでいっぱいだ。この海を渡らなければ、目的地にはたどり着けないのに。青の領域のインガを二つ取り除くか、自分が2D6点のダメージを受けるかを選ぶ。',
              '「みんなー楽しんでるー!?」ここはウズメが歌い踊るライブ会場だ。どうしよう、目的を忘れそうなほど楽しい！自分は、自分の属性のインガを一つ取り除くか、「堕落」の変調を受けるかを選ぶ。',
              '「龍の首の珠を取るのを手伝ってくれませんか？そうしたら、船に乗せてさしあげます」平安貴族のような格好をした男が話しかけてくる。手伝うしかないようだ。「重傷1」の変調を受ける。',
              '海岸でいじめられている亀を助けたら、海の中の宮殿につれてきてくれた。トヨタマヒメが現れ、盛大にもてなしてくれる。あっという間に、夢のような時間が過ぎていく。でも、そろそろ行かなくては。【日常】で判定する。失敗すると、自分の年齢を6D6歳増やし、「絶望」の変調を受ける。'
            ],
          },

          "ECVT" => {
            name: "エジプト神群試練表",
            type: '1D6',
            table: [
              '大蛇アペプが今にも目の前の空で輝く太陽を、飲み込もうとしている！止めなくては！【武勇】で判定する。失敗すると、黒の領域にインガを二つ配置する。',
              '気がつけば、魂が羽の生えたバーだけになって、空を飛んでいた。早く肉体に戻らなくては。【霊力】で判定する。自分の【生命力】を1D6点減少し、もう一度「試練表」を振る。',
              'ぐつぐつと沸き立つ湖と、流れる火の川が見える。目的地は、この川を越えた先にある。【技術】で判定する。失敗すると、炎タグのついた2D6点のダメージを受け、黒以外の領域のインガが一つずつ取り除かれる。',
              '冥界ドゥアトの番人たちが、目の前に現れた。と畜場より来る吸血鬼、下半身の排泄物を喰らうものが近づいてくる。ここは冥界なのか、それとも、やつらが地上に這い出してきたのか。自分は、「重傷1」の変調を受けるか、「恥辱」の変調を受けるかを選ぶ。',
              '目の前にアヌビスがいる。アヌビスは天秤を掲げて、心臓を要求してくる。「お前の罪を数えろ」【日常】で判定を行う。失敗すると、【活力】が0点になる。この効果によって【生命力】の現在値が最大値を超えた場合、最大値と同じ値に調整する。',
              '獅子頭の神、シェセムが、悪人の頭を砕いて、死者のためのワインにしている。悪人と見なされれば、頭をもがれてしまうだろう。【日常】で判定を行う。失敗すると、「重傷2」の変調を受ける。'
            ],
          },

          "CCVT" => {
            name: "クトゥルフ神群試練表",
            type: '1D6',
            table: [
              '新聞記者たちが忙しく行き来しているオフィスにいる。ここは、新聞社アーカムアドバタイザーの編集部だ。「君が大きなニュースを持っていると聞いたんだけれど」記者の一人が尋ねてくる。自分の【真実】が公開されていなければ、「臆病1」の変調を受ける。',
              '魚の顔と鱗に覆われた身体をもつ、ディープワンに取り囲まれる。あなたが女性ならば、彼らのすみかに連れ去られてしまう。男性ならば、暴力を振るわれ、1D6点のダメージを受ける。女性なら、衣服を奪われ、「恥辱」の変調を受ける。',
              'ここはどうやら夢の中らしい。目の前にクトゥルフがいる。「余になんの用だ。余を目覚めさせる気なら、容赦はしない」寝ぼけ眼のくせに、クトゥルフは怒っているようだ。「絶望」の変調を受ける。',
              '地下のもぐり酒場で一息つけた……と思ったら、トンプソン機関銃を構えた男たちが飛び込んできた。マフィアの抗争だ！4点のダメージを受ける。',
              '古ぼけた本を手に入れた。どうやら、魔導書のようだ。読むと正気を失う可能性もあるが、力が手に入る可能性も高い。【霊力】のランクがA以上なら、好きな領域にインガを二つ配置する。そうでない場合、「絶望」と「臆病2」の変調を受ける。',
              'なんの変哲も無い民家にいる。アーカムの静かな風景が……ああ、窓に！窓に！黒の領域にインガを一つ配置する。'
            ],
          },

          "NCVT" => {
            name: "北欧神群試練表",
            type: '1D6',
            table: [
              '美しい乙女が告げる。「あなたはエインヘリアルたる資格がある」どうやら、戦乙女ヴァルキュリャに見初められたらしい。彼女たちは、戦死した者の魂を連れていくのだが。自分は、戦乙女から【想い】を2点獲得する。この【想い】の関係はマイナスの「殺意」となる。',
              '雄叫びと共に現れたのは、獣の皮を被った屈強な戦士たち、ベルセルクだった。手に手に斧を構え、こちらに向かってくる！【武勇】で判定を行う。失敗すると、2D6点のダメージを受ける。',
              'オーディンの神子、エインヘリアルたちの宴会に紛れ込んでしまった。山のように積まれたご馳走を好きに食べていいと思ったら、「勝負だ！」という声。食べ比べを挑まれている。神子としては、負けるわけにはいかない。【日常】で判定を行う。失敗すると、「恥辱」の変調を受ける。',
              '「ここは我々の土地だ。ただで通れると思っているのか？」ドヴェルグが行く手を塞ぎ、神貨を要求してくる。彼らはがめついことで有名だ。神貨を2点支払う。支払わない場合、自分の【生命力】を1点減少して、もう一度「試練表」を使用する。',
              '「このまま冒険を続けても簡単すぎるんじゃないか？」ロキが話し掛けてきた。気がつくと君は狼の姿に変わっていた。このセッションの間、自分に「獣」のタグがつき、【愛】のランクが1段階低くなる（Dは変化しない）。',
              '巨人が話し掛けてくる。「お前に力をやってもいい。代わりに、片目か、片腕をよこせ」オーディンは片目を差し出して、知恵を手に入れた。嘘ではないだろうが……。【生命力】を3D6点減少することで、好きな領域にインガを二つ配置できる。減少しなかった場合、「臆病1」の変調を受ける。'
            ],
          },

          "DGVT" => {
            name: "ダンジョン試練表",
            type: '1D6',
            table: [
              '照明が切れてしまい、暗闇の中に放り出される。前が見えない。白の領域からインガを一つ取り除く。',
              '罠だ！こちらに向かって、巨大な岩が転がって来る！【技術】で判定する。失敗すると、2D6点のダメージを受ける。',
              '宝箱発見。罠がないかを慎重に調べてみよう。【技術】で判定する。成功すると、1神貨を獲得する。失敗すると、「憤怒」と「恥辱」の変調を受ける。',
              '謎解きが必要な部分に迷い込む。この謎を解かなければ、罠を無理矢理突破しなければならない。【頭脳】で判定を行う。失敗すると、「絶望」の変調を受け、1D6点のダメージを受ける。',
              '粘液が飛び散る部屋に入ってしまった。まずい、何でも溶かす酸だ！自分が装備しているアイテムの中から一つを選ぶ。選んだアイテムを破壊する。【食料】を選んだ場合は、すべての【食料】を破壊する。',
              '怪物たちのすみかに迷い込んでしまったようだ。怪物が一斉に襲ってくる！【武勇】で判定を行う。失敗すると、2D6点のダメージを受ける。'
            ],
          },

          "DAVT" => {
            name: "日常試練表",
            type: '1D6',
            table: [
              '仲間と移動していると、一般人の友達と偶然出会ってしまう。今何をしているかを聞かれたので、なんとかごまかす。自分に対して【想い】の値を持っているPC全員の属性が反転する。',
              '仕事や勉強を催促する電話がかかってきた。今はそれどころじゃないんだって！「憤怒」の変調を受ける。',
              'ふと、見たかったテレビ番組を見逃していたことに気づいてしまう。録画もしてない。ちょっと凹む。自分の属性と同じ領域にあるインガを一つ取り除く。',
              '警官に捕まって、職務質問を受ける。ちょっと言えない理由で、急いでいるんですけど。黒の領域にインガを一つ配置する。',
              '自分の格好や言動が浮いていたらしい、自分を噂するひそひそ話が聞こえてきてしまう。「恥辱」の変調を受けるか、【食料】以外のアイテムを1つ破壊する。',
              '乗りたかった電車やバスに乗り遅れる。仕方ないから、走るか。移動判定を行う。失敗すると、「堕落」の変調を受け、もう一度「試練表」を使用する。'
            ],
          },

          "PRCT" => {
            name: "挑戦テーマ表【武勇】",
            type: '1D6',
            table: [
              '腕相撲',
              '喧嘩',
              '度胸試し',
              'レスリング',
              '狩り',
              '武勇伝自慢'
            ],
          },

          "TCCT" => {
            name: "挑戦テーマ表【技術】",
            type: '1D6',
            table: [
              '織物',
              '戦車レース',
              'マラソン',
              'アクションゲーム',
              '射的',
              '資格自慢'
            ],
          },

          "INCT" => {
            name: "挑戦テーマ表【頭脳】",
            type: '1D6',
            table: [
              'パズル',
              '謎かけ',
              'チェス',
              '筆記試験',
              '禅問答',
              '学歴自慢'
            ],
          },

          "PSCT" => {
            name: "挑戦テーマ表【霊力】",
            type: '1D6',
            table: [
              '詩作',
              '動物を手なずける',
              '北風と太陽',
              '絵画',
              '演奏',
              'のど自慢'
            ],
          },

          "LVCT" => {
            name: "挑戦テーマ表【愛】",
            type: '1D6',
            table: [
              'ナンパ勝負',
              '誰かからより愛される',
              '美人コンテスト',
              'ティッシュ配り',
              '借り物競争',
              '恋愛自慢'
            ],
          },

          "DACT" => {
            name: "挑戦テーマ表【日常】",
            type: '1D6',
            table: [
              '料理',
              '大食い',
              '呑み比べ',
              '倹約生活',
              'サバイバル',
              'リア充自慢'
            ],
          },

          "RGT" => {
            name: "ランダムギフト表",
            type: '1D6',
            table: [
              'ランダムに選んだPCと同じ親神の親神ギフトの中から選ぶ。',
              'GMが選んだキャラクターと同じ親神の親神ギフトの中から選ぶ。',
              'ランダムに選んだPCと同じ神群の神群ギフトの中から選ぶ。',
              'GMが選んだキャラクターと同じ神群の神群ギフトの中から選ぶ。',
              '好きな背景ギフトの中から選ぶ。',
              '好きな汎用ギフトの中から選ぶ。'
            ],
          },

          "FBT" => {
            name: "決戦戦果表",
            type: '1D6',
            table: [
              '1D6枚の神貨を獲得する。',
              '［戦闘に経過した偵察・乱戦・追撃ラウンド数の合計+2］枚の神貨を獲得する。',
              '［倒した怪物の本体レベル+2］枚の神貨を獲得する。',
              '［黒の領域の覚醒段階+2］枚の神貨を獲得。',
              '「ランダムアイテム表」で、アイテムを入手できる。',
              '「ランダムアイテム表」で、アイテムを入手できる。'
            ],
          },

          "CHVT" => {
            name: "中華神群試練表",
            type: '1D6',
            table: [
              'たどりついた場所は、桃源郷であった。すべてを忘れて、しばらく楽しんでしまう。年齢が2D6点上昇し、「堕落」の変調を受ける。',
              '風にさらわれて、仙人に出会う。仙人は、稽古をつけてくれるが、激しい修行に体はボロボロになってしまった。好きな領域にインガを一つ配置し、「重傷4」の変調を受ける。',
              '美男・美女に誘惑されるが、それは妖怪の化けた姿だった。たぶらかされたことに、怒りを覚える。「憤怒」の変調を受ける。',
              '名前を呼ばれたので、返事をしたら、瓶の中に吸い込まれてしまった。瓶の中から脱出をするまでに苦労をする。2D6点のダメージを受け、「恥辱」の変調を受ける。',
              '地府で行われてる閻魔の裁判に参考人として招集される。下手な証言をしたために、疑われて地獄に落とされかかった。「絶望」の変調を受ける。',
              '麒麟の死骸を発見してしまう。これは、不吉の前触れだ。黒の領域にインガを一つ配置する。'
            ],
          },

          "LCVT" => {
            name: "ラストクロニクル神群試練表",
            type: '1D6',
            table: [
              'レ・ムゥの五色の太陽がすべて輝きを失う「千年夜」の到来を幻視する。これは起こりうる未来なのだろうか……。黒の領域にインガを1つ配置する。',
              '召喚された小野小町が退屈を持て余してる。彼女の退屈を紛らわせるため【頭脳】か【愛】で判定する。失敗した場合、黒の領域にインガを1つ配置する。',
              '血肉を貨幣代わりに扱う商人・ブラッドトレーダーと出会う。ラストクロニクル神群の聖地の買い物リストからアイテムを1つ選ぶ。【生命力】を「価格×3点」消費することで、選んだアイテムを獲得する。',
              'あなたは旅の途中で美女と出会い、意気投合する。しかし、その女性はメレドゥスの魔闘士・メニズマだった。彼女は去り際にあなたの精気を奪い取る。【生命力】と【活力】がそれぞれ1D6点減少する。',
              '強欲なる司都官が治める街に迷い込んでしまう。通行料として神貨を1D6点支払う。支払えない場合、2D6点ダメージを受ける。',
              '放浪の勇者・アルマイルから挨拶代わりの一撃を受ける。1D6点ダメージを受け、アルマイルからの【想い】が1点上昇する。'
            ],
          },

          "KCVT" => {
            name: "ケルト神群試練表",
            type: '1D6',
            table: [
              '怪物が奏でる銀の竪琴の音色が聞こえてきて、しばらくの間、眠ってしまう。眠っている間に、妖精たちに悪戯された。「恥辱」の変調を受け、アイテムを一つ選んで失う。',
              'かつて倒した敵の娘から呪いをかけられてしまい、左腕が麻痺して動かなくなる。このセッションの間、【武勇】のランクが一段階減少する（Dより下にはならない）。',
              'エイネーという女性に、泉の底にある指輪を取ってきて欲しいと頼まれる。泉の底に潜って戻って来ると、自分が加齢してしまっていることに気付く。罠だったのだ。自分の年齢をD66歳増やし、【活力】が0点になる。',
              '悪いドルイド僧から求婚を迫られる。急な話に戸惑っていると、ドルイド僧は怒りだし、PCを鹿に変える呪いをかけた。このセッションの間、【日常】のランクが一段階減少する（Dより下にはならない）。',
              'ウィッカーマンに閉じ込められ、焼かれてしまう。「重傷4」の変調を受ける。',
              '道案内をしてくれた美女にそそのかされて、女人の国にたどりついてしまう。誘惑に耐えながら、なんとか脱出する。「堕落」と「臆病2」の変調を受ける。'
            ],
          },

          "SAT" => {
            name: "店内雰囲気表",
            type: 'D66',
            table: [
              [11, "山の中にある峠の茶屋"],
              [12, "煙草の煙がたゆたうセルフ式コーヒーチェーン店"],
              [13, "山上りの座卓がある和風茶寮"],
              [14, "ロココ調の優美で華やかな雰囲気の高級サロン"],
              [15, "ヴィクトリア調のシックで上品なティーハウス"],
              [16, "古い歌謡曲がかかり、テーブル筐体が懐かしい純喫茶"],
              [22, "若い子で賑わうポップな内装のいかにもなチェーン店"],
              [23, "ミッドセンチュリーの家具がお洒落なカフェ"],
              [24, "ジュークボックスが目立つアメリカンダイナー"],
              [25, "ピアノ曲が静かに流れる落ち着いた喫茶店"],
              [26, "ノマドな若者が目立つコーヒーチェーン店"],
              [33, "かわいい給仕さんがたくさんいるメイドカフェ"],
              [34, "独特の茶器でゆったりお茶を楽しめる中国茶館"],
              [35, "アースカラーが懐かしい健康志向なナチュラルカフェ"],
              [36, "見晴らしのいいカフェテラスが自慢のオープンカフェ"],
              [44, "壁一面にレコードが飾られているジャズ喫茶"],
              [45, "24時間営業で荒れた雰囲気の漫画喫茶"],
              [46, "色々なアナログゲームが楽しめるゲームカフェ"],
              [55, "ショッピングモールのフードコート内にある出店"],
              [56, "ビジネスマンたちが商談にいそしむ談話室"],
              [66, "水タバコを吸いながら会話に興じる中東風カフェ"],
            ],
          },

          "SMT" => {
            name: "特殊メニュー表",
            type: 'D66',
            table: [
              [11, "アド・パトレス（ケルト）"],
              [12, "アムブロシア（ギリシア）"],
              [13, "ネクタル（ギリシア）"],
              [14, "アムリタ（インド）"],
              [15, "ソーマ（インド）"],
              [16, "ヤシオリ（ヤマト）"],
              [22, "変若水／おちみず（ヤマト）"],
              [23, "天舐酒／あまのたむけざけ（ヤマト）"],
              [24, "エリクサー（錬金術）"],
              [25, "ハオマ（ペルシア）"],
              [26, "金丹（中華）"],
              [33, "神農茶（中華）"],
              [34, "チョコラトル（アステカ）"],
              [35, "クヴァシル（北欧）"],
              [36, "ヘイズルーンの乳（北欧）"],
              [44, "ホワイト・ドロップ（エジプト）"],
              [45, "リキッド・ゴールド（エジプト）"],
              [46, "ジヴァヤ・ヴォジャ（スラブ）"],
              [55, "スハルジク（メソポタミア）"],
              [56, "ニンフサグのミルク（メソポタミア）"],
              [66, "黄金の蜂蜜酒（クトゥルフ）"],
            ],
          },

        }.freeze

      setPrefixes(['R[A-DS].*'] + TABLES.keys)
    end
  end
end

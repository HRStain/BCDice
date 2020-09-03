# frozen_string_literal: true

module BCDice
  module GameSystem
    class Insane_Korean < Base
      # ゲームシステムの識別子
      ID = 'Insane:Korean'

      # ゲームシステム名
      NAME = '인세인'

      # ゲームシステム名の読みがな
      SORT_KEY = '国際化:Korean:인세인'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~INFO_MESSAGE_TEXT
        ・판정
        스페셜／펌블／성공／실패를 판정
        ・각종표
        씬표　　　ST
        　사실은 무서운 현대 일본 씬표 HJST／광조의 20년대 씬표 MTST
        　암흑의 빅토리아 씬표 DVST
        수식표　　　　DT
        　본체표 BT／부위표 PT
        감정표　　　　　　FT
        직업표　　　　　　JT
        배드엔딩표　　BET
        랜덤 특기 결정표　RTT
        지정특기(폭력)표　　(TVT)
        지정특기(감정)표　　(TET)
        지정특기(지각)표　　(TPT)
        지정특기(기술)표　　(TST)
        지정특기(지식)표　　(TKT)
        지정특기(괴이)표　　(TMT)
        회화 중에 발생하는 공포표(CHT)
        거리에서 조우하는 공포표(VHT)
        갑자기 찾아오는 공포표(IHT)
        폐허에서 조우하는 공포표(RHT)
        야외에서 조우하는 공포표(MHT)
        정보 속에 숨어 있는 공포표(LHT)
        조우표　도시　(ECT)　산림　(EMT)　해변　(EAT)/반응표　RET
        야근 시 조우하는 공포표　OHT/야근 시 전화표　OPT/야근 씬표　OWT
        회사명 결정표1　CNT1/회사명 결정표2　CNT2/회사명 결정표3　CNT3
        ・D66 다이스 있음.
      INFO_MESSAGE_TEXT

      setPrefixes([
        'ST', 'HJST', 'MTST', 'DVST', 'DT', 'BT', 'PT', 'FT', 'JT', 'BET', 'RTT', 'TVT', 'TET', 'TPT', 'TST', 'TKT', 'TMT',
        'CHT', 'VHT', 'IHT', 'RHT', 'MHT', 'LHT', 'ECT', 'EMT', 'EAT', 'OPT', 'OHT', 'OWT', 'CNT1', 'CNT2', 'CNT3', 'RET'
      ])

      def initialize
        super

        @sort_add_dice = true
        @sort_barabara_dice = true
        @d66Type = 2
      end

      # 게임 별 성공 여부 판정(2D6)
      def check_2D6(total, dice_total, _dice_list, cmp_op, target)
        return '' if target == '?'
        return '' unless cmp_op == :>=

        if dice_total <= 2
          " ＞ 펌블(판정실패。 덱에서 【광기】를 1장 획득)"
        elsif dice_total >= 12
          " ＞ 스페셜(판정성공。 【생명력】 1점이나 【정신력】 1점 회복)"
        elsif total >= target
          " ＞ 성공"
        else
          " ＞ 실패"
        end
      end

      def rollDiceCommand(command)
        output = '1'
        type = ""
        total_n = ""

        case command
        when 'ST'
          type = '씬표'
          output, total_n = get_scene_table
        when 'HJST'
          type = '사실은 무서운 현대 일본 씬표'
          output, total_n = get_horror_scene_table
        when 'MTST'
          type = '광조의 20년대 씬표'
          output, total_n = get_mania_scene_table
        when 'DVST'
          type = '암흑의 빅토리아 씬표'
          output, total_n = get_dark_scene_table
        when 'DT'
          type = '수식표'
          output, total_n = get_description_table
        when 'BT'
          type = '본체표'
          output, total_n = get_body_table
        when 'PT'
          type = '부위표'
          output, total_n = get_parts_table
        when 'FT'
          type = '감정표'
          output, total_n = get_fortunechange_table
        when 'JT'
          type = '직업표'
          output, total_n = get_job_table
        when 'BET'
          type = '배드엔딩표'
          output, total_n = get_badend_table
        when 'RTT'
          type = '랜덤 특기 결정표'
          output, total_n = get_random_skill_table
        when 'TVT'
          type = '지정특기(폭력)표'
          output, total_n = get_violence_skill_table
        when 'TET'
          type = '지정특기(감정)표'
          output, total_n = get_emotion_skill_table
        when 'TPT'
          type = '지정특기(지각)표'
          output, total_n = get_perception_skill_table
        when 'TST'
          type = '지정특기(기술)표'
          output, total_n = get_skill_skill_table
        when 'TKT'
          type = '지정특기(지식)표'
          output, total_n = get_knowledge_skill_table
        when 'TMT'
          type = '지정특기(괴이)표'
          output, total_n = get_mystery_skill_table
        when 'CHT'
          type = '회화 중에 발생하는 공포표'
          output, total_n = get_conversation_horror_table
        when 'VHT'
          type = '거리에서 조우하는 공포표'
          output, total_n = get_ville_horror_table
        when 'IHT'
          type = '갑자기 찾아오는 공포표'
          output, total_n = get_inattendu_horror_table
        when 'RHT'
          type = '폐허에서 조우하는 공포표'
          output, total_n = get_ruines_horror_table
        when 'MHT'
          type = ' 야외에서 조우하는 공포표'
          output, total_n = get_Mlle_horror_table
        when 'LHT'
          type = '정보 속에 숨어 있는 공포표'
          output, total_n = get_latence_horror_table
        when 'ECT'
          type = '조우표・도시'
          output, total_n = get_city_table
        when 'EMT'
          type = '조우표・산림'
          output, total_n = get_mountainforest_table
        when 'EAT'
          type = '조우표・해변'
          output, total_n = get_seaside_table
        when 'OHT'
          type = '야근 시 조우하는 공포표'
          output, total_n = get_overtime_horror_table
        when 'OPT'
          type = '야근 시 전화표'
          output, total_n = get_overtimephone_table
        when 'OWT'
          type = '야근 씬표'
          output, total_n = get_overtimework_scene_table
        when 'CNT1'
          type = '회사명 결정표1'
          output, total_n = get_corporatenameone_table
        when 'CNT2'
          type = '회사명 결정표2'
          output, total_n = get_corporatenametwo_table
        when 'CNT3'
          type = '회사명 결정표3'
          output, total_n = get_corporatenamethree_table
        when 'RET'
          type = '반응표'
          output, total_n = get_reaction_scene_table
        end

        return "#{type}(#{total_n}) ＞ #{output}"
      end

      # 씬표
      def get_scene_table
        table = [
          '피 냄새가 지독히 풍긴다. 사건인가? 사고인가? 혹시, 아직 끝나지 않은 걸까?',
          '이건……꿈인가? 이미 끝났을 일이 기억 속에서 되살아난다.',
          '아래에 펼쳐진 거리를 내려다보고 있다. 왜 이런 높은 곳에……?',
          '종말을 맞은 세계 같은 암흑. 어둠 속, 누군가의 기척이 꿈틀거린다…….',
          '평온한 시간이 지나간다. 마치 그런 일은 없었던 것 같다.',
          '물먹은 흙의 냄새, 농밀한 기척이 흐르는 숲 속, 새나 벌레의 울음소리, 바람에 흔들리는 나무들의 소리가 들려온다.',
          '사람이 다니기엔 좁은 주택가. 모르는 사람들이 사는 집들에서 이런저런 소리들이 새어나와 어렴풋이 들린다…….',
          '갑자기 하늘을 구름이 덮는다. 비가 거세게 쏟아진다. 사람들은 처마를 찾아 허둥지둥 달려간다.',
          '황폐한 폐허, 썩어 사라져가는 생활의 흔적. 희미하게 들려오는 건 바람일까, 파도 소리일까, 이명일까.',
          '수많은 사람들. 시끄러운 소리. 매우 소란스러운 점내 BGM에, 비정상적인 웃음소리. 시끄러운 번화가의 한 곳이지만……?',
          '밝은 빛에 비춰져, 안심하며 한숨. 하지만 빛이 강해지는 만큼, 그림자도 짙어진다.',
        ]

        return get_table_by_2d6(table)
      end

      # 사실은 무서운 현대 일본 씬표
      def get_horror_scene_table
        table = [
          '갑자기 주변이 어두워진다. 정전인가? 어둠 속에서, 누군가가 당신을 부르는 목소리가 들려온다.',
          '똑. 똑. 똑. 어디서일까, 물방울이 떨어지는 것 같은 소리가 들려온다.',
          '창문 앞을 지나갈 때, 무언가 기분 나쁜 것이 비쳤다. 눈의 착각인가……?',
          'TV에서 뉴스 소리가 들려온다. 아무래도 근처에서 뒤숭숭한 사건이 일어난 것 같은데…….',
          '어두운 길을 혼자 걷고 있다. 뒤로 기분 나쁜 발소리가 다가오는 것 같은 기분이 드는데…….',
          '누굴까? 계속 시선이 느껴진다. 뒤를 돌아봐도 거기에 있는 것은 평소와 같은 광경인데…….',
          '갑자기 핸드폰 벨소리가 울려 퍼진다. 매너모드로 해둔 것 같은데……. 대체, 누구한테 온 것일까?',
          '빨간 빛을 비치는 석양. 태양은 가라앉고 하늘은 핏빛처럼 새빨갛다. 불안한 기분이 번져간다…….',
          '맛있을 것 같은 냄새가 풍겨와, 갑자기 공복감이 느껴진다. 오늘은 뭘 먹을까?',
          '새된 울음소리가 울려 퍼진다. 갑자기 공복감이 느껴진다. 오늘은 뭘 먹을까?',
          '잠을 이루지 못하고 눈을 뜬다. 뭔가 악몽을 꾼 것 같은데……. 어라, 의식은 있는데 몸이 움직이지 않아!',
        ]

        return get_table_by_2d6(table)
      end

      # 광조의 20년대 씬표
      def get_mania_scene_table
        table = [
          '이끼가 달라붙은 거대한 바위가 늘어선, 강에 떠오른 섬. 무엇을 모시고 있는지도 알 수 없는 제단이 있고, 이루 말하기 힘든 분위기가 떠오른다.',
          '무허가 술집. 가판도 없는 지하의 가게는, 거리의 남자나 호스티스들로 떠들썩하다.',
          '유적 안. 누가 세웠는지도 모르는, 비 유클리드 기하학적인 건축은, 안을 걷는 자의 정신을 서서히 좀먹어간다.',
          '대학도서관. 사십만을 넘는 장서 속에는, 모독적인 마도서도 있다고 한다.',
          '강한 바람을 다고, 어디선가 바다의 냄새가 풍겨온다. 바다는 멀리 있을텐데…….',
          '수많은 사람들로 붐비는 길목. 여기라면 누가 섞여있어도 알아챌 수 없을 것이다.',
          '깊은 어둠 속, 그 너머에는 말로 표현할 수 없는 무언가가 숨어있는 듯 하다.',
          '역사 있는 신문사. 휴간 한 번 없이 발행한 백년분에 달하는 신문이 보관되어있다.',
          '오래된 묘지. 비틀어진 나무들 사이에 낡아서 묘비명도 읽을 수 없는 비석이 서있다. 몇 개인가의 비석은 왜인지 기울어져있다.',
          '강가의 공장 터. 아주 오래 전부터 쓰지 않은 듯, 건물은 무너져가고 있다. 아무래도 부랑자들이 거처로 쓰고 있는 듯하다.',
          '조용한 실내. 무언가 불온한 기색이 느껴지지만……저건 뭐지? 창문에, 창문에!',
        ]

        return get_table_by_2d6(table)
      end

      # 암흑의 빅토리아 씬표
      def get_dark_scene_table
        table = [
          '영매사를 중심으로 원탁을 에워싼 사람들이, 강령회를 하고 있다. 어둑한 방 안에 수상쩍은 엑토플라즘이 흐르기 시작한다.',
          '노동자들이 모이는 펍. 여급이 나르는 에일이나 진을, 붉은 얼굴의 남자들이 들이킨다.',
          '피 냄새가 풍기는 곳. 여기서 무슨 일이 있었던 것 일까…….',
          '사창가가 늘어선 빈민가. 건물 앞에는 창부들이 손님을 기다리고 있다.',
          '사람들로 붐비는 떠들썩한 거리. 다양한 소문이 떠돌고 있다. 동양인을 비롯한 외국인의 모습도 보인다.',
          '안개가 짙은 길목. 가스등의 빛만이 돌로 포장된 길을 비추어 드러내고 있다.',
          '아주 조용한 방 안. 여기라면 뭘 해도 쓸데없는 방해는 받지 않겠지.',
          '기적 소리가 울리는 부두. 저 배는 외국으로 여행을 떠나는 걸까.',
          '책이 넘쳐나는 곳. 뭔가를 조사하기에는 안성맞춤이지만.',
          '귀족이나 자산가들이 모인 파티. 품위 있는 미소 아래에서는 어떤 흉계를 꾸미고 있는 걸까.',
          '조용한 호수 부근 풀숲에서는 야생의 토끼가 뛰어다니고 있다.',
        ]
        return get_table_by_2d6(table)
      end

      # 수식표
      def get_description_table
        table = [
          [11, '핼쑥한'],
          [12, '피를 흘리는'],
          [13, '비늘 모양의'],
          [14, '모독적인'],
          [15, '원통형의'],
          [16, '비정상적으로 증식하는'],
          [22, '불규칙적인'],
          [23, '꽥꽥 우는'],
          [24, '무수한'],
          [25, '털이 많은'],
          [26, '색채 없는'],
          [33, '신축하는'],
          [34, '외설적인'],
          [35, '부풀어 오른'],
          [36, '거대한'],
          [44, '점액 투성이의'],
          [45, '끊임없이 변화하는'],
          [46, '벌레 투성이의'],
          [55, '키틴질의'],
          [56, '「본체표를 사용」 같은'],
          [66, '무지개 빛으로 빛나는'],
        ]

        return get_table_by_d66_swap(table)
      end

      # 본체표
      def get_body_table
        table = [
          [11, '인간'],
          [12, '개'],
          [13, '쥐'],
          [14, '망령'],
          [15, '민달팽이'],
          [16, '벌레'],
          [22, '얼굴'],
          [23, '고양이'],
          [24, '지렁이'],
          [25, '소'],
          [26, '새'],
          [33, '반어인'],
          [34, '인조인간'],
          [35, '뱀'],
          [36, '노인'],
          [44, '아메바'],
          [45, '여성'],
          [46, '기계'],
          [55, '문어'],
          [56, '「부위표」를 사용'],
          [66, '소인'],
        ]

        return get_table_by_d66_swap(table)
      end

      # 부위표
      def get_parts_table
        table = [
          [11, '몸통'],
          [12, '발'],
          [13, '팔뚝'],
          [14, '머리털/갈기'],
          [15, '입'],
          [16, '유방'],
          [22, '얼굴'],
          [23, '피부'],
          [24, '눈'],
          [25, '꼬리'],
          [26, '촉수'],
          [33, '코'],
          [34, '그림자'],
          [35, '이빨'],
          [36, '뼈'],
          [44, '보석'],
          [45, '날개'],
          [46, '뇌수'],
          [55, '혀'],
          [56, '가지나 잎'],
          [66, '내장'],
        ]

        return get_table_by_d66_swap(table)
      end

      # 감정표
      def get_fortunechange_table
        table = [
          '공감（플러스）／불신（마이너스）',
          '우정（플러스）／분노（마이너스）',
          '애정（플러스）／시기（마이너스）',
          '충성（플러스）／모멸（마이너스）',
          '동정（플러스）／열등감（마이너스）',
          '광신（플러스）／살의（마이너스）',
        ]

        return get_table_by_1d6(table)
      end

      # 직업표
      def get_job_table
        table = [
          [11, '고고학자≪정경≫≪고고학≫'],
          [12, '갱(Gang)≪고문≫≪분노≫'],
          [13, '탐정≪육감≫≪수학≫'],
          [14, '경찰≪사격≫≪추적≫'],
          [15, '호사가≪예술≫≪인류학≫'],
          [16, '의사≪절단≫≪의학≫'],
          [22, '교수　지식분야에서 원하는 것을 2개'],
          [23, '성직자≪부끄러움≫≪사랑≫'],
          [24, '심리학자 감정분야에서 원하는 것을 2개'],
          [25, '학생　지식분야와 감정분야에서 원하는 것을 하나씩'],
          [26, '기자≪놀람≫≪미디어≫'],
          [33, '기술자≪전자기기≫≪기계≫'],
          [34, '도둑≪그늘≫≪함정≫'],
          [35, '예능인≪기쁨≫≪예술≫'],
          [36, '작가≪근심≫≪교양≫'],
          [44, '모험가≪구타≫≪탈것≫'],
          [45, '사서≪정리≫≪미디어≫'],
          [46, '요리사≪소각≫≪맛≫'],
          [55, '비즈니스맨≪참음≫≪효율≫'],
          [56, '호스트or호스티스≪웃음≫≪관능≫'],
          [66, '경호원　폭략분야에서 원하는 것을 2개'],
        ]

        return get_table_by_d66_swap(table)
      end

      # 배드엔딩표
      def get_badend_table
        table = [
          '당신 주위에 칠흑의 어둠이, 이형의 앞다리가, 무수한 촉수가 모여든다. 새로운 동료를 축복하고 있는 것이다. 당신은 이제 괴이를 무서워하지 않는다. 왜냐하면, 당신 자신이 괴이가 되었기 떄문이다. 이후, 당신은 괴이 NPC로서 등장한다',
          lambda { return "감옥과도 같은, 수술실 같은 어둑한 방에 감금당했다. 그리고, 매일같이고문을 받게 되었다. 어떻게든 도망칠 수는 있었지만…….  #{get_random_skill_table_text_only}의 특기가 【공포심】이 된다." },
          '아슬아슬한 순간, 수수께끼의 조직의 에이전트에게 구해진다. 「당신, 장래성이 있군. 어떤가? 우리들과 함께 하지 않겠나?」\n 당신은 원한다면, 닌자／마법사／헌터로서 괴이와 싸워나가는 것이 가능하다. 그 경우, 당신은 다른 사이코로 픽션의 캐릭터로 다시 태어난다.',
          '병원 침대에서 눈을 뜬다. 오랫동안, 무서운 악몽을 꾼 것 같은 기분이 든다. 그 세션의 후유증 판정은, 마이너스 1의 수정이 붙고, 펌블 수치가 1 상승한다.',
          '어딘가의 민가에서 눈을 뜬다. 근사한 사람에게 구해져서, 극진한 간호를 받은 듯 하다. 딱히 페널티는 없다.',
          '「위험해！」\n 거대한 절망이 당신을 덮쳐온다. 1D6 마이너스 1점의 데미지를 입는다. 이에 의해 【생명력】이 0점이 된 경우, 당신은 사망한다. 단, 당신에게 플러스의 【감정】을 가진 NPC가 있을 경우, 그 NPC가 그 데미지를 무효화해준다.',
          '다른 새로운 괴사건에 휘말린다. 고생은 끝, 그쪽은 어떻게든 무사해결! 딱히 패널티는 없다.',
          '커다란 상처를 입고, 생사의 경계를 헤맨다. 원하는 특기로 판정을 시행하라. 실패하면 사망한다. 【생명력】만큼 마이너스의 수정이 붙는다.',
          '눈을 뜨면 익숙하지 않은 장소다. 여긴 어디지? 나는 누구? 아무래도 지나친 공포로 기억을 잃어버린 것 같다. 공적점이 있다면, 그것을 1점 잃는다.',
          lambda { return "눈을 뜨니, 그곳은 평소의 그곳이었다. 하지만, 어딘가 위화감을 느낀다. 당신들 외에, 누구도 사건에 대해서는 모르는 것 같다. 죽었을 터인 그 인물도 살아있다. 시간을 여행한 것일까, 여긴 다른 세계선인가……? 　#{get_random_skill_table_text_only}의 특기가 【공포심】이 된다." },
          '뒤를 돌아보자, 거기에는 압도적인 「그것」이 기다리고 있었다. 무자비한 일격이 당신을 덮치고, 당신은 사망한다.',
        ]
        return get_table_by_2d6(table)
      end

      # 랜덤 특기 결정표
      def get_random_skill_table
        skillTableFull = [
          ['폭력', ['소각', '고문', '긴박', '위협하기', '파괴', '구타', '절단', '찌르기', '사격', '전쟁', '매장']],
          ['감정', ['연정', '기쁨', '근심', '부끄러움', '웃음', '참음', '놀람', '분노', '원한', '슬픔', '사랑']],
          ['지각', ['아픔', '관능', '감촉', '향기', '맛', '소리', '정경', '추적', '예술', '육감', '그늘']],
          ['기술', ['분해', '전자기기', '정리', '약품', '효율', '미디어', '카메라', '탈것', '기계', '함정', '병기']],
          ['지식', ['물리학', '수학', '화학', '생물학', '의학', '교양', '인류학', '역사', '민속학', '고고학', '천문학']],
          ['괴이', ['시간', '혼돈', '심해', '죽음', '영혼', '마술', '암흑', '종말', '꿈', '지저', '우주']],
        ]

        skillTable, total_n = get_table_by_1d6(skillTableFull)
        tableName, skillTable = *skillTable
        skill, total_n2 = get_table_by_2d6(skillTable)
        return "「#{tableName}」≪#{skill}≫", "#{total_n},#{total_n2}"
      end

      # 특기만 뽑고싶을 때 사용. 별로 예쁘진 않다.
      def get_random_skill_table_text_only
        text, = get_random_skill_table
        return text
      end

      # 지정특기 랜덤결정(폭력)
      def get_violence_skill_table
        table = [
          '소각',
          '고문',
          '긴박',
          '위협하기',
          '파괴',
          '구타',
          '절단',
          '찌르기',
          '사격',
          '전쟁',
          '매장',
        ]
        return get_table_by_2d6(table)
      end

      # 지정특기 랜덤결정(감정)
      def get_emotion_skill_table
        table = [
          '연정',
          '기쁨',
          '근심',
          '부끄러움',
          '웃음',
          '참음',
          '놀람',
          '분노',
          '원한',
          '슬픔',
          '사랑',
        ]
        return get_table_by_2d6(table)
      end

      # 지정특기 랜덤결정(지식)
      def get_perception_skill_table
        table = [
          '아픔',
          '관능',
          '감촉',
          '향기',
          '맛',
          '소리',
          '정경',
          '추적',
          '예술',
          '육감',
          '그늘',
        ]
        return get_table_by_2d6(table)
      end

      # 지정특기 랜덤결정(기술)
      def get_skill_skill_table
        table = [
          '분해',
          '전자기기',
          '정리',
          '약품',
          '효율',
          '미디어',
          '카메라',
          '탈것',
          '기계',
          '함정',
          '병기',
        ]
        return get_table_by_2d6(table)
      end

      # 지정특기 랜덤결정(지식)
      def get_knowledge_skill_table
        table = [
          '물리학',
          '수학',
          '화학',
          '생물학',
          '의학',
          '교양',
          '인류학',
          '역사',
          '민속학',
          '고고학',
          '천문학',
        ]
        return get_table_by_2d6(table)
      end

      # 지정특기 랜덤결정(괴이)
      def get_mystery_skill_table
        table = [
          '시간',
          '혼돈',
          '심해',
          '죽음',
          '영혼',
          '마술',
          '암흑',
          '종말',
          '꿈',
          '지저',
          '우주',
        ]
        return get_table_by_2d6(table)
      end

      # 회화 중에 발생하는 공포표
      def get_conversation_horror_table
        table = [
          "지정특기：죽음\n한창 대화중에, 당신은 문득, 상대의 어깨 너머로 시선을 향한다. 갑자기, 먼 건물의 옥상에서 여자가 뛰어내렸다. 소리 지를 틈도 없이, 그녀는 빨려 들어가듯 지면으로 내동댕이쳐진다. 거리가 있음에도 불구하고, 그녀와 눈이 마주치고 말았다. –-그 이후, 그녀의 얼굴이 뇌리에 박혀, 사라지지 않는다…….",
          "지정특기：구타\n땅바닥에 드러누운 상대를 보면서, 당신은 등줄기에 식은땀이 나는 것을 느꼈다. 상대는 쓰러진 채, 부자연스럽게 신체를 비틀며 꼼짝도 하지 않는다. 천천히 피 웅덩이가 커져간다……. –죽여버리고 말았다. 동요하며 눈을 깜빡였을 때, 상대의 신체가 사라졌다. 피 웅덩이도 보이지 않는다. 당신은 망연히 멈춰 서있다. 환각이었던걸까……?",
          "지정특기：전자기기\n당신이 전화로 상대와 이야기하고 있으면, 난데없이 상대가 입을다물어버린다. 「……저게 뭐지?」\n 상대는 혼잣말하듯 중얼거리더니, 당황한 듯 소리를 지른다. 「이리로 온다…… 이리로 온다! 우왓! 우와아아앗! 살려줘! 살려줘!!」\n 그것을 마지막으로 전화가 뚝하고 끊어진다. 다시 걸어보면 통화중이다. 계속.",
          "지정특기：소리\n당신이 전화로 상대와 이야기하고 있으면, 낮은 소리로 중얼거리는 목소리가 들려온다. 혼선인걸까? 이상하게 생각하며 듣고 있는 동안, 머리가 멍해져 온다. 중얼중얼, 중얼중얼, 중얼중얼, 중얼중얼……. 정신을 차리면, 전화기를 든 챌 멍- 하니 서 있다. 통화는 끊어져 있다. 무슨 이야기를 하고 있었는지 기억나지 않는다. 다만, 굉장히 무서운 것을 들은 듯한 기분이 든다. 대체, 당신은 누구와 이야기하고 있었던걸까?",
          "지정특기：고문\n대화 도중, 피 맛이 났다. 동시에 갈그랑거리는 위화감을 느꼈다. 상대가 새파랗게 질려서 당신의 얼굴을 가리킨다. 어찌된 일인지 물어보려 입을 열자, 뚝하고 무언가가 땅바닥으로 떨어졌다. 내려다보면, 피 웅덩이 속에 새하얗게 당신의 이빨이 한 개 떨어져 있다.",
          "지정특기：인류학\n대화 도중, 시야에 위화감을 느낀 당신은 눈을 깜빡였다. 상대의 얼굴이, 이상하게 되어 있었다. 잡아 늘여서, 휘저은 것처럼, 그로테스크하게 일그러져 있다. 엣? 하고 자세히 보지만 일그러짐은 변함없다. 상대는 전혀 눈치채지 못한 듯하다. 눈을 질끈 감았다가 다시 보자, 겨우 일그러짐이 사라졌다. 당신은 마음에 한가지 의심이 생겨난다. 눈 앞에 있는 상대는, 정말로 인간인걸까?",
        ]
        return get_table_by_1d6(table)
      end

      # 거리에서 조우하는 공포표
      def get_ville_horror_table
        table = [
          "지정특기：탈것\n끼이익--!! 거친 브레이크 소리, 그리고 둔탁한 소리. 깜짝 놀라 뒤를 돌아보자, 멈춰진 차와, 그 앞에 쓰러져있는 사람이 눈에 들어왔다. 교통사고다! 황급히 뛰어가서, 피해자의 얼굴을 본 순간, 당신은 그대로 얼어붙었다. 쓰러져 있는 사람은, 당신이었다. --엣?! 깜짝 놀라 눈을 깜빡이면, 길 위의 당신도, 차도, 사라졌다.",
          "지정특기：정경\n지나가는 집의 지붕에 누군가 서있다. 그나저나 당신 뭘……? 그 누군가는, 춤을 추고 있는 듯이 보였다. 손발을 휘저으며, 머리를 거세게 움직이며 춤추고 있다. 평범한 모습은 아니다. 미친 것처럼 춤추고 있다. 보고 있는 동안에 불길한 기분이 들었다. 보고싶지 않은데, 어째서인지, 눈을 돌릴 수 없다. 불길한 예감이 점점 커져간다…….",
          "지정특기：종말\n애애애애애애애애애앵……. 거리에 사이렌이 울려 퍼진다. 어디서 울리고 있는 걸까, 언제까지 울리는 걸까. 이렇게 커다란 소리인데도, 어째서 아무도 동요하지 않는 걸까. 이상한 마음에 걷고 있으면, 길 건너편에서 걸어오는 사람 그림자가 있다. 상처를 입었는지, 비틀거리며, 지금 당장이라도 쓰러질 것처럼, 힘없이, 힘없이 부자연스런 걸음걸이로 가까이 다가온다. 저건 대체……?",
          "지정특기：위협하기\n걷고 있으려니, 갑자기 조용해진다. 주변을 둘러보면, 사람도, 차도, 아무도 없다. 아무도 없는 거리가 어디까지고 펼쳐져 있다. 방금까지 사람이 굉장히 많이 있었는데……?\n 「이봐! 뭐 하고 있는거야!」\n 갑자기 호통치는 소리에 가슴이 덜컥한다. 뒤돌아보니, 작업복을 입은 남자가 이리로 걸어오고 있었다. 「멍청한 녀석! 이런델 왔다간--」\n 끝까지 듣기도 전에, 갑자기 소리가 돌아왔다. 사람과 차가 지나다니는, 원래의 거리다. 방금은 뭐였을까……?",
          "지정특기：혼돈\n전봇대 밑에 여성이 웅크리고 있다. 배를 부여잡고, 괴로운 듯 얼굴을 숙이고 있다. 「괜찮으세요?」\n 다가가서 말을 건 당신에게, 여성은 고개를 끄덕였다. 「네—감사합니다。」\n 그렇게 말하며 고개를 든 여성의 얼굴은, 아무것도 없었다. 반들반들하게 벗겨진 달걀 같은 피부가 계속되고 있을 뿐이었다. 우왓!?\n 뒤로 몸을 젖힌 순간, 의식이 멀어졌고, 정신을 차려보니 당신은 전봇대 밑에 웅크리고 있었다.",
          "지정특기：웃음\n역에 도착하니, 몹시 혼잡했다. 인신사고로 전차가 멈춰있는 듯하다. 재수 없으려니. 그렇게 생각하고 있으면, 개찰구 근처의 인파 속에서, 일본 옷을 입은 여성이 빠른 걸음으로 당신 쪽으로 다가왔다. 여성은 만면에 미소를 짓고 있었다. 혼잣말을 중얼거리는지, 입이 움직이고 있다. 스쳐지나갈 때에, 여성의 목소리가 귀에 들렸다. 「해버렸다. 해버렸다. 해버렸다. 꼴좋네。」\n 엣, 하며 돌아보는 당신을 남겨두고, 여성은 인파 속으로 사라져버렸다.",
        ]

        return get_table_by_1d6(table)
      end

      # 갑자기 찾아오는 공포표.
      def get_inattendu_horror_table
        table = [
          "지정특기：놀람\n쿵쾅쿵쾅쿵쾅! 갑작스런 소리에, 당신은 깜짝 놀라 고개를 들고 올려다본다. 지붕 밑에 무언가가 돌아다니고 있는 것 같다. 동물이 들어온 걸까? 그렇다고 쳐도 커다란 소리다. --마치, 어린아이가 이리저리 뛰어 돌아다니는 듯한. 한 순간 소리가 멈췄다가, 이내 다시 들린다. 쿵! 쿵! 쿵! 쿵! 펄떡펄떡 뛰어오르는 듯한 소리가 나는 곳은, 정확히 당신의 바로 위였다…….",
          "지정특기：우주\n창문으로 빛이 들어온다. 하늘로 눈을 돌려 바라보면, 하얗고 빛나는 거대한 비행물체가 떠있다. 홀린 듯 쳐다보고 있으면, 새나 비행기라고 생각할 수 없는, 불규칙한 움직임으로 날아다니기 시작한다. 뭐야 저건? 이상하게 생각하고 있으면, 등 뒤에서 누군가가 속삭인다. 「저건……야」\n 핫 하고 눈치채면, 어느샌가, 전혀 다른 장소에 있다. 손 안에 무언가 쥐여있는 듯한 딱딱한 감촉이 있다…….",
          "지정특기：냄새\n기묘한 화물이 도착했다. 검테이프로 꽁꽁 싸매진 커다란 골판지다. 발신인 이름을 적어둔 종이가 붙어있지만 번져있어 읽을 수 없다. 상자의 내용물은 흙이었다. 사금파리나 돌맹이가 섞인, 이상한 냄새를 풍기는 흙이 들어 있었다. 이유를 알 수 없어서 내용물은 버렸지만, 그 이후 왠지 운이 나빠진듯한 기분이 든다…….",
          "지정특기：참음\n벽 너머에서 누군가 이야기하는 소리가 들려온다. 「……니까, 이 녀석은……하지 않으면。」\n 「그렇네……하군……지 않으면。」\n 수군수군, 수군수군하고, 음침한 어조로 대화는 계속된다. 무엇을 이야기하고 있는지, 내용은 잘 모르겠지만, 어쩐지 자신의 이야기를 하고 있는 듯해서 왠지 기분이 나쁘다. 신경쓰여서 벽에 귀를 대었을 때, 확실한 목소리가 벽 너머에서 이렇게 말했다. 「……얘, 제대로 듣고 있어?」",
          "지정특기：감촉\n똑. 똑. 목덜미에 떨어진 미지근한 물방울의 감촉에 당신은 눈썹을 찌푸렸다. 눈치채고 나면, 책상 위에 빨간 물방울이 떨어져 있다. 쇳내가 코를 찌른다. 똑. 똑. 똑. 물방울은 세를 늘려, 자꾸 자꾸 떨어져내려, 책상 위로 퍼져나간다. 천천히 올려다보면, 천장에는 커다랗고 검붉은 얼룩이 넓게 퍼져있다. 똑. 토독. 똑. --토도도도독! 높아진 물소리에 당신은 우뚝 멈춰 선다. 지붕 밑에, 대체, 뭐가……?",
          "지정특기：지저\n낯익은 장소에서, 낯선 문을 발견했다. 열어보면, 긴 내리막계단이 어둠 속으로 뻗어 있다. 수상쩍게 생각해서 아래로 내려가보니…… 그 곳은 지하실이었다. 이런 장소가 있었던가.  한 손에 불빛을 들고 나아가보면 무언가 다가오는 기분이 든다. 어둠 속에서, 누군가가, 당신의 이름을 불렀다.",
        ]

        return get_table_by_1d6(table)
      end

      # 폐허에서 조우하는 공포표
      def get_ruines_horror_table
        table = [
          "지정특기：암흑\n무겁고 튼튼해 보이는 문을 연다. 방 안은 새까맸다. 등불로 비춰보니, 다른 방으로 이어지는 길이 몇 갈래 발견되었다. 달리 눈에 띄는 것은 없는 듯 하다. 일단, 입구로 되돌아가려고, 들어왔던 문 쪽으로 돌아선다. 그 곳에는 벽 밖에 없었다. 그 중후한 문이 사라져있다. 그런 말도 안 되는 일이. 그러나, 몇 번이고 찾아봐도 어떤 벽에도 문 같은 것은 보이지 않는다. 할 수 없이, 통로를 나아가기로 했지만, 조금씩 불길한 기분이 엄습해 온다. ……그 문은, 열어서는 안됐던 것 아닐까?",
          "지정특기：정리\n당신은 폐허 속에서 부웅…… 하는 낮은 소리를 눈치챘다. 냉장고다. 어디서 전기가 들어오고 잇는지, 하얀 냉장고가 폐허의 한 쪽 구석에 조용히 서 있었다. 찰카닥 하고 문을 잡아당겨 열어본 당신은, 안에 있던 무언가와 눈이 마주쳤다. ……정신을 차리니, 당신은 어둡고 차가운 곳에 몸을 웅크리고 있다. 부웅……하는 소리가 들려온다. 이곳은 서늘하고 좁아서--굉장히 편안하다.",
          "지정특기：추적\n폐옥의 미닫이문을 열었을 때, 당신은 강한 위화감을 느꼈다. 먼지가 두껍게 쌓인 그 방에는, 묵직한 분위기가 감돌았다. 밥상 위에는 내용물이 남은 찻잔, 방금 전까지 누군가가 앉아있던 걸로 보이는 움푹 패인 방석. 어째서 이 거실에는, 이리도 생활감이 남아있는 걸까?",
          "지정특기：사랑\n폐허를 걷고 있자니, 돌연, 당신의 휴대폰으로 전화가 걸려왔다. 쥐죽은 듯 고요한 폐허에 울려 퍼지는 착신음에 몹시 놀라면서도 받아보면 전화기 저편에서, 당신의 할머니가 갑자기 꾸짖는다. 「얘야, 뭐 하는 거니! 그런데는 가면 안되잖니!」\n 엣, 어째서 할머니가……?\n 「빨리 거기서 나오렴! 그러다 큰일 난다!」\n 영문도 알 수 없는 채로 우물쭈물 거리고 있는 동안, 전화는 끊어졌다. 화면에는 「권외」라고 표시되어 있었다.",
          "지정특기：함정\n폐허를 걷고 있으니, 갑자기 발에 극심한 통증이 일었다. 비명을 억누르며 아래를 보니, 발목에 덫이 꽉 물려있다. 어째서 이런 곳에, 이런 덫이……? 고생해서 덫을 해제하고, 다시 주변을 둘러보았을 때, 당신은 깜짝 놀란다. 덫은 하나가 아니었다. 잔해 속에 숨겨놓은 것처럼, 몇 개고, 몇 개고, 덫이 설치되어 있었다.",
          "지정특기：약품\n갑자기, 신나 냄새가 코를 찔렀다. 폐허의 벽에 끈적끈적하게, 붉은 페인트로 문자가 쓰여있다. 무엇이 쓰여있는지는 분명하지 않지만, 오로지 악의와 증오만을 칠해 넣은 듯한 터치에 두려움이 생긴다. 그러던 도중 어떤 사실을 눈치채고, 당신은 바짝 소름이 돋았다. 페인트가 아직 마르지 않았다. ……갓 칠한 것처럼 새로운 것이다.",
        ]

        return get_table_by_1d6(table)
      end

      # 야외에서 조우하는 공포표
      def get_Mlle_horror_table
        table = [
          "지정특기：아픔\n부우우우우우웅. 귓가에 새된 날개소리가 울려 퍼진다. 본 적 없는 새빨간 날벌레 무리가 날고 있었다. 부우우우우우웅. 날벌레를 쫓아내려고, 팔을 휘두른다. 아얏. 팔에 찌르는 듯한 통증이 일었다. 부우우우우우웅. 벌레들은, 어디론가로 가버린다. 순간 팔의 표면에 이상한 수포가 돋아나기 시작했다.",
          "지정특기：꿈\n나무들 사이에, 무언가 커다란 것이 움직이고 있는 것이 보인다. 고기 썩는 듯한 냄새가 물씬 코를 찌른다. 얼룩덜룩한 무늬는…… 모피? 그게 아니면, 갈기갈기 찢어진 옷 조각? 그 녀석이 당신을 봤다. 나뭇잎 사이로 들여다보는 눈은, 마치 사람 같은—눈이 마주친 순간부터 기억이 없다. 정신이 들면, 머리카락을 닮은 검은 털이, 당신의 전신에 붙어있다.",
          "지정특기：원한\n숲 속에서 맞닥뜨린 거대한 나무의 줄기에는 수많은 짚인형이 못으로 고정되어 있었다. 우와아, 라고 생각하며 올려다보던 중, 기분 나쁜 사실을 눈치채고 말았다. 새 짚인형 중 하나에, 이름이 쓰여진 팻말이 붙어있다. --굉장히, 눈에 익은 이름이었다.",
          "지정특기：심해\n……이봐 ……이봐아. 멀리서 부르는 소리를 들은 기분이 들어, 물결 사이를 응시한다. 반들반들한 검은 그림자가 떠올랐다 가라앉았다 하며, 당신을 부르고 있다.",
          "지정특기：그늘\n덤불 속에 폐차가 파묻혀있다. 특징 없는 하얀 밴이다. 창문은 새카맣게 그을음이 묻어있어, 아무것도 보이지 않는다. 차체는 녹이 슬고, 도료도 벗겨져서, 방치되어버린 오래된 폐차임이 확실하다. —-그런데도, 폐차 속에서 날카로운 시선이 느껴진다. 잠금이 풀리는 소리가 나고, 천천히 뒷좌석의 문이 열리기 시작한다…….",
          "지정특기：소각\n타닥……타닥……. 불이 타오르는 소리가 들린다. 공터에 모닥불이 불꽃을 튀기고 있었다. 곁에는 아무도 없다 따듯해진 기분으로 멈춰 서서, 나뭇가지로 모닥불을 휘젓고 있으니, 불 속에서 가벼운 웃음소리가 들렸다. 흠칫 놀란 당신의 발 밑을, 고양이처럼 커다란 무언가가 스르륵 빠져나갔다. 모닥불로 눈을 돌리면, 그 곳에는 단지 그을은 뼛조각만 남아있었다.",
        ]

        return get_table_by_1d6(table)
      end

      # 정보 속에 숨어 있는 공포표.
      def get_latence_horror_table
        table = [
          "지정특기：맛\n목이 마른 것을 깨달았다. 조사를 시작하고 나서, 시간이 상당히 많이 흘렀다. 아무래도 너무 깊이 몰두하고 있었던 듯하다. 화면에 눈을 돌리면서, 페트병의 물을 입에 머금는다. 그러자, 입 속에 위화감이 퍼졌다. 참지 못하고 물을 토해낸다. 그러자, 새까만 액체가 책상 위의 자료를 더럽혔다. 입 속에는, 구정물 같은 냄새가 떠나지 않는다. 확인해본 페트병의 물은 투명했는데……?",
          "지정특기：카메라\n자료 사이에서, 노란 봉투에 들어있는 사진 묶음이 나왔다. 피사체는……당신이다. 모르는 사이에 찍힌, 상신의 사진이 몇 십장이나 묶여있다. 빛 바랜 사진을 아무렇게나 묶어놓은 고무줄은 낡아서, 끈적거렸다. --누가, 이런 사진을? 무엇 때문에……?",
          "지정특기：미디어\n텔레비전의 뉴스를 보고 있으면, 그때까지 막힘없이 재잘거리고 있던아나운서가, 갑자기 입을 다문다. 어쩌려는거야, 라고 생각하고 있으니, 아나운서가 기묘한 것을 말하기 시작했다. 「죽을 수도 있습니다. 라고 말했습니다. 또한, 높은 확률로, 재앙이 발생합니다. 오늘부터 내일까지, 엄중히 경계하세요. 엄중히 경계하세요. 엄중히 경계하세요」\n 아나운서는, 화면 저 편에서 당신의 눈을 지그시 응시하고 있다. 당신이 당황해 하고 있으면, 텔레비전의 전원이 스스로 꺼진다.",
          "지정특기：민속학\n자료를 찾던 와중, 어느 한촌에 전해지는 역겨운 풍습에 다다랐다. 폭력……의식……제물……도저히 정상적인 인간이 한 짓이라고 생각할 수 없는 소행에 치가 떨린다. 그 풍습에는, 어째선지 기시감이 있다. 어디서 읽었더라? 생각하던 도중, 어떤 기억이 되살아났다. 당신이 어릴 적의 기억이었다. 아냐……그런, 말도 안되는, 당신의 고향이, 이런 한촌일리 없어…….",
          "지정특기：마술\n자료 속에서, 기묘한 고서가 나왔다. 가죽 장정의 호화로운 책으로, 묘한 냄새가 난다. 문장은 지리멸렬해서, 정상적인 인간이 썼다고 생각되지 않는다. 그러나, 찢어진 듯한 페이지를 한 장 한 장 넘기고 있으려니, 차츰차츰 작자가 말하려는 바를 알게 된다. 계속, 계속해서 알게 된다. 아아, 이제 알았다. 완전히 알았다. 이제 괜찮다. 분명 이 책은, 당신에게 읽혀지기 위해 쓰여졌던 것이다..",
          "지정특기：역사\n표지가 없는 보고서를 발견했다. 팔락팔락 넘겨보면, 지금 막 당신이 조사하고 있는 사건에 대한 조사보고서였다. 안타깝게도, 여기저기 먹칠이 되어있어, 가장 중요한 부분은 알 수 없다. 보아하니, 아무래도, 군에 의한 조사인 듯하다. 군? 어째서 군대가 이 사건을 조사하고 있었던 거지?",
        ]

        return get_table_by_1d6(table)
      end

      # 조우표・도시
      def get_city_table
        table = [
          "실패작×3　기본ｐ246",
          "노려보는 사람×1　데드 루프ｐ190　개×1　기본ｐ243",
          "신봉자×2　기본ｐ243",
          "얼굴을 가린 여자×1　데드 루프ｐ192",
          "유령 자동차×1　데드 루프ｐ193",
          "원령×1　기본ｐ245",
        ]

        return get_table_by_1d6(table)
      end

      # 조우표・산림
      def get_mountainforest_table
        table = [
          "놋페라보×3　데드 루프ｐ190",
          "독충 무리×2　데드 루프ｐ191",
          "곰×1　데드 루프ｐ191",
          "거대 곤충×1　데드 루프ｐ192",
          "늑대 인간×1　기본ｐ265",
          "쿠네쿠네×1　데드 루프ｐ193",
        ]

        return get_table_by_1d6(table)
      end

      # 조우표・해변
      def get_seaside_table
        table = [
          "도깨비불×3　데드 루프ｐ190",
          "깊은 곳의 존재×2　기본ｐ261",
          "별을 건너는 자×1　기본ｐ261",
          "우주인×1　기본ｐ257",
          "마녀×1　기본ｐ245",
          "기어 다니는 자×1　기본ｐ261",
        ]

        return get_table_by_1d6(table)
      end

      # 야근 시 조우하는 공포표
      def get_overtime_horror_table
        table = [
          "지정특기：죽음\n창문에 눈을 돌렸을 때, 창 밖을 떨어지는 그림자와 눈이 마주쳤다! 황급히 창가에 달려가지만, 아래에는 아무것도 없다. 환각이었던 것일까……?",
          "지정특기：기계\n갑자기 복사기가 윙윙거리며 종이를 쏟아 내기 시작했다. 바닥에 흩날리는 복사 용지에는 비뚤어진 사람 얼굴 같은 것이 인쇄되어 있다. 징그럽다…….",
          "지정특기：그늘\n창백한 아이가 책상 밑에서 당신을 쳐다보고 있다. 우와!라고 외치며 뛰어 올랐다가 앉으면, 아이의 모습은 사라졌다.",
          "지정특기：감촉\n일을 하고 있자니, 뒤에서 긴 흑발이 늘어져 왔다. 여자의 긴 생머리다. ……뒤에서 들여다보는 것은 도대체 누구인가?",
          "지정특기：근심\n시야의 구석을 어두운 얼굴의 남자가 지나가는 것이 보였다. 돌아봐도 아무도 없다. 누구야? 모른다고, 저런 녀석.",
          "지정특기：암흑\n팟! 갑작스런 정전으로 층이 어둠에 잠겼다. 놀라서 얼굴을 들어올리면, 어둠 속에서 많은 사람의 그림자가 멈춰 서서, 당신을 가만히 보고 있다!",
        ]

        return get_table_by_1d6(table)
      end

      # 야근 시 전화표
      def get_overtimephone_table
        table = [
          "「진행 상황은 어떻습니까?」\n 클라이언트에게서의 진행 확인 전화. 지금 하고 있어요! 전화 시간이 아깝다구! 스트레스로 배가 아프다. 【생명력】 -1.",
          "「사양이 바뀌어서…… 」\n 클라이언트의 사양 변경 연락. 이제와서!? 죽여버린다!? 모처럼의 작업이 무효가 된다. PP -1",
          "「최근 전화를 받지 않는데……괜찮아?」\n 연인이나 가족 등 소중한 사람의 전화. 업무 시간에 걸지마 하고 생각하면서도, 조금 기분 전환이 된다. 【정신력】 1 회복.",
          "「특상 초밥 오인분 부탁드립니다!」\n 잘못 걸려온 전화였다. 놀라게 하다니…….",
          "「어이! 좀 전의 일인데 어떻게 된거야!」\n 다른 용무의 클레임 전화다! 지친 정신에 손상을 입고, 【정신력】 -1.",
          "「……없으면 좋을텐데。」\n 전화 저편에서 지옥 같은 목소리가 속삭인다. 오싹해져 반사적으로 전화를 끊는다. 착신 이력은 남아있지 않다……뭐야 지금!? 《전자기기》로 공포판정.",
        ]

        return get_table_by_1d6(table)
      end

      # 야근 씬표
      def get_overtimework_scene_table
        table = [
          "지직……갑자기 형광등이 깜박인다. 전기 쪽이 이상한걸까? 정전만은 참아줬으면.",
          "톡. 톡. 어디선가 물이 뚝뚝 떨어지는 소리가 들린다. 어딘가 비가 새거나, 수도꼭지를 잠그는 것을 잊은걸까?",
          "슈욱……쏴아아아아. 화장실 물 내리는 소리가 울린다. 누군가 화장실에 있었나? 아니면다른 층인가?",
          "사이렌 소리가 가까이 다가오고, 적색 빛이 창문에 비친다. 근처에 뭔가 있던 것 같은데…….",
          "뒤에서 누군가 말하는 소리를 들은 것 같다. 순간적으로 뒤돌아 보지만……환청일까?",
          "창문 유리 너머로 보이는 밤의 불빛을 안타까운 마음으로 바라본다. 빨리 돌아가고 싶다…….",
          "갑자기, 핸드폰 소리가 울려 퍼진다. 매너모드로 하고 있었을텐데……도대체, 누구일까?",
          "갑작스런 기계음에 놀라 보면, 팩스가 종이를 뱉어내고 있다. 이런 시간에 무엇일까?",
          "맛있을 것 같은 냄새가 풍겨오고, 갑자기 허기를 느낀다. 어디서 오는거야, 이 냄새는?",
          "기분 전환으로 보고 있던 인터넷이 푹 빠져 문득 깨닫자 수 분 경과……안돼 안돼.",
          "앞으로 배의 노를 저어, 번쩍 눈을 떴다. 황급히 시계를 보고……엣, 벌써 이런 시간이야!?",
        ]
        return get_table_by_2d6(table)
      end

      # 회사명 결정표1
      def get_corporatenameone_table
        table = [
          "플라잉",
          "트러블",
          "브래드",
          "프리티",
          "크림슨",
          "범인",
        ]

        return get_table_by_1d6(table)
      end

      # 회사명 결정표2
      def get_corporatenametwo_table
        table = [
          "위치-즈",
          "인텔리전스",
          "고양이",
          "새",
          "공포",
          "인세인",
        ]

        return get_table_by_1d6(table)
      end

      # 회사명 결정표3
      def get_corporatenamethree_table
        table = [
          "(주)",
          "(주)",
          "(주)",
          "(유)",
          "(유)",
          "(유)",
        ]

        return get_table_by_1d6(table)
      end

      # 반응표
      def get_reaction_scene_table
        table = [
          "「잠시 이쪽으로 와주시겠습니까。」\n 갑자기 체포, 구속당한다. 「반응표」를 사용했던캐릭터는, 이 씬이 종료되고 나서, 2씬 동안, 자신이 씬 플레이어가 아닌 씬에 등장할 수 없게 된다.（마스터 씬에는 등장 가능）",
          "「내가 협력할 수 있는 건, 여기까지다。」\n 협력을 구했던 인물은, 겁을 먹은 듯한 모습으로 손에 든 꾸러미를 당신에게 건네주었다. 「반응표」를 사용했던 캐릭터는, 원하는 아이템 1개를 획득한다.",
          "「그 건은 수사 중입니다. 정보제공 감사합니다。」\n 협력을 구했던 인물은, 생글생글 웃으며 그렇게 대답한다. 무엇을 물어봐도, 똑 같은 대답만 되돌아온다. 「반응표」를 사용했던 캐릭터는, 【정신력】을 1점 감소시킨다.",
          "「혹시 자네, 그 사건의 관계자인가……?」\n 아무래도 협력을 구했던 인물도, 마침 같은 사건을 조사하고 있었던 듯하다. 여러 가지 정보를 제공해 줄 것 같다. 「반응표」를 사용했던 캐릭터는, 이후, 조사판정을 할 때 +1의 수정이 붙는다.",
          "「꿈이라도 꾼 것 아닙니까?」\n 아무리 강하게 호소해도 믿어주지 않는다. ……혹시, 이상한 건 내 쪽이란 건가? 감정의 특기분야에서 랜덤으로 특기를 1개 골라 공포판정을 행한다.",
          "「네네, 우리들도 한가하지 않다구요。」\n 여러 가지를 이야기해도 상대조차 해주지 않는다. 문전박대를 당한다.",
          "「잠시 신체검사를 해도 괜찮겠습니까?」\n 수상한 인물로 여겨진 것 같다. 「반응표」를사용했던 캐릭터가, 아이템이나 위법인 듯한 프라이즈를 가지고 있었을 경우, 이 씬이 종료되고 나서 2씬 동안, 자신이 씬 플레이어가 아닌 씬에 등장할 수 없게 된다.（마스터 씬에서는 등장 가능）",
          "「그건 신경쓰이는군요. 이쪽에서도 조사해보도록하죠。」\n 자기 일처럼 상담에 응해준다. 뭔가 알게되면 연락해주겠다고 말하지만……. 1D6을 굴린다. 홀수라면, 2씬 후에 정보를 건네준다. 「반응표」를 사용했던 캐릭터는, 원하는 【비밀】 1개를 획득한다. 짝수라면, 조사하고 있던 NPC가 의문사 당한다. 「반응표」를 사용했던 캐릭터는, 지식의 특기분야에서 랜덤으로 특기 1개를 골라 공포판정을 한다.",
          "「목숨이 아깝다면 이 이상 관여하지마。」\n 당신은 인기척도 없는 곳으로 끌려가, 구타를 당했다. 협력을 구했던 인물은, 도움을 청했을 터인 당신을 강하게 거부했다. 「반응표」를 사용했던 캐릭터는 【생명력】을 1점 감소시킨다.",
          "「알겠습니다. 만일을 위해 패트롤을 강화하도록 하죠。」\n 주변의 경호를 약속해준다. 「반응표」를 사용했던 캐릭터는, 이 세션 동안, 한 번은 자신이 입었던 데미지를 무효화 시킬 수 있다. 데미지를 무효화 했을 경우, 「반응표」를 사용했던 캐릭터는, 폭력의 특기분야에서 랜덤으로 특기 1개를 골라 공포판정을 한다.",
          "「……뭐야 이녀석!?」\n 도움을 구했던 상대가 갑자기 사망한다. 놈들의 손길이, 이런 곳까지 미치고 있는걸까? 「반응표」를 사용했던 캐릭터는, 폭력의 특기분야에서 랜덤으로 특기 1개를 골라 공포판정을 한다.",
        ]
        return get_table_by_2d6(table)
      end
    end
  end
end

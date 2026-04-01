/**
 * PDP儿童性格测试 - 场景剧本数据
 * 包含8个冒险场景，每个场景考验PDP四个维度的不同方面
 * 分值规则：对应维度3分，相邻维度1分，对立维度0分
 * 8题满分：24分（每题最高3分）
 */

window.StoryData = {
  scenes: [
    // ========== 场景1：森林入口的迷路小兔 ==========
    // 考验：领导力(T) vs 社交力(P) vs 同理心(K) vs 分析力(O)
    {
      id: 'scene1',
      background: 'forest_path',
      title: '森林入口的迷路小兔',
      narration: '你走进了神秘的魔法森林，阳光透过树叶洒下金色的光斑。忽然，你听到一阵小小的哭声——一只毛茸茸的小兔子蹲在路边，眼睛红红的，它迷路了，找不到回家的路。',
      character: 'tiger',
      dialogue: [
        {
          speaker: 'tiger',
          text: '嘿，小冒险家！前面有只迷路的小兔子，你看到了吗？',
          emotion: 'calm',
          action: 'enter'
        },
        {
          speaker: 'tiger',
          text: '它看起来很害怕呢。你觉得我们应该怎么帮助它？',
          emotion: 'worried',
          action: null
        }
      ],
      options: [
        {
          text: '我来带路！跟着我走，我一定能找到小兔子的家！',
          icon: 'compass',
          scores: { tiger: 3, peacock: 1, koala: 0, owl: 1 },
          feedback: '你充满自信地走在前面，小兔子跟着你勇敢地迈出了第一步！勇勇对你竖起了大拇指！',
          nextSceneVariant: 'leader'
        },
        {
          text: '小兔子别哭啦！我给你唱首歌，讲个笑话，让你开心起来吧！',
          icon: 'music',
          scores: { tiger: 1, peacock: 3, koala: 1, owl: 0 },
          feedback: '你的歌声让小兔子破涕为笑！你让大家都变得快乐了，真是个开心果！',
          nextSceneVariant: 'entertainer'
        },
        {
          text: '别害怕，我陪着你。我们慢慢找，一定能找到你的家。',
          icon: 'heart',
          scores: { tiger: 0, peacock: 1, koala: 3, owl: 1 },
          feedback: '你温柔地握住了小兔子的手，它不再害怕了。有你在身边，它觉得好安心。',
          nextSceneVariant: 'comforter'
        },
        {
          text: '让我看看……你从哪个方向来的？我们可以根据脚印找到回家的路。',
          icon: 'magnifier',
          scores: { tiger: 1, peacock: 0, koala: 1, owl: 3 },
          feedback: '好聪明！你仔细观察了地上的脚印，找到了一条清晰的线索！慧慧说你是个小侦探！',
          nextSceneVariant: 'analyst'
        }
      ],
      conditionalDialogue: null
    },

    // ========== 场景2：断桥过河的挑战 ==========
    // 考验：勇气/行动(T) vs 创意/表达(P) vs 耐心/协作(K) vs 计划/思考(O)
    {
      id: 'scene2',
      background: 'river_bridge',
      title: '断桥过河的挑战',
      narration: '你来到了一条清澈的小河边，河水欢快地流淌着。可是糟糕，通往对岸的木桥断了一截！河对面的花丛中似乎藏着第一颗魔法宝石，闪着微微的光芒。',
      character: 'peacock',
      dialogue: [
        {
          speaker: 'peacock',
          text: '哎呀呀，桥断了！可是对面有一颗好漂亮的魔法宝石呢！',
          emotion: 'worried',
          action: 'enter'
        },
        {
          speaker: 'peacock',
          text: '你有没有什么好主意，能让我们过河呢？',
          emotion: 'excited',
          action: 'bounce'
        }
      ],
      options: [
        {
          text: '我直接跳过去！这点距离难不倒我！一、二、三，跳！',
          icon: 'lightning',
          scores: { tiger: 3, peacock: 1, koala: 0, owl: 1 },
          feedback: '哇，你鼓起勇气纵身一跃，稳稳地落在了对岸！真是太勇敢了！',
          nextSceneVariant: 'brave'
        },
        {
          text: '我们可以用树藤搭一个秋千飞过去！像飞翔的小鸟一样，一定很好玩！',
          icon: 'star',
          scores: { tiger: 1, peacock: 3, koala: 0, owl: 1 },
          feedback: '多有创意的想法啊！你用树藤做了一个秋千，像小鸟一样飞过了河！大家都为你鼓掌！',
          nextSceneVariant: 'creative'
        },
        {
          text: '我们找找看有没有浅的地方，一步一步慢慢踩着石头过河吧。',
          icon: 'footprints',
          scores: { tiger: 0, peacock: 0, koala: 3, owl: 1 },
          feedback: '你耐心地找到了河里的踏脚石，一步一步稳稳地走过了河。安全又可靠！',
          nextSceneVariant: 'steady'
        },
        {
          text: '等一下，让我先想想。我来画一张过河的计划图，看看哪种方法最安全。',
          icon: 'clipboard',
          scores: { tiger: 1, peacock: 0, koala: 1, owl: 3 },
          feedback: '你认真地分析了所有可能的方法，选出了最好的一个。计划周全，完美执行！',
          nextSceneVariant: 'planner'
        }
      ],
      conditionalDialogue: {
        condition: 'scene1',
        variants: {
          leader: {
            speaker: 'peacock',
            text: '哇，你刚才带着小兔子找到了家，真是个小领袖！这次你也一定有办法的！',
            emotion: 'excited',
            action: null
          },
          entertainer: {
            speaker: 'peacock',
            text: '你刚才让小兔子笑了呢！我觉得你一定也能想到有趣的过河方法！',
            emotion: 'happy',
            action: null
          },
          comforter: {
            speaker: 'peacock',
            text: '你对小兔子那么温柔，真好。别担心这条河，我们一起想办法！',
            emotion: 'happy',
            action: null
          },
          analyst: {
            speaker: 'peacock',
            text: '你刚才找脚印的样子好厉害！来帮我看看怎么过这条河吧！',
            emotion: 'excited',
            action: null
          }
        }
      }
    },

    // ========== 场景3：水晶洞穴的宝石谜题 ==========
    // 考验：决断力(T) vs 表现欲(P) vs 包容心(K) vs 逻辑力(O)
    {
      id: 'scene3',
      background: 'crystal_cave',
      title: '水晶洞穴的宝石谜题',
      narration: '你走进了一个闪闪发光的水晶洞穴，到处都是五颜六色的宝石。洞穴中央有一个石台，上面放着四颗不同颜色的宝石，旁边的石碑上写着一个谜题：只有选对宝石，才能打开通往下一个世界的大门。',
      character: 'owl',
      dialogue: [
        {
          speaker: 'owl',
          text: '嗯，这个谜题很有趣。石碑上说："选择最能代表你的那颗宝石。"',
          emotion: 'calm',
          action: 'enter'
        },
        {
          speaker: 'owl',
          text: '记住，没有错误的答案。每颗宝石都有自己的魔力，关键是跟着你的心走。',
          emotion: 'calm',
          action: 'glow'
        }
      ],
      options: [
        {
          text: '我选红色宝石！它最亮最耀眼，就像火焰一样充满力量！',
          icon: 'gem_red',
          scores: { tiger: 3, peacock: 1, koala: 0, owl: 1 },
          feedback: '红色宝石在你手中燃起了温暖的光芒！它感受到了你内心的力量和决心！',
          nextSceneVariant: 'power'
        },
        {
          text: '紫色宝石好漂亮啊！它在发光呢，就像会跳舞一样！我要这颗！',
          icon: 'gem_purple',
          scores: { tiger: 1, peacock: 3, koala: 0, owl: 1 },
          feedback: '紫色宝石在你手中绽放出绚丽的彩虹光！它说你是这个洞穴里最闪亮的冒险家！',
          nextSceneVariant: 'sparkle'
        },
        {
          text: '绿色宝石看起来好温润。它好像在轻轻发光，让我觉得很舒服。',
          icon: 'gem_green',
          scores: { tiger: 0, peacock: 1, koala: 3, owl: 1 },
          feedback: '绿色宝石散发出柔和的光芒，整个洞穴都变得温暖起来。它选择了最温柔的你。',
          nextSceneVariant: 'harmony'
        },
        {
          text: '蓝色宝石的光最稳定，而且你看，它的切面是最精致的。我选它。',
          icon: 'gem_blue',
          scores: { tiger: 1, peacock: 0, koala: 1, owl: 3 },
          feedback: '蓝色宝石发出深邃的光芒，仿佛藏着宇宙的秘密。它认可了你的智慧！',
          nextSceneVariant: 'wisdom'
        }
      ],
      conditionalDialogue: {
        condition: 'scene2',
        variants: {
          brave: {
            speaker: 'owl',
            text: '你刚才跳过河的样子可真果断。不过这次需要静下心来观察哦。',
            emotion: 'calm',
            action: null
          },
          creative: {
            speaker: 'owl',
            text: '刚才你用树藤过河的创意不错。看看这些宝石，哪颗让你最有灵感？',
            emotion: 'happy',
            action: null
          },
          steady: {
            speaker: 'owl',
            text: '你踩着石头过河的样子很稳重呢。这次也慢慢感受每颗宝石吧。',
            emotion: 'calm',
            action: null
          },
          planner: {
            speaker: 'owl',
            text: '刚才你的计划画得很好！不过这一次，答案不在脑袋里，在你的心里面哦。',
            emotion: 'happy',
            action: null
          }
        }
      }
    },

    // ========== 场景4：星光草地的精灵舞会 ==========
    // 考验：竞争心(T) vs 社交力(P) vs 和谐感(K) vs 观察力(O)
    {
      id: 'scene4',
      background: 'starlight_meadow',
      title: '星光草地的精灵舞会',
      narration: '夜幕降临，你来到了一片铺满星光的草地。成百上千的小精灵在这里举办舞会！音乐悠扬，萤火虫提着小灯笼飞来飞去。精灵女王邀请你参加今晚的活动。',
      character: 'peacock',
      dialogue: [
        {
          speaker: 'peacock',
          text: '哇哦！舞会耶！我最喜欢舞会了！快看，精灵们在跳舞呢！',
          emotion: 'excited',
          action: 'enter'
        },
        {
          speaker: 'peacock',
          text: '精灵女王说你可以选一种方式参加舞会，你想怎么玩呢？',
          emotion: 'happy',
          action: 'bounce'
        }
      ],
      options: [
        {
          text: '我要参加舞蹈比赛！我一定能跳得最好，拿到第一名！',
          icon: 'trophy',
          scores: { tiger: 3, peacock: 1, koala: 0, owl: 0 },
          feedback: '你自信满满地站上了舞台，用力跳出了最帅的动作！精灵们都为你欢呼！',
          nextSceneVariant: 'competitor'
        },
        {
          text: '我要和精灵们一起跳舞！大家围成一个圈，一起唱歌跳舞多开心啊！',
          icon: 'people',
          scores: { tiger: 0, peacock: 3, koala: 1, owl: 0 },
          feedback: '你拉着精灵们的手一起跳舞，欢声笑语飘荡在星光草地上！你让所有人都笑了！',
          nextSceneVariant: 'socializer'
        },
        {
          text: '我去照顾那边坐着的小精灵吧，它好像没有舞伴，一个人看起来好孤单。',
          icon: 'handshake',
          scores: { tiger: 0, peacock: 1, koala: 3, owl: 1 },
          feedback: '你走过去陪小精灵聊天，它开心地笑了。你让一个孤单的小家伙找到了朋友！',
          nextSceneVariant: 'caretaker'
        },
        {
          text: '我想在旁边安静地看一会儿。精灵跳舞的样子好美，我想把每个动作都记住。',
          icon: 'eye',
          scores: { tiger: 0, peacock: 0, koala: 1, owl: 3 },
          feedback: '你安静地观察着一切，发现了精灵舞步里藏着的秘密图案！慧慧说你的眼睛像望远镜！',
          nextSceneVariant: 'observer'
        }
      ],
      conditionalDialogue: {
        condition: 'scene3',
        variants: {
          power: {
            speaker: 'peacock',
            text: '你的红宝石好亮呀！带着这股力量来跳舞，一定帅呆了！',
            emotion: 'excited',
            action: null
          },
          sparkle: {
            speaker: 'peacock',
            text: '你的紫宝石和舞会的灯光好配！我们一起闪闪发光吧！',
            emotion: 'happy',
            action: null
          },
          harmony: {
            speaker: 'peacock',
            text: '你的绿宝石让草地更美了。舞会因为你变得更温馨了！',
            emotion: 'happy',
            action: null
          },
          wisdom: {
            speaker: 'peacock',
            text: '你的蓝宝石像星星一样！今晚的舞会，你一定会发现很多有趣的事！',
            emotion: 'excited',
            action: null
          }
        }
      }
    },

    // ========== 场景5：古老大树的智慧考验 ==========
    // 考验：执行力(T) vs 感染力(P) vs 忍耐力(K) vs 求知欲(O)
    {
      id: 'scene5',
      background: 'ancient_tree',
      title: '古老大树的智慧考验',
      narration: '森林深处有一棵巨大的古树，树干粗得要十个小朋友才能抱住。古树爷爷已经活了一千岁，它的树洞里藏着一颗魔法宝石。但古树爷爷说，只有通过它的考验才能拿到宝石。',
      character: 'owl',
      dialogue: [
        {
          speaker: 'owl',
          text: '这棵古树可是森林里最有智慧的长者。它的考验不简单哦。',
          emotion: 'calm',
          action: 'enter'
        },
        {
          speaker: 'owl',
          text: '古树爷爷问了一个问题："如果你只有一天时间去做一件事，你会做什么？"',
          emotion: 'calm',
          action: null
        }
      ],
      options: [
        {
          text: '我要完成一个大挑战！比如爬上最高的山顶，或者游过最宽的河！',
          icon: 'mountain',
          scores: { tiger: 3, peacock: 0, koala: 1, owl: 1 },
          feedback: '古树爷爷笑了："你有一颗勇敢行动的心，世界需要像你这样敢做敢当的孩子！"',
          nextSceneVariant: 'achiever'
        },
        {
          text: '我要举办一个超级大派对，把所有的朋友都叫来，一起度过最快乐的一天！',
          icon: 'party',
          scores: { tiger: 0, peacock: 3, koala: 1, owl: 0 },
          feedback: '古树爷爷的树叶沙沙笑了："你的快乐能传染给每一个人，这是了不起的天赋！"',
          nextSceneVariant: 'inspirer'
        },
        {
          text: '我想和家人在一起，一起做饭、一起看星星，安安静静地待一天。',
          icon: 'home',
          scores: { tiger: 0, peacock: 1, koala: 3, owl: 0 },
          feedback: '古树爷爷温柔地说："你懂得珍惜身边的人，这份温暖比什么都珍贵。"',
          nextSceneVariant: 'nurturer'
        },
        {
          text: '我要去图书馆看一整天的书！探索宇宙的秘密，学习新知识！',
          icon: 'book',
          scores: { tiger: 1, peacock: 0, koala: 0, owl: 3 },
          feedback: '古树爷爷投来赞许的目光："求知若渴，你的智慧之树一定会长得又高又大！"',
          nextSceneVariant: 'scholar'
        }
      ],
      conditionalDialogue: {
        condition: 'scene4',
        variants: {
          competitor: {
            speaker: 'owl',
            text: '你在舞会上跳得真带劲。古树爷爷的考验需要另一种力量，准备好了吗？',
            emotion: 'calm',
            action: null
          },
          socializer: {
            speaker: 'owl',
            text: '你在舞会上交了好多朋友！不过这次需要你安静下来，听听自己的心。',
            emotion: 'calm',
            action: null
          },
          caretaker: {
            speaker: 'owl',
            text: '你在舞会上照顾那个小精灵的样子，让古树爷爷也很感动呢。',
            emotion: 'happy',
            action: null
          },
          observer: {
            speaker: 'owl',
            text: '你在舞会上发现了精灵舞步的秘密！古树爷爷说你和他年轻时很像。',
            emotion: 'happy',
            action: null
          }
        }
      }
    },

    // ========== 场景6：彩虹瀑布的团队任务 ==========
    // 考验：指挥力(T) vs 鼓舞力(P) vs 支持力(K) vs 策划力(O)
    {
      id: 'scene6',
      background: 'rainbow_falls',
      title: '彩虹瀑布的团队任务',
      narration: '你来到了壮观的彩虹瀑布！无数水珠在阳光下变成了七色彩虹。瀑布后面有一个秘密洞穴，里面藏着宝石。但是洞口被一块大石头挡住了，一个人搬不动，需要和森林小伙伴们一起才行。',
      character: 'koala',
      dialogue: [
        {
          speaker: 'koala',
          text: '这块石头好大呀。不过没关系，小松鼠、小鹿和小熊都来帮忙了。',
          emotion: 'calm',
          action: 'enter'
        },
        {
          speaker: 'koala',
          text: '大家都看着你呢，你觉得我们应该怎么一起搬开这块大石头？',
          emotion: 'happy',
          action: null
        }
      ],
      options: [
        {
          text: '我来安排！小熊力气大，你去推！小鹿你去搬树枝做撬杆！大家听我指挥！',
          icon: 'megaphone',
          scores: { tiger: 3, peacock: 1, koala: 0, owl: 1 },
          feedback: '你清晰地安排了每个人的任务，大家齐心协力，大石头终于被搬开了！真是个好指挥！',
          nextSceneVariant: 'commander'
        },
        {
          text: '大家加油呀！我们是最棒的团队！一二三，一起使劲！我相信我们一定行！',
          icon: 'fire',
          scores: { tiger: 1, peacock: 3, koala: 1, owl: 0 },
          feedback: '你的鼓励让大家浑身充满了力量！小伙伴们喊着口号一起推，大石头咕噜噜滚开了！',
          nextSceneVariant: 'cheerleader'
        },
        {
          text: '我去帮小松鼠扶好树枝，它太小了搬不动。每个人都需要有人帮忙的。',
          icon: 'hands',
          scores: { tiger: 0, peacock: 0, koala: 3, owl: 1 },
          feedback: '你默默地帮助了最需要帮助的小松鼠，它感动得差点哭了。有你在，大家都觉得好温暖！',
          nextSceneVariant: 'supporter'
        },
        {
          text: '别急，让我先想想用什么方法最省力。对了，我们可以用杠杆原理！',
          icon: 'gear',
          scores: { tiger: 1, peacock: 0, koala: 0, owl: 3 },
          feedback: '你设计了一个巧妙的杠杆装置，用最小的力气搬动了最大的石头！大家都惊呆了！',
          nextSceneVariant: 'strategist'
        }
      ],
      conditionalDialogue: {
        condition: 'scene5',
        variants: {
          achiever: {
            speaker: 'koala',
            text: '你想爬上最高的山顶呢！这次换一种方式，和大家一起合作好不好？',
            emotion: 'happy',
            action: null
          },
          inspirer: {
            speaker: 'koala',
            text: '你想开大派对的想法好棒！现在我们真的需要团队合作了！',
            emotion: 'excited',
            action: null
          },
          nurturer: {
            speaker: 'koala',
            text: '你喜欢和家人在一起，这次我们也像一家人一样一起努力吧！',
            emotion: 'happy',
            action: null
          },
          scholar: {
            speaker: 'koala',
            text: '你喜欢学知识！正好，搬大石头也需要用到物理原理哦！',
            emotion: 'happy',
            action: null
          }
        }
      }
    },

    // ========== 场景7：暗影山谷的恐惧挑战 ==========
    // 考验：勇敢(T) vs 乐观(P) vs 坚韧(K) vs 冷静(O)
    {
      id: 'scene7',
      background: 'shadow_valley',
      title: '暗影山谷的恐惧挑战',
      narration: '前方是一片灰蒙蒙的山谷，阳光照不进来，到处都是奇怪的影子。黑暗迷雾在这里最浓，它会变成你最害怕的样子来吓唬你。这是冒险中最难的一关，你准备好了吗？',
      character: 'tiger',
      dialogue: [
        {
          speaker: 'tiger',
          text: '前面就是暗影山谷。说实话，我第一次来的时候也有点害怕呢。',
          emotion: 'brave',
          action: 'enter'
        },
        {
          speaker: 'tiger',
          text: '黑暗迷雾变成了一个巨大的影子怪物挡在路中间！你想怎么面对它？',
          emotion: 'brave',
          action: 'shake'
        }
      ],
      options: [
        {
          text: '我才不怕你！看我冲过去！再大的怪物也别想挡住我的路！',
          icon: 'sword',
          scores: { tiger: 3, peacock: 0, koala: 0, owl: 1 },
          feedback: '你大喊一声冲了上去，影子怪物被你的勇气吓得往后退了三步！勇勇说你是真正的勇士！',
          nextSceneVariant: 'fearless'
        },
        {
          text: '这个大影子其实挺好笑的！你看它像不像一只穿了大衣的大蘑菇？哈哈哈！',
          icon: 'smile',
          scores: { tiger: 1, peacock: 3, koala: 1, owl: 0 },
          feedback: '你的笑声像阳光一样照亮了山谷！影子怪物被你逗得都忘了自己是来吓人的！',
          nextSceneVariant: 'optimist'
        },
        {
          text: '虽然我害怕，但我不会退缩。我闭上眼睛深呼吸，然后一步一步慢慢往前走。',
          icon: 'shield',
          scores: { tiger: 1, peacock: 0, koala: 3, owl: 1 },
          feedback: '你虽然害怕，但始终没有停下脚步。影子怪物发现吓不倒你，慢慢变淡消失了。',
          nextSceneVariant: 'resilient'
        },
        {
          text: '别慌，影子怪物是假的，它是迷雾变的。让我仔细看看它的弱点在哪里。',
          icon: 'brain',
          scores: { tiger: 0, peacock: 1, koala: 1, owl: 3 },
          feedback: '你冷静地分析了影子怪物的形态，发现它最怕光！你举起宝石，光芒驱散了黑暗！',
          nextSceneVariant: 'analytical'
        }
      ],
      conditionalDialogue: {
        condition: 'scene6',
        variants: {
          commander: {
            speaker: 'tiger',
            text: '你刚才指挥大家搬石头的样子真帅！这次我们一起面对黑暗！',
            emotion: 'brave',
            action: null
          },
          cheerleader: {
            speaker: 'tiger',
            text: '你的鼓励给了大家好多力量！现在，把那份力量留给自己吧！',
            emotion: 'brave',
            action: null
          },
          supporter: {
            speaker: 'tiger',
            text: '你帮助小松鼠的样子让我很感动。这次轮到我陪你了，别怕！',
            emotion: 'brave',
            action: null
          },
          strategist: {
            speaker: 'tiger',
            text: '你的杠杆装置太聪明了！这次也用你的智慧来战胜黑暗吧！',
            emotion: 'excited',
            action: null
          }
        }
      }
    },

    // ========== 场景8：金色山顶的最终选择 ==========
    // 考验：目标感(T) vs 分享欲(P) vs 关怀心(K) vs 完美主义(O)
    {
      id: 'scene8',
      background: 'golden_peak',
      title: '金色山顶的最终选择',
      narration: '你终于来到了魔法森林的最高点——金色山顶！这里阳光灿烂，能看到整个森林的全景。你收集的魔法宝石正在发光，黑暗迷雾马上就要被彻底驱散了。最后一颗宝石就在山顶上，但它问了你一个问题……',
      character: 'koala',
      dialogue: [
        {
          speaker: 'koala',
          text: '你一路走来真的好厉害。最后一颗宝石想知道你的心愿呢。',
          emotion: 'happy',
          action: 'enter'
        },
        {
          speaker: 'koala',
          text: '"当你拥有了所有的魔法力量，你最想做的事情是什么？"',
          emotion: 'calm',
          action: 'glow'
        }
      ],
      options: [
        {
          text: '我要变得更加强大，保护整个魔法森林！成为最伟大的守护者！',
          icon: 'crown',
          scores: { tiger: 3, peacock: 0, koala: 1, owl: 1 },
          feedback: '你的目标清晰而坚定！最后一颗宝石被你的志向点燃，发出了最耀眼的光芒！',
          nextSceneVariant: 'protector'
        },
        {
          text: '我要把这个冒险的故事分享给所有人听！让全世界都知道魔法森林有多棒！',
          icon: 'broadcast',
          scores: { tiger: 0, peacock: 3, koala: 1, owl: 0 },
          feedback: '你的故事会传遍整个世界！宝石感受到了你想分享快乐的心，为你绽放出彩虹色的光！',
          nextSceneVariant: 'storyteller'
        },
        {
          text: '我希望森林里的每一个小动物都能幸福快乐，再也不会有人孤单害怕。',
          icon: 'world_heart',
          scores: { tiger: 0, peacock: 1, koala: 3, owl: 0 },
          feedback: '你的善良让宝石流下了感动的泪水。它变成了最温暖的光，温暖了整个森林。',
          nextSceneVariant: 'guardian'
        },
        {
          text: '我想弄明白魔法的原理，把所有的秘密都记录下来，写成一本魔法百科全书！',
          icon: 'scroll',
          scores: { tiger: 1, peacock: 0, koala: 0, owl: 3 },
          feedback: '你对知识的追求让宝石化为一本闪闪发光的魔法书！它说你是未来最伟大的智者！',
          nextSceneVariant: 'sage'
        }
      ],
      conditionalDialogue: {
        condition: 'scene7',
        variants: {
          fearless: {
            speaker: 'koala',
            text: '你刚才冲向影子怪物的样子好勇敢！现在，用同样的勇气说出你的心愿吧。',
            emotion: 'happy',
            action: null
          },
          optimist: {
            speaker: 'koala',
            text: '你把影子怪物变成了大蘑菇，哈哈！你总能让大家笑。那你的心愿是什么呢？',
            emotion: 'happy',
            action: null
          },
          resilient: {
            speaker: 'koala',
            text: '你一步一步走过暗影山谷的样子让我好感动。最后一步了，说出你的心愿吧。',
            emotion: 'happy',
            action: null
          },
          analytical: {
            speaker: 'koala',
            text: '你用光驱散黑暗的方法太聪明了！现在用你的智慧想想，你最想做什么呢？',
            emotion: 'happy',
            action: null
          }
        }
      }
    }
  ],

  // 场景背景配置
  backgroundConfig: {
    forest_path: {
      baseColor: '#2D5016',
      skyColor: '#87CEEB',
      groundColor: '#4A7023',
      particles: ['leaf', 'sunbeam'],
      ambience: 'birds_chirping'
    },
    river_bridge: {
      baseColor: '#1A6B8A',
      skyColor: '#B3E5FC',
      groundColor: '#5D4037',
      particles: ['water_droplet', 'butterfly'],
      ambience: 'river_flowing'
    },
    crystal_cave: {
      baseColor: '#1A1A2E',
      skyColor: '#16213E',
      groundColor: '#0F3460',
      particles: ['crystal_shard', 'sparkle'],
      ambience: 'cave_echo'
    },
    starlight_meadow: {
      baseColor: '#1B0A3C',
      skyColor: '#0D1B2A',
      groundColor: '#2D1B69',
      particles: ['star', 'firefly'],
      ambience: 'night_music'
    },
    ancient_tree: {
      baseColor: '#1B4332',
      skyColor: '#52796F',
      groundColor: '#2D6A4F',
      particles: ['leaf_falling', 'pollen'],
      ambience: 'wind_rustling'
    },
    rainbow_falls: {
      baseColor: '#006994',
      skyColor: '#48CAE4',
      groundColor: '#264653',
      particles: ['rainbow_mist', 'water_spray'],
      ambience: 'waterfall'
    },
    shadow_valley: {
      baseColor: '#1A1A1A',
      skyColor: '#2C2C2C',
      groundColor: '#0D0D0D',
      particles: ['shadow_wisp', 'dark_fog'],
      ambience: 'eerie_wind'
    },
    golden_peak: {
      baseColor: '#F9A825',
      skyColor: '#FFF8E1',
      groundColor: '#F57F17',
      particles: ['golden_sparkle', 'cloud_wisps'],
      ambience: 'triumphant_chime'
    }
  },

  // 场景元数据
  meta: {
    totalScenes: 8,
    maxScorePerScene: 3,
    maxTotalScore: 24,
    dimensions: ['tiger', 'peacock', 'koala', 'owl'],
    dimensionLabels: {
      tiger: '老虎型（领导力/行动力）',
      peacock: '孔雀型（社交力/表达力）',
      koala: '考拉型（同理心/协作力）',
      owl: '猫头鹰型（分析力/思考力）'
    }
  }
};

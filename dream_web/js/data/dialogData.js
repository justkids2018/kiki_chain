/**
 * PDP儿童性格测试 - 对话数据
 * 包含序章、高潮、结局三部分对话序列
 * 每条对话：{speaker, text, emotion, action}
 */

window.DialogData = {
  // ==================== 序章对话 ====================
  prologueDialogues: [
    {
      speaker: 'narrator',
      text: '在遥远的地方，有一片神奇的魔法森林。这里的树会发光，花会唱歌，每一颗石头都藏着一个秘密……',
      emotion: 'calm',
      action: null
    },
    {
      speaker: 'narrator',
      text: '森林里住着四位了不起的动物守护者，他们守护着四块神奇的性格宝石，让整个森林充满了和谐与快乐。',
      emotion: 'happy',
      action: null
    },
    {
      speaker: 'tiger',
      text: '嗨！我是勇勇！我是勇气宝石的守护者！有我在，什么困难都不怕！',
      emotion: 'brave',
      action: 'enter'
    },
    {
      speaker: 'tiger',
      text: '只要勇敢向前冲，就没有到不了的地方！跟我一起加油吧！',
      emotion: 'excited',
      action: 'bounce'
    },
    {
      speaker: 'peacock',
      text: '哈喽哈喽～我是彩彩！我守护着魅力宝石！认识你真是太开心啦！',
      emotion: 'happy',
      action: 'enter'
    },
    {
      speaker: 'peacock',
      text: '我最喜欢交朋友了，和大家在一起的时光总是那么快乐！',
      emotion: 'excited',
      action: 'bounce'
    },
    {
      speaker: 'koala',
      text: '你好呀……我是暖暖，和平宝石的守护者。看到你来了，我好高兴。',
      emotion: 'calm',
      action: 'enter'
    },
    {
      speaker: 'koala',
      text: '别紧张，有什么事我们可以慢慢来，我会一直陪着你的。',
      emotion: 'happy',
      action: null
    },
    {
      speaker: 'owl',
      text: '你好，小朋友。我是慧慧，智慧宝石的守护者。我已经观察你一会儿了。',
      emotion: 'calm',
      action: 'enter'
    },
    {
      speaker: 'owl',
      text: '每个人心里都藏着独特的力量，让我帮你找到属于你的那份特别吧。',
      emotion: 'happy',
      action: 'glow'
    },
    {
      speaker: 'narrator',
      text: '可是有一天，一阵神秘的黑暗迷雾悄悄笼罩了森林……四块性格宝石的光芒开始变得暗淡。',
      emotion: 'worried',
      action: null
    },
    {
      speaker: 'tiger',
      text: '不好了！黑暗迷雾把宝石的力量偷走了！森林变得好暗……',
      emotion: 'worried',
      action: 'shake'
    },
    {
      speaker: 'peacock',
      text: '怎么办呀？没有宝石的光芒，大家都不开心了……',
      emotion: 'worried',
      action: 'shake'
    },
    {
      speaker: 'koala',
      text: '大家别害怕，只要我们团结在一起，一定有办法的。',
      emotion: 'calm',
      action: null
    },
    {
      speaker: 'owl',
      text: '根据古老的传说，只有一位特别的小冒险家才能帮我们找回宝石的力量！',
      emotion: 'excited',
      action: 'glow'
    },
    {
      speaker: 'tiger',
      text: '没错！那个勇敢的小冒险家就是——你！',
      emotion: 'brave',
      action: 'bounce'
    },
    {
      speaker: 'narrator',
      text: '四位守护者一起看向你，眼中闪烁着期待的光芒。一段奇妙的冒险，就要开始啦！',
      emotion: 'excited',
      action: null
    },
    {
      speaker: 'owl',
      text: '在冒险的路上，你会遇到各种各样的挑战。别担心，没有对错，只需要跟着你的心走就好。',
      emotion: 'calm',
      action: null
    },
    {
      speaker: 'tiger',
      text: '准备好了吗？让我们出发吧！魔法森林大冒险，开始！',
      emotion: 'brave',
      action: 'bounce'
    }
  ],

  // ==================== 高潮对决对话 ====================
  climaxDialogues: [
    {
      speaker: 'narrator',
      text: '经过八个关卡的冒险，你终于来到了魔法森林的中心。这里，黑暗迷雾正在聚集着最后的力量……',
      emotion: 'worried',
      action: null
    },
    {
      speaker: 'narrator',
      text: '大地开始颤抖，天空变得昏暗。一团巨大的黑影在你面前渐渐显现！',
      emotion: 'worried',
      action: null
    },
    {
      speaker: 'narrator',
      text: '"哈哈哈……你以为一个小孩子能打败我？" 黑暗迷雾发出低沉的笑声。',
      emotion: 'worried',
      action: null
    },
    {
      speaker: 'tiger',
      text: '别怕！你一路走来已经变得很强大了！我相信你！',
      emotion: 'brave',
      action: 'enter'
    },
    {
      speaker: 'peacock',
      text: '你不是一个人在战斗！我们所有人都在为你加油！',
      emotion: 'excited',
      action: 'enter'
    },
    {
      speaker: 'koala',
      text: '你的温暖和善良是最强大的力量，黑暗迷雾最害怕的就是这个！',
      emotion: 'calm',
      action: 'enter'
    },
    {
      speaker: 'owl',
      text: '四块宝石正在响应你的心——你在冒险中展现的品质，就是驱散黑暗的钥匙！',
      emotion: 'excited',
      action: 'enter'
    },
    {
      speaker: 'narrator',
      text: '四块性格宝石开始发出耀眼的光芒——橙色的勇气、紫色的魅力、绿色的和平、蓝色的智慧！',
      emotion: 'excited',
      action: null
    },
    {
      speaker: 'narrator',
      text: '宝石的光芒汇聚在一起，形成了一道璀璨的彩虹光束！黑暗迷雾痛苦地尖叫着……',
      emotion: 'brave',
      action: null
    },
    {
      speaker: 'narrator',
      text: '"不——这不可能！" 黑暗迷雾在光芒中渐渐消散，森林重新恢复了光明！',
      emotion: 'happy',
      action: null
    },
    {
      speaker: 'narrator',
      text: '阳光重新洒满了魔法森林，花朵绽放，鸟儿歌唱，一切都变得比以前更加美丽！',
      emotion: 'happy',
      action: null
    },
    {
      speaker: 'tiger',
      text: '太棒了！你做到了！你是最勇敢的冒险家！',
      emotion: 'excited',
      action: 'bounce'
    },
    {
      speaker: 'peacock',
      text: '耶耶耶！我就知道你可以的！你简直太厉害了！',
      emotion: 'happy',
      action: 'bounce'
    },
    {
      speaker: 'koala',
      text: '谢谢你，因为有你，森林又恢复了和平与温暖。',
      emotion: 'happy',
      action: null
    },
    {
      speaker: 'owl',
      text: '了不起。在这段冒险中，宝石发现了一个秘密——关于你内心真正的力量……',
      emotion: 'calm',
      action: 'glow'
    }
  ],

  // ==================== 结局对话（按性格类型分类）====================
  endingDialogues: {
    tiger: [
      {
        speaker: 'tiger',
        text: '我就知道！你和我一样，有着一颗勇敢的心！',
        emotion: 'excited',
        action: 'bounce'
      },
      {
        speaker: 'tiger',
        text: '勇气宝石选中了你！你天生就是一个勇敢的小领袖！',
        emotion: 'brave',
        action: 'glow'
      },
      {
        speaker: 'tiger',
        text: '你不怕困难，遇到问题总是第一个冲在前面。这份勇气是你最棒的超能力！',
        emotion: 'happy',
        action: null
      },
      {
        speaker: 'tiger',
        text: '记住，真正的勇敢不只是冲在前面，也要学会听听别人的想法哦。',
        emotion: 'calm',
        action: null
      },
      {
        speaker: 'tiger',
        text: '从今天起，我会一直守护着你！带着勇气向前冲吧，小老虎！',
        emotion: 'brave',
        action: 'glow'
      }
    ],
    peacock: [
      {
        speaker: 'peacock',
        text: '哇哦！魅力宝石在为你闪耀！你果然是个充满魅力的小明星！',
        emotion: 'excited',
        action: 'bounce'
      },
      {
        speaker: 'peacock',
        text: '你就像我一样，天生就会让身边的人感到快乐和温暖！',
        emotion: 'happy',
        action: 'bounce'
      },
      {
        speaker: 'peacock',
        text: '你最厉害的地方就是能把快乐传染给每一个人，走到哪里都像小太阳一样！',
        emotion: 'excited',
        action: null
      },
      {
        speaker: 'peacock',
        text: '不过呢，有时候也要安静下来想一想，好的想法需要时间来酝酿哦。',
        emotion: 'calm',
        action: null
      },
      {
        speaker: 'peacock',
        text: '从今天开始，我就是你的守护者啦！继续发光发亮吧，小孔雀！',
        emotion: 'happy',
        action: 'glow'
      }
    ],
    koala: [
      {
        speaker: 'koala',
        text: '我感觉到了……和平宝石在温柔地为你发光，就像你的心一样温暖。',
        emotion: 'happy',
        action: 'glow'
      },
      {
        speaker: 'koala',
        text: '你有一颗最善良的心，总是能感受到别人的感受，这是最了不起的能力。',
        emotion: 'calm',
        action: null
      },
      {
        speaker: 'koala',
        text: '在冒险中，你总是先关心别人，让大家都感到安心和被爱。',
        emotion: 'happy',
        action: null
      },
      {
        speaker: 'koala',
        text: '不过要记住，照顾别人的同时也要好好照顾自己哦，你值得被温柔对待。',
        emotion: 'calm',
        action: null
      },
      {
        speaker: 'koala',
        text: '我会一直在你身边陪着你。带着爱和温暖前进吧，小考拉！',
        emotion: 'happy',
        action: 'glow'
      }
    ],
    owl: [
      {
        speaker: 'owl',
        text: '有意思……智慧宝石对你产生了最强烈的共鸣。你拥有一颗善于思考的头脑。',
        emotion: 'calm',
        action: 'glow'
      },
      {
        speaker: 'owl',
        text: '在每一次选择中，你都展现出了非凡的智慧和判断力，这让我很欣赏。',
        emotion: 'happy',
        action: null
      },
      {
        speaker: 'owl',
        text: '你喜欢先思考再行动，追求最好的答案。这种认真的态度会让你走得更远。',
        emotion: 'calm',
        action: null
      },
      {
        speaker: 'owl',
        text: '小提示：有时候不用想得太完美，大胆去试试看，犯错也是学习的好方法哦。',
        emotion: 'happy',
        action: null
      },
      {
        speaker: 'owl',
        text: '从今天起，我将守护你的智慧之路。带着好奇心去探索世界吧，小猫头鹰！',
        emotion: 'happy',
        action: 'glow'
      }
    ]
  }
};

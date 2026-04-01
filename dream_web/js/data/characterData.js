/**
 * PDP儿童性格测试 - 角色数据
 * 包含四位守护者的完整信息：外观、性格、对话、绘制参数
 * 老虎·勇勇 | 孔雀·彩彩 | 考拉·暖暖 | 猫头鹰·慧慧
 */

window.CharacterData = {
  tiger: {
    id: 'tiger',
    name: '勇勇',
    species: '老虎',
    fullName: '老虎·勇勇',
    color: '#FF6B35',
    secondaryColor: '#FFD700',
    accentColor: '#FF8F00',
    personality: '勇敢果断，天生领袖',
    catchphrase: '勇敢向前，没有什么能阻挡我们！',
    traits: ['勇敢', '果断', '有领导力', '目标明确'],
    element: 'fire',
    gemColor: '#FF4500',
    gemName: '勇气红宝石',

    greeting: '嗨！我是勇勇，魔法森林里最勇敢的守护者！你看起来也很勇敢呢，我们一起去冒险吧！',
    
    encouragement: [
      '加油！你比自己想象的要勇敢一百倍！',
      '别怕，勇敢的人不是不害怕，而是害怕了还能继续前进！',
      '你做得太棒了！我就知道你是个了不起的冒险家！',
      '每一步都算数，继续走下去，胜利就在前方！',
      '相信自己！你拥有改变一切的力量！'
    ],

    victory: '太厉害了！你用勇气照亮了整个魔法森林，黑暗迷雾再也不敢靠近了！',

    dialogStyle: {
      speed: 'fast',
      tone: 'enthusiastic',
      punctuation: '！'
    },

    drawParams: {
      bodyType: 'strong',
      bodyWidth: 90,
      bodyHeight: 80,
      headSize: 55,
      earType: 'round',
      earSize: 18,
      eyeType: 'determined',
      eyeSize: 12,
      pupilSize: 6,
      noseType: 'triangle',
      noseSize: 8,
      mouthType: 'confident_smile',
      tailType: 'long_curved',
      tailLength: 45,
      limbWidth: 18,
      limbHeight: 30,
      stripePattern: true,
      stripeCount: 5,
      stripeColor: '#CC4400',
      cheekColor: '#FF9966',
      bellyColor: '#FFF3E0',
      crownAccessory: true,
      crownColor: '#FFD700',
      scarf: {
        visible: true,
        color: '#FF0000',
        style: 'hero_cape'
      },
      idleAnimation: {
        type: 'power_pose',
        speed: 1.2,
        amplitude: 3
      },
      expressionMap: {
        happy: { eyeScale: 1.1, mouthCurve: 0.8, blush: true },
        brave: { eyeScale: 1.3, mouthCurve: 0.5, glowEffect: true },
        worried: { eyeScale: 0.9, mouthCurve: -0.2, earDroop: 0.1 },
        excited: { eyeScale: 1.4, mouthCurve: 1.0, jumpHeight: 5 },
        calm: { eyeScale: 1.0, mouthCurve: 0.3, breatheAmplitude: 2 }
      }
    }
  },

  peacock: {
    id: 'peacock',
    name: '彩彩',
    species: '孔雀',
    fullName: '孔雀·彩彩',
    color: '#7C4DFF',
    secondaryColor: '#E040FB',
    accentColor: '#AA00FF',
    personality: '热情开朗，善于表达',
    catchphrase: '一起来吧，快乐是最大的魔法！',
    traits: ['热情', '善于表达', '有创意', '乐于分享'],
    element: 'light',
    gemColor: '#9C27B0',
    gemName: '欢乐紫水晶',

    greeting: '哇！你终于来啦！我是彩彩，最喜欢交新朋友了！你一定有好多好多有趣的故事要告诉我吧？',

    encouragement: [
      '你好棒呀！每个人都有自己独特的光芒！',
      '开心一点嘛！笑一笑，什么困难都会变小的！',
      '哇，你的想法好有趣！我从来没想到过呢！',
      '没关系没关系，我们可以换一种方式试试看！',
      '你知道吗？快乐的人运气都不会太差哦！'
    ],

    victory: '耶耶耶！我们一起创造了最美的魔法彩虹！你是最闪亮的那颗星！',

    dialogStyle: {
      speed: 'fast',
      tone: 'cheerful',
      punctuation: '！～'
    },

    drawParams: {
      bodyType: 'elegant',
      bodyWidth: 70,
      bodyHeight: 85,
      headSize: 45,
      crownFeathers: {
        count: 3,
        height: 25,
        colors: ['#7C4DFF', '#E040FB', '#448AFF']
      },
      eyeType: 'sparkling',
      eyeSize: 14,
      pupilSize: 7,
      eyelashLength: 4,
      beakType: 'small_curved',
      beakColor: '#FF9800',
      tailType: 'fan',
      tailFeathers: {
        count: 7,
        length: 60,
        colors: ['#7C4DFF', '#E040FB', '#448AFF', '#00BCD4', '#4CAF50', '#FFD700', '#FF5252'],
        eyeSpots: true,
        eyeSpotColor: '#1A237E',
        shimmer: true
      },
      wingType: 'folded_elegant',
      wingSize: 35,
      legType: 'thin_long',
      legHeight: 35,
      bodyGradient: {
        start: '#7C4DFF',
        end: '#304FFE'
      },
      sparkleEffect: true,
      sparkleCount: 5,
      idleAnimation: {
        type: 'dance_sway',
        speed: 1.0,
        amplitude: 4
      },
      expressionMap: {
        happy: { eyeScale: 1.3, sparkle: true, tailSpread: 1.2, blush: true },
        brave: { eyeScale: 1.1, tailSpread: 1.5, glowEffect: true },
        worried: { eyeScale: 0.8, tailSpread: 0.6, featherDroop: 0.2 },
        excited: { eyeScale: 1.5, sparkle: true, tailSpread: 1.8, spinEffect: true },
        calm: { eyeScale: 1.0, tailSpread: 0.8, shimmerSlow: true }
      }
    }
  },

  koala: {
    id: 'koala',
    name: '暖暖',
    species: '考拉',
    fullName: '考拉·暖暖',
    color: '#4CAF50',
    secondaryColor: '#81C784',
    accentColor: '#66BB6A',
    personality: '温柔善良，关心他人',
    catchphrase: '别担心，我会一直陪在你身边。',
    traits: ['温柔', '有耐心', '善解人意', '值得信赖'],
    element: 'earth',
    gemColor: '#2E7D32',
    gemName: '温暖绿翡翠',

    greeting: '你好呀小朋友，我是暖暖。不用紧张哦，慢慢来就好，我会一直陪着你的。',

    encouragement: [
      '你已经很棒了，不用着急，按自己的节奏来就好。',
      '没关系的，每个人都会遇到困难，重要的是我们不放弃。',
      '你知道吗？你的善良是最珍贵的宝石。',
      '深呼吸，慢慢来，我相信你一定可以的。',
      '不管发生什么，我都会在你身边为你加油。'
    ],

    victory: '你做到了！你用温暖和善良融化了所有的黑暗，大家都好喜欢你呀。',

    dialogStyle: {
      speed: 'slow',
      tone: 'gentle',
      punctuation: '。～'
    },

    drawParams: {
      bodyType: 'round_soft',
      bodyWidth: 85,
      bodyHeight: 75,
      headSize: 58,
      earType: 'round_fluffy',
      earSize: 22,
      earInnerColor: '#E8F5E9',
      eyeType: 'gentle',
      eyeSize: 13,
      pupilSize: 8,
      eyeHighlight: 2,
      noseType: 'oval',
      noseSize: 10,
      noseColor: '#5D4037',
      mouthType: 'warm_smile',
      armType: 'hugging',
      armWidth: 20,
      armLength: 35,
      legType: 'short_sturdy',
      legHeight: 20,
      furTexture: 'fluffy',
      furColor: '#78909C',
      bellyColor: '#EFEBE9',
      cheekColor: '#F48FB1',
      cheekSize: 10,
      leafAccessory: {
        visible: true,
        position: 'head',
        color: '#4CAF50',
        type: 'eucalyptus'
      },
      scarf: {
        visible: true,
        color: '#4CAF50',
        style: 'cozy_wrap'
      },
      heartEffect: true,
      idleAnimation: {
        type: 'gentle_breathe',
        speed: 0.6,
        amplitude: 2
      },
      expressionMap: {
        happy: { eyeScale: 1.1, mouthCurve: 0.6, cheekGlow: true, heartFloat: true },
        brave: { eyeScale: 1.0, mouthCurve: 0.4, fistClench: true },
        worried: { eyeScale: 1.2, mouthCurve: -0.1, tearDrop: 0.3 },
        excited: { eyeScale: 1.2, mouthCurve: 0.8, bounceSmall: true },
        calm: { eyeScale: 0.9, mouthCurve: 0.5, breatheSlow: true }
      }
    }
  },

  owl: {
    id: 'owl',
    name: '慧慧',
    species: '猫头鹰',
    fullName: '猫头鹰·慧慧',
    color: '#2196F3',
    secondaryColor: '#64B5F6',
    accentColor: '#1976D2',
    personality: '聪明冷静，思考周全',
    catchphrase: '让我想想，一定有更好的办法。',
    traits: ['聪明', '冷静', '爱思考', '追求完美'],
    element: 'wind',
    gemColor: '#0D47A1',
    gemName: '智慧蓝宝石',

    greeting: '嗯，你好。我是慧慧，我一直在观察你呢。你看起来是个聪明的孩子，让我们一起解开森林的秘密吧。',

    encouragement: [
      '仔细想想，答案就藏在细节里。',
      '很好的思路！继续往下想，你马上就要找到答案了。',
      '知识就是力量，你学到的每一样东西都会成为你的翅膀。',
      '不急，好的答案需要时间来酝酿。',
      '你的观察力真强！连我都没注意到这一点呢。'
    ],

    victory: '精彩！你用智慧解开了所有的谜题，魔法森林因为你变得更加有趣了。',

    dialogStyle: {
      speed: 'medium',
      tone: 'thoughtful',
      punctuation: '。'
    },

    drawParams: {
      bodyType: 'compact_round',
      bodyWidth: 75,
      bodyHeight: 70,
      headSize: 55,
      earTufts: {
        visible: true,
        height: 15,
        color: '#1565C0'
      },
      eyeType: 'large_round',
      eyeSize: 18,
      pupilSize: 10,
      eyeRingColor: '#BBDEFB',
      eyeRingWidth: 3,
      beakType: 'pointed_small',
      beakColor: '#FFC107',
      wingType: 'folded',
      wingSpan: 50,
      wingPatternColor: '#1565C0',
      wingPatternType: 'feather_layers',
      tailType: 'short_fan',
      tailLength: 20,
      talonType: 'sharp',
      talonLength: 15,
      bodyFeatherPattern: {
        type: 'spotted',
        spotColor: '#BBDEFB',
        spotSize: 4,
        spotCount: 12
      },
      glasses: {
        visible: true,
        type: 'round',
        color: '#FFD700',
        frameWidth: 2
      },
      book: {
        visible: true,
        position: 'wing',
        color: '#3F51B5'
      },
      starEffect: true,
      idleAnimation: {
        type: 'head_tilt',
        speed: 0.8,
        amplitude: 8
      },
      expressionMap: {
        happy: { eyeScale: 1.1, beakOpen: 0.3, headTilt: 5 },
        brave: { eyeScale: 1.2, wingSpread: 1.3, glassesShine: true },
        worried: { eyeScale: 1.3, headTilt: -8, featherRuffle: true },
        excited: { eyeScale: 1.4, wingFlap: true, starBurst: true },
        calm: { eyeScale: 0.9, headTilt: 0, glowSoft: true }
      }
    }
  }
};

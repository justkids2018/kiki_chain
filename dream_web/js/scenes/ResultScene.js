/**
 * ResultScene - 多维度性格分析报告
 */
window.ResultScene = {
  id: 'result',
  container: null,
  _running: false,

  // 16种性格的详细多维度建议数据
  _adviceData: {
    tiger: {
      communication: {
        title: '🗣 沟通风格',
        child: '你喜欢直接表达，说话干脆利落。讨论问题时总是第一个发言，喜欢主导话题方向。',
        parent: '跟孩子沟通时给予明确的目标和挑战，避免唠叨。他们喜欢"讲道理"不如"比一比"——用竞赛的方式更有效。尊重他们想要做主的需求，在安全范围内让他们自己做决定。'
      },
      interest: {
        title: '🎯 兴趣培养方向',
        items: ['运动竞技类：武术、游泳、足球、攀岩', '领导力训练：辩论赛、学生会、项目管理', '探险挑战类：野外露营、障碍赛、编程竞赛', '策略游戏：国际象棋、围棋、策略桌游']
      },
      teaching: {
        title: '📚 教学引导方法',
        tips: [
          '设定清晰的目标和奖励机制，让学习变成"通关挑战"',
          '给予领导角色——让他们当小组长，在责任中成长',
          '避免过度限制，用"可以做什么"代替"不能做什么"',
          '鼓励他们在竞争中学会尊重对手，输了也了不起'
        ]
      },
      learning: {
        title: '📖 学习方式偏好',
        text: '目标导向型学习者。喜欢先看到全貌再拆分执行，适合项目制学习（PBL）。对有明确评分和排名的学习任务更有动力。注意力集中但容易急于求成，需要培养"慢下来把事情做好"的习惯。'
      },
      social: {
        title: '👫 社交建议',
        text: '天生的领导者，容易成为小团体中心。但需要学习倾听和妥协。建议多参加需要合作的团队活动，让他们体验"不是老大也可以很棒"。遇到冲突时引导他们换位思考。'
      },
      career: {
        title: '🚀 未来职业方向参考',
        items: ['企业管理 / CEO / 创业者', '运动员 / 教练', '律师 / 法官', '军事指挥 / 消防员', '项目经理 / 产品总监']
      }
    },
    peacock: {
      communication: {
        title: '🗣 沟通风格',
        child: '你是天生的小话唠，能聊能唱还能演！你喜欢分享有趣的事情，讲话绘声绘色，是朋友圈里的开心果。',
        parent: '孩子需要大量的关注和认可。多夸奖他们的创意和表达（而不只是成绩），给他们展示自己的舞台。避免在公众场合批评他们——他们非常在意面子。'
      },
      interest: {
        title: '🎯 兴趣培养方向',
        items: ['表演艺术类：话剧、舞蹈、主持、唱歌', '创意设计类：绘画、手工、动画制作、服装设计', '社交类活动：演讲比赛、社团活动、vlog创作', '语言类：外语学习、写作、播客']
      },
      teaching: {
        title: '📚 教学引导方法',
        tips: [
          '用故事和角色扮演的方式教学，比干巴巴的课本有效10倍',
          '给予充足的表达和展示机会——课堂汇报、才艺展示',
          '把学习内容变成可以"创作"的任务，比如拍视频、做海报',
          '帮助他们学会专注——一次只做一件事，做完再做下一件'
        ]
      },
      learning: {
        title: '📖 学习方式偏好',
        text: '体验式学习者。喜欢互动、讨论、动手做，不喜欢枯燥的背诵。适合多媒体教学和小组合作学习。注意力容易分散，建议把学习时间分成小段（25分钟番茄钟），中间穿插有趣的休息。'
      },
      social: {
        title: '👫 社交建议',
        text: '超强社交力，朋友多但可能不够深入。引导他们珍惜几个知心好友，学会深度聆听。当他们说"全班都是我朋友"时，帮他们区分"一起玩的人"和"真正的朋友"。'
      },
      career: {
        title: '🚀 未来职业方向参考',
        items: ['演员 / 主持人 / 网红', '设计师 / 创意总监', '市场营销 / 公关', '老师 / 培训师', '记者 / 自媒体']
      }
    },
    koala: {
      communication: {
        title: '🗣 沟通风格',
        child: '你说话温柔，总是先想到别人的感受。你不太爱在大家面前大声说话，但一对一聊天时特别贴心，朋友都愿意跟你说心里话。',
        parent: '孩子需要安全感和稳定的环境。改变和新环境会让他们紧张，需要提前告知和温柔引导。不要强迫他们在众人面前表现，让他们按自己的节奏来。多问"你觉得怎么样"，认真听他们的回答。'
      },
      interest: {
        title: '🎯 兴趣培养方向',
        items: ['照顾类：宠物饲养、园艺种植、烹饪烘焙', '手工艺术：编织、陶艺、折纸、插花', '音乐类：钢琴、古筝、合唱团（非独唱）', '志愿服务：社区服务、环保活动、义卖']
      },
      teaching: {
        title: '📚 教学引导方法',
        tips: [
          '创造安全温暖的学习环境，不要催促和施压',
          '多给正面鼓励，少用批评——一句批评需要五句表扬来修复',
          '让他们做小助手和调解员，在服务他人中获得成就感',
          '鼓励他们勇敢表达自己的想法："你的意见很重要，大家都想听"'
        ]
      },
      learning: {
        title: '📖 学习方式偏好',
        text: '稳定型学习者。喜欢有规律的学习节奏，不喜欢突如其来的变化。适合循序渐进的教学方式。他们可能学得不是最快的，但学得最扎实。给予充足的时间消化知识，不要跟别人比速度。'
      },
      social: {
        title: '👫 社交建议',
        text: '有几个很好的朋友，但朋友圈不大。他们是最好的倾听者和忠实的朋友。引导他们学会说"不"——善良不等于什么都答应。当他们被人欺负时，教他们勇敢发声，必要时帮他们出头。'
      },
      career: {
        title: '🚀 未来职业方向参考',
        items: ['心理咨询师 / 社工', '医生 / 护士 / 兽医', '老师（特别是幼教）', '人力资源 / 行政管理', '园艺师 / 环保工作者']
      }
    },
    owl: {
      communication: {
        title: '🗣 沟通风格',
        child: '你说话认真有条理，经常问"为什么"。你不太喜欢闲聊，但对感兴趣的话题能滔滔不绝。你习惯先想好了再开口，所以有时候会比别人慢半拍说话。',
        parent: '孩子需要逻辑和道理，"因为我说了算"对他们无效。耐心回答他们的"为什么"，哪怕问了一百遍。给他们足够的独处和思考时间。不要嘲笑他们的"怪问题"——那可能是天才的种子。'
      },
      interest: {
        title: '🎯 兴趣培养方向',
        items: ['科学探究类：编程、机器人、科学实验、天文观测', '逻辑思维类：数学奥赛、国际象棋、推理解谜', '阅读写作类：科幻小说、百科全书、研究性写作', '收集分类：标本收集、集邮、模型搭建']
      },
      teaching: {
        title: '📚 教学引导方法',
        tips: [
          '解释清楚"为什么学这个"——知道原因他们才有动力',
          '给予独立思考的时间和空间，不要急于给答案',
          '用数据、图表、思维导图等可视化方式辅助学习',
          '允许他们深入钻研自己感兴趣的领域——深度比广度更重要'
        ]
      },
      learning: {
        title: '📖 学习方式偏好',
        text: '分析型学习者。喜欢系统性地学习，先建立框架再填充细节。适合结构化的教学和自主学习。完美主义倾向可能导致拖延，需要帮助他们接受"80分就可以先交卷"。对重复练习的耐受度低，需要增加难度变化。'
      },
      social: {
        title: '👫 社交建议',
        text: '朋友不多但质量高，偏好深度交流。可能在热闹的场合觉得不自在，这完全正常。不要强迫他们社交，但可以创造小范围的社交机会（2-3人的兴趣小组最理想）。教他们理解"不是所有人都要讲道理，有时候表达情感更重要"。'
      },
      career: {
        title: '🚀 未来职业方向参考',
        items: ['科学家 / 工程师 / 程序员', '医学研究 / 生物学家', '数据分析师 / 金融分析师', '教授 / 学者 / 作家', '建筑师 / 产品设计师']
      }
    }
  },

  init: function(container) {
    this.container = container;
    container.className = 'scene scene-result scene-entering';
    container.innerHTML = '';

    var content = document.createElement('div');
    content.className = 'result-content';
    content.id = 'result-content';
    container.appendChild(content);
  },

  enter: function() {
    this._running = true;
    var result = this._getResult();
    this._renderResult(result);
    return Promise.resolve();
  },

  _getResult: function() {
    var result = null;
    if (window.ScoreEngine) {
      var primaryType = ScoreEngine.calculateResult();
      var engineResult = ScoreEngine.getResultData();

      if (window.ResultData && engineResult && engineResult.primary && engineResult.secondary) {
        var resultKey = engineResult.primary + '_' + engineResult.secondary;
        var richResult = ResultData.results && ResultData.results[resultKey];
        if (richResult) {
          result = {
            primary: engineResult.primary,
            secondary: engineResult.secondary,
            title: richResult.title,
            subtitle: richResult.subtitle,
            description: richResult.description,
            traits: richResult.traits,
            strength: richResult.strengths || richResult.strength || '',
            growth: richResult.growth,
            blessing: richResult.blessing,
            color: richResult.color,
            scores: engineResult.scores || ScoreEngine.getScores()
          };
        }
      }
      if (!result && engineResult) result = engineResult;
      if (!result && primaryType) {
        result = {
          primary: primaryType, secondary: 'peacock',
          title: '神秘的冒险家', traits: ['勇敢', '善良', '聪明', '乐观'],
          strength: '你有着独一无二的力量组合！',
          growth: '继续保持好奇心，你会变得更加了不起！',
          blessing: '守护者们都为你骄傲！'
        };
      }
    }
    if (!result) {
      result = {
        primary: 'tiger', secondary: 'peacock',
        title: '勇敢的小领袖', subtitle: '老虎型',
        traits: ['勇敢', '果断', '有领导力', '充满活力'],
        strength: '你天生就是领袖！', growth: '也要耐心听听别人的想法哦！',
        blessing: '带着勇气向前冲吧！'
      };
    }
    return result;
  },

  _renderResult: function(result) {
    var content = document.getElementById('result-content');
    if (!content) return;
    content.innerHTML = '';

    var primary = result.primary || 'tiger';
    var advice = this._adviceData[primary] || this._adviceData.tiger;

    // === 头部：头像 + 标题 ===
    var charImg = document.createElement('img');
    charImg.className = 'result-guardian-img';
    charImg.src = 'assets/avatars/' + primary + '.jpg';
    charImg.alt = result.title || '守护者';
    content.appendChild(charImg);

    this._addEl(content, 'div', 'result-title', result.title || '神秘守护者');
    this._addEl(content, 'div', 'result-subtitle', result.subtitle || '');

    // === 性格标签 ===
    var traits = document.createElement('div');
    traits.className = 'result-traits';
    (result.traits || []).forEach(function(t) {
      var tag = document.createElement('span');
      tag.className = 'result-trait-tag';
      tag.textContent = t;
      traits.appendChild(tag);
    });
    content.appendChild(traits);

    // === 性格概述 ===
    if (result.description) {
      this._addCard(content, '🌈 性格概述', result.description);
    }

    // === 超能力 ===
    this._addCard(content, '✨ 你的超能力', result.strength || result.strengths || '');

    // === 沟通风格 ===
    if (advice.communication) {
      this._addCard(content, advice.communication.title,
        '<strong>孩子的表现：</strong>' + advice.communication.child +
        '<br><br><strong>家长沟通建议：</strong>' + advice.communication.parent
      );
    }

    // === 兴趣培养 ===
    if (advice.interest) {
      var interestHtml = '<ul style="padding-left:16px;margin:0">' +
        advice.interest.items.map(function(item) { return '<li style="margin-bottom:4px">' + item + '</li>'; }).join('') +
        '</ul>';
      this._addCard(content, advice.interest.title, interestHtml);
    }

    // === 教学引导方法 ===
    if (advice.teaching) {
      var teachingHtml = '<ol style="padding-left:18px;margin:0">' +
        advice.teaching.tips.map(function(tip) { return '<li style="margin-bottom:6px">' + tip + '</li>'; }).join('') +
        '</ol>';
      this._addCard(content, advice.teaching.title, teachingHtml);
    }

    // === 学习方式 ===
    if (advice.learning) {
      this._addCard(content, advice.learning.title, advice.learning.text);
    }

    // === 社交建议 ===
    if (advice.social) {
      this._addCard(content, advice.social.title, advice.social.text);
    }

    // === 成长小秘密 ===
    this._addCard(content, '🌱 成长小秘密', result.growth || '');

    // === 未来职业方向 ===
    if (advice.career) {
      var careerHtml = advice.career.items.map(function(item) {
        return '<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:12px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.12);font-size:12px">' + item + '</span>';
      }).join('');
      this._addCard(content, advice.career.title, '<div style="display:flex;flex-wrap:wrap;gap:2px">' + careerHtml + '</div>');
    }

    // === 守护者祝福 ===
    if (result.blessing) {
      var blessing = document.createElement('div');
      blessing.className = 'result-blessing';
      blessing.innerHTML = '<div class="result-blessing-text">"' + result.blessing + '"</div>';
      content.appendChild(blessing);
    }

    // === 按钮 ===
    var actions = document.createElement('div');
    actions.className = 'result-actions';

    var shareBtn = document.createElement('button');
    shareBtn.className = 'result-btn result-btn-primary';
    shareBtn.textContent = '查看我的卡片';
    shareBtn.onclick = function() {
      if (window.SceneManager) SceneManager.goto('share', { result: result });
    };

    var retryBtn = document.createElement('button');
    retryBtn.className = 'result-btn result-btn-secondary';
    retryBtn.textContent = '再测一次';
    retryBtn.onclick = function() {
      if (window.ScoreEngine) ScoreEngine.reset();
      if (window.SceneManager) SceneManager.goto('welcome');
    };

    actions.appendChild(shareBtn);
    actions.appendChild(retryBtn);
    content.appendChild(actions);
  },

  _addEl: function(parent, tag, cls, text) {
    var el = document.createElement(tag);
    el.className = cls;
    el.textContent = text;
    parent.appendChild(el);
    return el;
  },

  _addCard: function(parent, title, htmlContent) {
    if (!htmlContent) return;
    var card = document.createElement('div');
    card.className = 'result-card';
    card.innerHTML = '<div class="result-card-title">' + title + '</div>' +
      '<div class="result-card-text">' + htmlContent + '</div>';
    parent.appendChild(card);
  },

  exit: function() {
    this._running = false;
    return Promise.resolve();
  },

  destroy: function() {
    this._running = false;
    this.container = null;
  }
};

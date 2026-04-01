/**
 * ScoreEngine - PDP计分引擎
 * 管理四维性格分数（老虎/孔雀/考拉/猫头鹰）、选择历史和结果计算
 * @global window.ScoreEngine
 */
window.ScoreEngine = (function() {
  'use strict';

  /** @type {{tiger: number, peacock: number, koala: number, owl: number}} 四维分数 */
  var scores = { tiger: 0, peacock: 0, koala: 0, owl: 0 };

  /** @type {Array<{sceneId: string, optionIndex: number, scoreObj: Object, timestamp: number}>} 选择历史 */
  var history = [];

  /** @type {string} localStorage存储键 */
  var STORAGE_KEY = 'pdp_test_history';

  /**
   * PDP性格结果数据
   * @type {Object<string, Object>}
   */
  var resultData = {
    tiger: {
      name: '老虎',
      emoji: '🐯',
      color: '#FF6B35',
      title: '勇敢的小老虎',
      traits: ['自信果断', '目标明确', '行动力强', '天生领导者'],
      description: '你像一只勇敢的小老虎，充满自信和勇气！你喜欢挑战，总是第一个冲在前面。你有很强的决断力，知道自己想要什么，并且会努力去实现。',
      strengths: '你天生就是领导者，能带领小伙伴们一起完成任务。你的勇气和决心会帮助你克服一切困难！',
      advice: '记得有时候也要倾听别人的意见哦，好的领导者不只是做决定，还要关心身边的伙伴。'
    },
    peacock: {
      name: '孔雀',
      emoji: '🦚',
      color: '#4ECDC4',
      title: '闪亮的小孔雀',
      traits: ['热情开朗', '善于表达', '创意丰富', '社交达人'],
      description: '你像一只闪亮的小孔雀，热情又有魅力！你喜欢和大家在一起，总能让周围的气氛变得活跃。你有丰富的想象力和创造力，善于表达自己的想法。',
      strengths: '你的热情和创造力是你最大的财富！你能感染身边的每个人，让大家都变得开心。',
      advice: '有时候也需要安静下来，专注地完成一件事情。把你的好主意一个一个变成现实吧！'
    },
    koala: {
      name: '考拉',
      emoji: '🐨',
      color: '#95E1D3',
      title: '温暖的小考拉',
      traits: ['温柔体贴', '耐心十足', '善解人意', '忠诚可靠'],
      description: '你像一只温暖的小考拉，温柔又体贴！你总是关心身边的人，是大家最信赖的好朋友。你有很强的耐心，做事情踏实稳定。',
      strengths: '你的温暖和耐心让身边的人都感到安心。你是最棒的倾听者和最可靠的朋友！',
      advice: '有时候也要勇敢地说出自己的想法哦，你的意见也很重要！不要害怕表达自己。'
    },
    owl: {
      name: '猫头鹰',
      emoji: '🦉',
      color: '#A78BFA',
      title: '智慧的小猫头鹰',
      traits: ['善于思考', '观察敏锐', '追求完美', '逻辑清晰'],
      description: '你像一只智慧的小猫头鹰，聪明又善于观察！你喜欢思考问题，总能发现别人注意不到的细节。你做事认真仔细，追求完美。',
      strengths: '你的智慧和细心是你最大的优势！你能发现事物的本质，做出最准确的判断。',
      advice: '有时候不需要一切都完美哦，允许自己犯小错误，大胆尝试新事物吧！'
    }
  };

  /**
   * 混合性格描述
   * @type {Object<string, string>}
   */
  var blendDescriptions = {
    'tiger-peacock': '你既有老虎的勇气，又有孔雀的热情！你是一个既能带领大家，又能让大家开心的小伙伴。',
    'tiger-koala': '你既有老虎的果断，又有考拉的温暖！你是一个既能做决定，又能照顾到每个人的好领导。',
    'tiger-owl': '你既有老虎的行动力，又有猫头鹰的智慧！你不仅敢想敢做，还能想得很周到。',
    'peacock-koala': '你既有孔雀的活力，又有考拉的温柔！你是大家最喜欢的开心果，也是最贴心的好朋友。',
    'peacock-owl': '你既有孔雀的创意，又有猫头鹰的细心！你的想法总是又有趣又靠谱。',
    'koala-owl': '你既有考拉的耐心，又有猫头鹰的智慧！你是一个做事认真又善解人意的好伙伴。'
  };

  /**
   * 获取混合性格描述键
   * @param {string} a - 第一种性格
   * @param {string} b - 第二种性格
   * @returns {string}
   */
  function getBlendKey(a, b) {
    var types = [a, b].sort();
    return types.join('-');
  }

  /**
   * 安全地从localStorage读取JSON
   * @param {string} key - 存储键
   * @returns {*}
   */
  function safeGetJSON(key) {
    try {
      var data = localStorage.getItem(key);
      return data ? JSON.parse(data) : null;
    } catch (e) {
      console.warn('[ScoreEngine] localStorage读取失败:', e);
      return null;
    }
  }

  /**
   * 安全地写入localStorage
   * @param {string} key - 存储键
   * @param {*} value - 值
   */
  function safeSetJSON(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (e) {
      console.warn('[ScoreEngine] localStorage写入失败:', e);
    }
  }

  return {
    /**
     * 重置所有分数和历史
     */
    reset: function() {
      scores = { tiger: 0, peacock: 0, koala: 0, owl: 0 };
      history = [];
    },

    /**
     * 记录选择并累加分值
     * 支持两种调用方式：
     *   addScore(sceneId, optionIndex, scoreObj) - 完整三参数
     *   addScore(scoreObj) - 仅传分值对象（简化模式）
     * @param {string|Object} sceneIdOrScoreObj - 场景ID或分值对象
     * @param {number} [optionIndex] - 选项索引
     * @param {Object} [scoreObj] - 分值对象，如 { tiger: 3, peacock: 1, koala: 0, owl: 1 }
     */
    addScore: function(sceneIdOrScoreObj, optionIndex, scoreObj) {
      var sceneId, actualScore;

      // 判断调用方式
      if (typeof sceneIdOrScoreObj === 'object' && sceneIdOrScoreObj !== null) {
        // addScore(scoreObj) 简化调用
        actualScore = sceneIdOrScoreObj;
        sceneId = 'q' + (history.length + 1); // 自动生成场景ID
        optionIndex = history.length;
      } else {
        // addScore(sceneId, optionIndex, scoreObj) 完整调用
        sceneId = sceneIdOrScoreObj;
        actualScore = scoreObj;
      }

      if (!sceneId || typeof sceneId !== 'string') {
        console.warn('[ScoreEngine] addScore() 需要有效的场景ID');
        return;
      }
      if (!actualScore || typeof actualScore !== 'object') {
        console.warn('[ScoreEngine] addScore() 需要有效的分值对象');
        return;
      }

      // 检查是否已回答过该场景（如果是则先回退之前的分数）
      for (var i = history.length - 1; i >= 0; i--) {
        if (history[i].sceneId === sceneId) {
          // 回退之前的分数
          var oldScore = history[i].scoreObj;
          if (oldScore) {
            Object.keys(oldScore).forEach(function(key) {
              if (scores[key] !== undefined) {
                scores[key] -= (oldScore[key] || 0);
              }
            });
          }
          history.splice(i, 1);
          break;
        }
      }

      // 累加新分值
      Object.keys(actualScore).forEach(function(key) {
        if (scores[key] !== undefined) {
          scores[key] += (actualScore[key] || 0);
        }
      });

      // 记录选择
      history.push({
        sceneId: sceneId,
        optionIndex: typeof optionIndex === 'number' ? optionIndex : history.length,
        scoreObj: actualScore,
        timestamp: Date.now()
      });
    },

    /**
     * 获取当前四维分数
     * @returns {{tiger: number, peacock: number, koala: number, owl: number}}
     */
    getScores: function() {
      return {
        tiger: scores.tiger,
        peacock: scores.peacock,
        koala: scores.koala,
        owl: scores.owl
      };
    },

    /**
     * 获取完整选择历史
     * @returns {Array<Object>}
     */
    getHistory: function() {
      return history.slice();
    },

    /**
     * 获取某场景的选择记录
     * @param {string} sceneId - 场景ID
     * @returns {Object|null}
     */
    getChoice: function(sceneId) {
      for (var i = history.length - 1; i >= 0; i--) {
        if (history[i].sceneId === sceneId) {
          return history[i];
        }
      }
      return null;
    },

    /**
     * 计算最终测试结果
     * 返回最高分的角色ID字符串（如 'tiger'）
     * @returns {string} 最高分角色ID
     */
    calculateResult: function() {
      // 排序找出主性格
      var sorted = Object.keys(scores).sort(function(a, b) {
        return scores[b] - scores[a];
      });

      return sorted[0];
    },

    /**
     * 获取详细的计算结果（包含完整分数、百分比和混合描述）
     * @returns {{primary: string, secondary: string, scores: Object, percentage: Object, blend: string}}
     */
    calculateDetailedResult: function() {
      var total = scores.tiger + scores.peacock + scores.koala + scores.owl;
      if (total === 0) total = 1; // 防止除零

      // 计算百分比
      var percentage = {
        tiger: Math.round((scores.tiger / total) * 100),
        peacock: Math.round((scores.peacock / total) * 100),
        koala: Math.round((scores.koala / total) * 100),
        owl: Math.round((scores.owl / total) * 100)
      };

      // 排序找出主性格和次性格
      var sorted = Object.keys(scores).sort(function(a, b) {
        return scores[b] - scores[a];
      });

      var primary = sorted[0];
      var secondary = sorted[1];

      // 确保secondary与primary不同
      if (secondary === primary && sorted.length > 2) {
        secondary = sorted[2];
      }

      // 获取混合描述
      var blendKey = getBlendKey(primary, secondary);
      var blend = blendDescriptions[blendKey] || '';

      return {
        primary: primary,
        secondary: secondary,
        scores: this.getScores(),
        percentage: percentage,
        blend: blend
      };
    },

    /**
     * 获取完整结果数据（包含文案）
     * 返回结果文案对象，包含 title, subtitle, traits, strength, growth, blessing 字段
     * @returns {Object} 结果文案对象
     */
    getResultData: function() {
      var detailed = this.calculateDetailedResult();
      var primary = detailed.primary;
      var secondary = detailed.secondary;
      var pd = resultData[primary] || {};
      var sd = resultData[secondary] || {};

      // 获取混合描述
      var blendKey = getBlendKey(primary, secondary);
      var blend = blendDescriptions[blendKey] || '';

      return {
        // scene-dev期望的字段
        title: pd.title || '',
        subtitle: pd.name ? (pd.emoji + ' ' + pd.name + '型性格') : '',
        traits: pd.traits || [],
        strength: pd.strengths || pd.description || '',
        growth: pd.advice || '',
        blessing: blend || pd.description || '',

        // 兼容完整数据
        primary: primary,
        secondary: secondary,
        scores: detailed.scores,
        percentage: detailed.percentage,
        blend: blend,
        primaryData: pd,
        secondaryData: sd,
        allTypes: resultData,

        // 额外常用字段
        name: pd.name || '',
        emoji: pd.emoji || '',
        color: pd.color || '',
        description: pd.description || ''
      };
    },

    /**
     * 保存当前测试结果到localStorage
     */
    saveToLocal: function() {
      var result = this.getResultData();
      var record = {
        id: Date.now().toString(36) + Math.random().toString(36).substr(2, 5),
        date: new Date().toISOString(),
        primary: result.primary,
        secondary: result.secondary,
        scores: result.scores,
        percentage: result.percentage,
        history: history.slice()
      };

      var saved = safeGetJSON(STORAGE_KEY) || [];
      if (!Array.isArray(saved)) saved = [];

      // 最多保存20条历史记录
      saved.unshift(record);
      if (saved.length > 20) {
        saved = saved.slice(0, 20);
      }

      safeSetJSON(STORAGE_KEY, saved);
      return record;
    },

    /**
     * 从localStorage读取历史记录
     * @returns {Array<Object>}
     */
    loadFromLocal: function() {
      var saved = safeGetJSON(STORAGE_KEY);
      return Array.isArray(saved) ? saved : [];
    },

    /**
     * 获取历史测试结果列表
     * @returns {Array<Object>} 历史结果（按时间倒序）
     */
    getHistoryResults: function() {
      return this.loadFromLocal();
    },

    /**
     * 获取结果数据定义（所有性格类型）
     * @returns {Object}
     */
    getResultDefinitions: function() {
      return JSON.parse(JSON.stringify(resultData));
    },

    /**
     * 获取答题进度
     * @returns {number} 已答题数
     */
    getProgress: function() {
      return history.length;
    },

    /**
     * 清除localStorage中的历史记录
     */
    clearHistory: function() {
      try {
        localStorage.removeItem(STORAGE_KEY);
      } catch (e) {
        console.warn('[ScoreEngine] 清除历史记录失败:', e);
      }
    }
  };
})();

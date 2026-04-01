/**
 * Easing - 缓动函数集合
 * 提供常用的动画缓动曲线，输入输出范围均为 0~1
 * @global window.Easing
 */
window.Easing = (function() {
  'use strict';

  return {
    /**
     * 线性（匀速）
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    linear: function(t) {
      return t;
    },

    /**
     * 二次方缓入
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeInQuad: function(t) {
      return t * t;
    },

    /**
     * 二次方缓出
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeOutQuad: function(t) {
      return t * (2 - t);
    },

    /**
     * 二次方缓入缓出
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeInOutQuad: function(t) {
      return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
    },

    /**
     * 三次方缓入
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeInCubic: function(t) {
      return t * t * t;
    },

    /**
     * 三次方缓出
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeOutCubic: function(t) {
      var t1 = t - 1;
      return t1 * t1 * t1 + 1;
    },

    /**
     * 三次方缓入缓出
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeInOutCubic: function(t) {
      return t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1;
    },

    /**
     * 超出后回弹（Back效果）
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeOutBack: function(t) {
      var s = 1.70158;
      var t1 = t - 1;
      return t1 * t1 * ((s + 1) * t1 + s) + 1;
    },

    /**
     * 弹跳效果（Bounce）
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeOutBounce: function(t) {
      if (t < 1 / 2.75) {
        return 7.5625 * t * t;
      } else if (t < 2 / 2.75) {
        t -= 1.5 / 2.75;
        return 7.5625 * t * t + 0.75;
      } else if (t < 2.5 / 2.75) {
        t -= 2.25 / 2.75;
        return 7.5625 * t * t + 0.9375;
      } else {
        t -= 2.625 / 2.75;
        return 7.5625 * t * t + 0.984375;
      }
    },

    /**
     * 弹性效果（Elastic）
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeOutElastic: function(t) {
      if (t === 0 || t === 1) return t;
      var p = 0.3;
      var s = p / 4;
      return Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / p) + 1;
    },

    /**
     * 指数缓入缓出
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    easeInOutExpo: function(t) {
      if (t === 0) return 0;
      if (t === 1) return 1;
      if (t < 0.5) {
        return Math.pow(2, 20 * t - 10) / 2;
      }
      return (2 - Math.pow(2, -20 * t + 10)) / 2;
    },

    /**
     * 弹簧效果
     * @param {number} t - 进度 0~1
     * @returns {number}
     */
    spring: function(t) {
      return 1 - Math.cos(t * 4.5 * Math.PI) * Math.exp(-t * 6);
    }
  };
})();

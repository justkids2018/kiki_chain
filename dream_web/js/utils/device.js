/**
 * Device - 设备检测工具
 * 检测运行环境、特性支持和屏幕信息
 * @global window.Device
 */
window.Device = (function() {
  'use strict';

  /** @type {string} 用户代理字符串（缓存） */
  var ua = navigator.userAgent || '';

  /** @type {Function[]} resize回调列表 */
  var resizeCallbacks = [];

  /** @type {number|null} resize节流定时器 */
  var resizeTimer = null;

  /** @type {boolean} resize监听是否已初始化 */
  var resizeInited = false;

  /**
   * 初始化resize监听（惰性）
   */
  function initResizeListener() {
    if (resizeInited) return;
    resizeInited = true;
    window.addEventListener('resize', function() {
      // 节流处理，250ms内仅触发一次
      if (resizeTimer) clearTimeout(resizeTimer);
      resizeTimer = setTimeout(function() {
        for (var i = 0; i < resizeCallbacks.length; i++) {
          try {
            resizeCallbacks[i]();
          } catch (e) {
            console.warn('[Device] resize回调出错:', e);
          }
        }
      }, 250);
    }, false);
  }

  return {
    /**
     * 是否微信环境
     * @returns {boolean}
     */
    isWeChat: function() {
      return /MicroMessenger/i.test(ua);
    },

    /**
     * 是否小程序web-view环境
     * @returns {boolean}
     */
    isMiniProgram: function() {
      // 先检查UA
      if (/miniProgram/i.test(ua)) return true;
      // 再检查全局变量
      if (typeof window.__wxjs_environment !== 'undefined' && window.__wxjs_environment === 'miniprogram') {
        return true;
      }
      return false;
    },

    /**
     * 是否iOS系统
     * @returns {boolean}
     */
    isIOS: function() {
      return /iPhone|iPad|iPod/i.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    },

    /**
     * 是否Android系统
     * @returns {boolean}
     */
    isAndroid: function() {
      return /Android/i.test(ua);
    },

    /**
     * 是否移动端设备
     * @returns {boolean}
     */
    isMobile: function() {
      return this.isIOS() || this.isAndroid() || /Mobile|webOS|BlackBerry|Opera Mini|IEMobile/i.test(ua);
    },

    /**
     * 获取设备像素比
     * @returns {number}
     */
    getDPR: function() {
      return window.devicePixelRatio || 1;
    },

    /**
     * 获取屏幕尺寸
     * @returns {{width: number, height: number}}
     */
    getScreenSize: function() {
      return {
        width: window.innerWidth || document.documentElement.clientWidth || screen.width,
        height: window.innerHeight || document.documentElement.clientHeight || screen.height
      };
    },

    /**
     * 是否支持Web Speech API
     * @returns {boolean}
     */
    supportsSpeech: function() {
      return !!(window.speechSynthesis && window.SpeechSynthesisUtterance);
    },

    /**
     * 是否支持Canvas 2D
     * @returns {boolean}
     */
    supportsCanvas: function() {
      try {
        var canvas = document.createElement('canvas');
        return !!(canvas.getContext && canvas.getContext('2d'));
      } catch (e) {
        return false;
      }
    },

    /**
     * 是否支持触摸事件
     * @returns {boolean}
     */
    supportsTouchEvents: function() {
      return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    },

    /**
     * 是否支持backdrop-filter（毛玻璃效果）
     * @returns {boolean}
     */
    supportsBackdropFilter: function() {
      var el = document.createElement('div');
      el.style.cssText = 'backdrop-filter: blur(1px); -webkit-backdrop-filter: blur(1px)';
      return el.style.backdropFilter !== '' || el.style.webkitBackdropFilter !== '';
    },

    /**
     * 设置rem基准（保持16px固定基准，不动态修改）
     * 项目中用clamp/vw做响应式，不需要动态rem
     * @param {number} [designWidth=375] - 设计稿宽度（保留参数兼容性）
     */
    setRemBase: function(designWidth) {
      // 固定16px基准，不动态修改html font-size
      // 响应式由CSS中的clamp()和vw单位处理
      document.documentElement.style.fontSize = '16px';
    },

    /**
     * 监听窗口变化
     * @param {Function} callback - 回调函数
     * @returns {Function} 取消监听的函数
     */
    onResize: function(callback) {
      if (typeof callback !== 'function') return function() {};

      initResizeListener();
      resizeCallbacks.push(callback);

      return function() {
        var idx = resizeCallbacks.indexOf(callback);
        if (idx !== -1) {
          resizeCallbacks.splice(idx, 1);
        }
      };
    },

    /**
     * 获取屏幕方向
     * @returns {'portrait'|'landscape'}
     */
    getOrientation: function() {
      if (window.screen && window.screen.orientation) {
        return window.screen.orientation.type.indexOf('portrait') !== -1 ? 'portrait' : 'landscape';
      }
      var size = this.getScreenSize();
      return size.height >= size.width ? 'portrait' : 'landscape';
    },

    /**
     * 触觉反馈（振动）
     * @param {number} [duration=15] - 振动时长(ms)
     */
    vibrate: function(duration) {
      duration = duration || 15;
      try {
        if (navigator.vibrate) {
          navigator.vibrate(duration);
        }
      } catch (e) {
        // 静默降级
      }
    },

    /**
     * 获取安全区域信息（适配刘海屏）
     * @returns {{top: number, bottom: number, left: number, right: number}}
     */
    getSafeArea: function() {
      var style = getComputedStyle(document.documentElement);
      return {
        top: parseInt(style.getPropertyValue('env(safe-area-inset-top)'), 10) || 0,
        bottom: parseInt(style.getPropertyValue('env(safe-area-inset-bottom)'), 10) || 0,
        left: parseInt(style.getPropertyValue('env(safe-area-inset-left)'), 10) || 0,
        right: parseInt(style.getPropertyValue('env(safe-area-inset-right)'), 10) || 0
      };
    },

    /**
     * 获取运行环境信息汇总
     * @returns {Object}
     */
    getInfo: function() {
      return {
        isWeChat: this.isWeChat(),
        isMiniProgram: this.isMiniProgram(),
        isIOS: this.isIOS(),
        isAndroid: this.isAndroid(),
        isMobile: this.isMobile(),
        dpr: this.getDPR(),
        screen: this.getScreenSize(),
        orientation: this.getOrientation(),
        supportsSpeech: this.supportsSpeech(),
        supportsCanvas: this.supportsCanvas(),
        supportsTouchEvents: this.supportsTouchEvents(),
        supportsBackdropFilter: this.supportsBackdropFilter()
      };
    }
  };
})();

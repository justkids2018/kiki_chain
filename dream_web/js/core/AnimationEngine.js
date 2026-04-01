/**
 * AnimationEngine - 动画引擎
 * 基于requestAnimationFrame的高性能动画系统
 * 支持补间动画、组合动画、缓动函数
 * @global window.AnimationEngine
 */
window.AnimationEngine = (function() {
  'use strict';

  /** @type {Map<number, Object>} 活动动画集合 */
  var animations = new Map();

  /** @type {Map<number, Function>} 帧回调集合 */
  var frameCallbacks = new Map();

  /** @type {boolean} 主循环是否运行中 */
  var running = false;

  /** @type {number} 上一帧时间戳 */
  var lastTime = 0;

  /** @type {number} 动画ID计数器 */
  var animIdCounter = 0;

  /** @type {number} 帧回调ID计数器 */
  var frameIdCounter = 0;

  /** @type {number|null} requestAnimationFrame句柄 */
  var rafHandle = null;

  /**
   * 获取缓动函数
   * @param {string|Function} easing - 缓动函数名或自定义函数
   * @returns {Function}
   */
  function getEasing(easing) {
    if (typeof easing === 'function') return easing;
    if (typeof easing === 'string' && window.Easing && typeof window.Easing[easing] === 'function') {
      return window.Easing[easing];
    }
    // 默认线性
    return function(t) { return t; };
  }

  /**
   * 主循环帧处理
   * @param {number} timestamp - 当前时间戳
   */
  function loop(timestamp) {
    if (!running) return;

    var dt = lastTime ? (timestamp - lastTime) / 1000 : 0.016;
    lastTime = timestamp;

    // 限制dt最大值，防止切tab后大跳
    if (dt > 0.1) dt = 0.016;

    // 处理活动动画
    var toRemove = [];
    animations.forEach(function(anim, id) {
      // 处理延迟
      if (anim.delayRemaining > 0) {
        anim.delayRemaining -= dt * 1000;
        return;
      }

      anim.elapsed += dt * 1000;
      var rawProgress = Math.min(anim.elapsed / anim.duration, 1);
      var easedProgress = anim.easing(rawProgress);

      try {
        anim.callback(easedProgress, dt);
      } catch (e) {
        console.error('[AnimationEngine] 动画回调出错:', e);
        toRemove.push(id);
        return;
      }

      if (rawProgress >= 1) {
        if (anim.loop) {
          anim.elapsed = 0;
        } else {
          toRemove.push(id);
          if (typeof anim.onComplete === 'function') {
            try {
              anim.onComplete();
            } catch (e) {
              console.error('[AnimationEngine] onComplete回调出错:', e);
            }
          }
        }
      }
    });

    // 移除已完成的动画
    for (var i = 0; i < toRemove.length; i++) {
      animations.delete(toRemove[i]);
    }

    // 执行帧回调
    frameCallbacks.forEach(function(callback) {
      try {
        callback(dt, timestamp);
      } catch (e) {
        console.error('[AnimationEngine] 帧回调出错:', e);
      }
    });

    rafHandle = requestAnimationFrame(loop);
  }

  return {
    /**
     * 启动动画主循环
     */
    start: function() {
      if (running) return;
      running = true;
      lastTime = 0;
      rafHandle = requestAnimationFrame(loop);
    },

    /**
     * 停止动画主循环
     */
    stop: function() {
      running = false;
      if (rafHandle !== null) {
        cancelAnimationFrame(rafHandle);
        rafHandle = null;
      }
      lastTime = 0;
    },

    /**
     * 注册补间动画
     * @param {number} duration - 动画时长(ms)
     * @param {Function} callback - 动画回调 callback(progress, deltaTime)
     * @param {Object} [options] - 配置选项
     * @param {string|Function} [options.easing='linear'] - 缓动函数
     * @param {boolean} [options.loop=false] - 是否循环
     * @param {number} [options.delay=0] - 延迟开始(ms)
     * @param {Function} [options.onComplete] - 完成回调
     * @returns {number} 动画ID
     */
    add: function(duration, callback, options) {
      if (typeof duration !== 'number' || duration <= 0) {
        console.warn('[AnimationEngine] add() 需要有效的持续时间');
        return -1;
      }
      if (typeof callback !== 'function') {
        console.warn('[AnimationEngine] add() 需要回调函数');
        return -1;
      }

      options = options || {};
      var id = ++animIdCounter;

      animations.set(id, {
        duration: duration,
        callback: callback,
        easing: getEasing(options.easing),
        loop: !!options.loop,
        delay: options.delay || 0,
        delayRemaining: options.delay || 0,
        onComplete: options.onComplete || null,
        elapsed: 0
      });

      // 确保主循环运行
      if (!running) {
        this.start();
      }

      return id;
    },

    /**
     * 移除指定动画
     * @param {number} id - 动画ID
     */
    remove: function(id) {
      animations.delete(id);
    },

    /**
     * 清空所有动画
     */
    removeAll: function() {
      animations.clear();
    },

    /**
     * 渐入动画
     * @param {HTMLElement} element - 目标元素
     * @param {number} [duration=300] - 动画时长(ms)
     * @returns {Promise<void>}
     */
    fadeIn: function(element, duration) {
      if (!element) return Promise.resolve();
      duration = duration || 300;

      element.style.opacity = '0';
      element.style.display = '';

      var self = this;
      return new Promise(function(resolve) {
        self.add(duration, function(progress) {
          element.style.opacity = String(progress);
        }, {
          easing: 'easeOutCubic',
          onComplete: function() {
            element.style.opacity = '1';
            resolve();
          }
        });
      });
    },

    /**
     * 渐出动画
     * @param {HTMLElement} element - 目标元素
     * @param {number} [duration=300] - 动画时长(ms)
     * @returns {Promise<void>}
     */
    fadeOut: function(element, duration) {
      if (!element) return Promise.resolve();
      duration = duration || 300;

      return new Promise(function(resolve) {
        var self = this;
        this.add(duration, function(progress) {
          element.style.opacity = String(1 - progress);
        }.bind(this), {
          easing: 'easeInCubic',
          onComplete: function() {
            element.style.opacity = '0';
            resolve();
          }
        });
      }.bind(this));
    },

    /**
     * 滑动到指定位置
     * @param {HTMLElement} element - 目标元素
     * @param {number} x - 目标X坐标
     * @param {number} y - 目标Y坐标
     * @param {number} [duration=400] - 动画时长(ms)
     * @returns {Promise<void>}
     */
    slideTo: function(element, x, y, duration) {
      if (!element) return Promise.resolve();
      duration = duration || 400;

      var startX = parseFloat(element.style.transform ? element.style.transform.replace(/.*translateX\(([^)]+)\).*/, '$1') : 0) || 0;
      var startY = parseFloat(element.style.transform ? element.style.transform.replace(/.*translateY\(([^)]+)\).*/, '$1') : 0) || 0;

      return new Promise(function(resolve) {
        this.add(duration, function(progress) {
          var cx = startX + (x - startX) * progress;
          var cy = startY + (y - startY) * progress;
          element.style.transform = 'translate(' + cx + 'px, ' + cy + 'px)';
        }, {
          easing: 'easeOutCubic',
          onComplete: function() {
            element.style.transform = 'translate(' + x + 'px, ' + y + 'px)';
            resolve();
          }
        });
      }.bind(this));
    },

    /**
     * 缩放到指定比例
     * @param {HTMLElement} element - 目标元素
     * @param {number} scale - 目标缩放比例
     * @param {number} [duration=300] - 动画时长(ms)
     * @returns {Promise<void>}
     */
    scaleTo: function(element, scale, duration) {
      if (!element) return Promise.resolve();
      duration = duration || 300;

      var currentTransform = element.style.transform || '';
      var currentScale = 1;
      var scaleMatch = currentTransform.match(/scale\(([^)]+)\)/);
      if (scaleMatch) {
        currentScale = parseFloat(scaleMatch[1]) || 1;
      }

      return new Promise(function(resolve) {
        this.add(duration, function(progress) {
          var s = currentScale + (scale - currentScale) * progress;
          element.style.transform = 'scale(' + s + ')';
        }, {
          easing: 'easeOutBack',
          onComplete: function() {
            element.style.transform = 'scale(' + scale + ')';
            resolve();
          }
        });
      }.bind(this));
    },

    /**
     * 顺序执行动画数组
     * @param {Array<Function>} anims - 动画函数数组，每个返回Promise
     * @returns {Promise<void>}
     */
    sequence: function(anims) {
      if (!Array.isArray(anims) || anims.length === 0) {
        return Promise.resolve();
      }
      return anims.reduce(function(chain, animFn) {
        return chain.then(function() {
          return typeof animFn === 'function' ? animFn() : Promise.resolve();
        });
      }, Promise.resolve());
    },

    /**
     * 并行执行动画数组
     * @param {Array<Function>} anims - 动画函数数组，每个返回Promise
     * @returns {Promise<void>}
     */
    parallel: function(anims) {
      if (!Array.isArray(anims) || anims.length === 0) {
        return Promise.resolve();
      }
      var promises = anims.map(function(animFn) {
        return typeof animFn === 'function' ? animFn() : Promise.resolve();
      });
      return Promise.all(promises).then(function() {});
    },

    /**
     * 注册帧回调（每帧执行）
     * @param {Function} callback - 帧回调 callback(dt, timestamp)
     * @returns {number} 回调ID
     */
    onFrame: function(callback) {
      if (typeof callback !== 'function') {
        console.warn('[AnimationEngine] onFrame() 需要回调函数');
        return -1;
      }
      var id = ++frameIdCounter;
      frameCallbacks.set(id, callback);

      // 确保主循环运行
      if (!running) {
        this.start();
      }

      return id;
    },

    /**
     * 移除帧回调
     * @param {number} id - 回调ID
     */
    offFrame: function(id) {
      frameCallbacks.delete(id);
    },

    /**
     * 获取活动动画数量
     * @returns {number}
     */
    getActiveCount: function() {
      return animations.size;
    },

    /**
     * 是否有动画在运行
     * @returns {boolean}
     */
    isRunning: function() {
      return running;
    }
  };
})();

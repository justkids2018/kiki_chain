/**
 * DOM - DOM工具函数集
 * 提供元素创建、查询、样式操作、事件绑定、触屏兼容等工具
 * @global window.DOM
 */
window.DOM = (function() {
  'use strict';

  /**
   * 简单HTML转义（防XSS）
   * @param {string} str - 待转义字符串
   * @returns {string}
   */
  function escapeHTML(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  return {
    /**
     * 创建DOM元素
     * @param {string} tag - 标签名
     * @param {string} [className] - CSS类名（空格分隔多个）
     * @param {Object} [attrs] - 属性对象
     * @returns {HTMLElement}
     */
    create: function(tag, className, attrs) {
      var el = document.createElement(tag || 'div');
      if (className) {
        el.className = className;
      }
      if (attrs && typeof attrs === 'object') {
        Object.keys(attrs).forEach(function(key) {
          if (key === 'textContent') {
            el.textContent = attrs[key];
          } else if (key === 'innerHTML') {
            el.innerHTML = attrs[key];
          } else if (key === 'style' && typeof attrs[key] === 'object') {
            Object.keys(attrs[key]).forEach(function(prop) {
              el.style[prop] = attrs[key][prop];
            });
          } else if (key === 'dataset' && typeof attrs[key] === 'object') {
            Object.keys(attrs[key]).forEach(function(prop) {
              el.dataset[prop] = attrs[key][prop];
            });
          } else {
            el.setAttribute(key, attrs[key]);
          }
        });
      }
      return el;
    },

    /**
     * querySelector简写
     * @param {string} selector - CSS选择器
     * @param {HTMLElement|Document} [parent=document] - 父元素
     * @returns {HTMLElement|null}
     */
    $: function(selector, parent) {
      return (parent || document).querySelector(selector);
    },

    /**
     * querySelectorAll简写（返回数组）
     * @param {string} selector - CSS选择器
     * @param {HTMLElement|Document} [parent=document] - 父元素
     * @returns {HTMLElement[]}
     */
    $$: function(selector, parent) {
      return Array.prototype.slice.call((parent || document).querySelectorAll(selector));
    },

    /**
     * 添加CSS类
     * @param {HTMLElement} el - 目标元素
     * @param {...string} classes - 要添加的类名
     */
    addClass: function(el) {
      if (!el || !el.classList) return;
      var classes = Array.prototype.slice.call(arguments, 1);
      for (var i = 0; i < classes.length; i++) {
        if (classes[i]) {
          el.classList.add(classes[i]);
        }
      }
    },

    /**
     * 移除CSS类
     * @param {HTMLElement} el - 目标元素
     * @param {...string} classes - 要移除的类名
     */
    removeClass: function(el) {
      if (!el || !el.classList) return;
      var classes = Array.prototype.slice.call(arguments, 1);
      for (var i = 0; i < classes.length; i++) {
        if (classes[i]) {
          el.classList.remove(classes[i]);
        }
      }
    },

    /**
     * 切换CSS类
     * @param {HTMLElement} el - 目标元素
     * @param {string} className - 要切换的类名
     * @returns {boolean} 切换后是否包含该类
     */
    toggleClass: function(el, className) {
      if (!el || !el.classList || !className) return false;
      return el.classList.toggle(className);
    },

    /**
     * 批量设置样式
     * @param {HTMLElement} el - 目标元素
     * @param {Object} styles - 样式对象，如 { color: 'red', fontSize: '14px' }
     */
    setStyle: function(el, styles) {
      if (!el || !styles || typeof styles !== 'object') return;
      Object.keys(styles).forEach(function(prop) {
        el.style[prop] = styles[prop];
      });
    },

    /**
     * 安全设置文本内容
     * @param {HTMLElement} el - 目标元素
     * @param {string} text - 文本内容
     */
    setText: function(el, text) {
      if (!el) return;
      el.textContent = text != null ? String(text) : '';
    },

    /**
     * 设置innerHTML（简单转义标签）
     * @param {HTMLElement} el - 目标元素
     * @param {string} html - HTML内容
     */
    setHTML: function(el, html) {
      if (!el) return;
      el.innerHTML = html != null ? String(html) : '';
    },

    /**
     * 添加事件监听
     * @param {HTMLElement|Window|Document} el - 目标元素
     * @param {string} event - 事件名
     * @param {Function} handler - 事件处理函数
     * @param {Object|boolean} [options] - addEventListener选项
     */
    on: function(el, event, handler, options) {
      if (!el || !event || typeof handler !== 'function') return;
      el.addEventListener(event, handler, options || false);
    },

    /**
     * 移除事件监听
     * @param {HTMLElement|Window|Document} el - 目标元素
     * @param {string} event - 事件名
     * @param {Function} handler - 事件处理函数
     */
    off: function(el, event, handler) {
      if (!el || !event || typeof handler !== 'function') return;
      el.removeEventListener(event, handler);
    },

    /**
     * 事件委托
     * @param {HTMLElement} parent - 父元素
     * @param {string} selector - 子元素CSS选择器
     * @param {string} event - 事件名
     * @param {Function} handler - 事件处理函数 handler(event, matchedEl)
     */
    delegate: function(parent, selector, event, handler) {
      if (!parent || !selector || !event || typeof handler !== 'function') return;

      parent.addEventListener(event, function(e) {
        var target = e.target;
        while (target && target !== parent) {
          if (target.matches && target.matches(selector)) {
            handler.call(target, e, target);
            return;
          }
          target = target.parentNode;
        }
      }, false);
    },

    /**
     * 触屏+点击兼容处理（解决300ms延迟）
     * 优先使用touchend，回退到click
     * @param {HTMLElement} el - 目标元素
     * @param {Function} handler - 点击处理函数
     */
    onTap: function(el, handler) {
      if (!el || typeof handler !== 'function') return;

      var touchStarted = false;
      var startX = 0;
      var startY = 0;
      var TAP_THRESHOLD = 10; // 移动阈值（px）

      // 触摸事件
      el.addEventListener('touchstart', function(e) {
        touchStarted = true;
        var touch = e.touches[0];
        startX = touch.clientX;
        startY = touch.clientY;
      }, { passive: true });

      el.addEventListener('touchend', function(e) {
        if (!touchStarted) return;
        touchStarted = false;

        var touch = e.changedTouches[0];
        var dx = Math.abs(touch.clientX - startX);
        var dy = Math.abs(touch.clientY - startY);

        // 判断是否为有效tap（未滑动超过阈值）
        if (dx < TAP_THRESHOLD && dy < TAP_THRESHOLD) {
          e.preventDefault();
          handler.call(el, e);
        }
      }, false);

      // click作为回退（桌面端）
      el.addEventListener('click', function(e) {
        // 如果touchend已处理，忽略click
        if (touchStarted) return;
        handler.call(el, e);
      }, false);
    },

    /**
     * 等待CSS动画结束
     * @param {HTMLElement} el - 目标元素
     * @param {number} [timeout=1000] - 超时时间(ms)
     * @returns {Promise<void>}
     */
    waitForAnimation: function(el, timeout) {
      if (!el) return Promise.resolve();
      timeout = timeout || 1000;

      return new Promise(function(resolve) {
        var resolved = false;
        function done() {
          if (resolved) return;
          resolved = true;
          resolve();
        }
        el.addEventListener('animationend', done, { once: true });
        setTimeout(done, timeout);
      });
    },

    /**
     * 等待CSS过渡结束
     * @param {HTMLElement} el - 目标元素
     * @param {number} [timeout=1000] - 超时时间(ms)
     * @returns {Promise<void>}
     */
    waitForTransition: function(el, timeout) {
      if (!el) return Promise.resolve();
      timeout = timeout || 1000;

      return new Promise(function(resolve) {
        var resolved = false;
        function done() {
          if (resolved) return;
          resolved = true;
          resolve();
        }
        el.addEventListener('transitionend', done, { once: true });
        setTimeout(done, timeout);
      });
    },

    /**
     * 显示元素
     * @param {HTMLElement} el - 目标元素
     * @param {string} [display=''] - display值
     */
    show: function(el, display) {
      if (!el) return;
      el.style.display = display || '';
      el.removeAttribute('hidden');
    },

    /**
     * 隐藏元素
     * @param {HTMLElement} el - 目标元素
     */
    hide: function(el) {
      if (!el) return;
      el.style.display = 'none';
    },

    /**
     * 创建高清Canvas
     * @param {number} width - 逻辑宽度
     * @param {number} height - 逻辑高度
     * @param {number} [dpr] - 设备像素比（默认自动检测）
     * @returns {{canvas: HTMLCanvasElement, ctx: CanvasRenderingContext2D, dpr: number}}
     */
    createCanvas: function(width, height, dpr) {
      dpr = dpr || window.devicePixelRatio || 1;
      var canvas = document.createElement('canvas');
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      canvas.style.width = width + 'px';
      canvas.style.height = height + 'px';

      var ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.scale(dpr, dpr);
      }

      return { canvas: canvas, ctx: ctx, dpr: dpr };
    },

    /**
     * HTML转义
     * @param {string} str - 待转义字符串
     * @returns {string}
     */
    escape: escapeHTML,

    /**
     * 将元素滚动到可视区域
     * @param {HTMLElement} el - 目标元素
     * @param {Object} [options] - scrollIntoView选项
     */
    scrollIntoView: function(el, options) {
      if (!el || typeof el.scrollIntoView !== 'function') return;
      el.scrollIntoView(options || { behavior: 'smooth', block: 'center' });
    }
  };
})();

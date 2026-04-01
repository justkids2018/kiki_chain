/**
 * SceneManager - 场景管理器（核心状态机）
 * 管理场景的注册、切换、栈操作和转场动画
 * @global window.SceneManager
 */
window.SceneManager = (function() {
  'use strict';

  /** @type {Object<string, Object>} 注册的场景实例 */
  let scenes = {};

  /** @type {string[]} 场景栈（存储场景ID） */
  let sceneStack = [];

  /** @type {string|null} 当前活动场景ID */
  let currentScene = null;

  /** @type {HTMLElement|null} DOM容器 */
  let container = null;

  /** @type {boolean} 转场锁，防止快速连续切换 */
  let isTransitioning = false;

  /**
   * 等待元素的CSS动画结束
   * @param {HTMLElement} el - 目标元素
   * @param {number} [timeout=1000] - 超时时间(ms)
   * @returns {Promise<void>}
   */
  function waitAnimationEnd(el, timeout) {
    timeout = timeout || 1000;
    return new Promise(function(resolve) {
      var resolved = false;
      function done() {
        if (resolved) return;
        resolved = true;
        resolve();
      }
      el.addEventListener('animationend', done, { once: true });
      // 超时保底，防止动画未触发时阻塞
      setTimeout(done, timeout);
    });
  }

  /**
   * 创建场景容器DOM
   * @param {string} sceneId - 场景ID
   * @returns {HTMLElement}
   */
  function createSceneContainer(sceneId) {
    var div = document.createElement('div');
    div.className = 'scene scene-entering';
    div.setAttribute('data-scene', sceneId);
    div.style.width = '100%';
    div.style.height = '100%';
    div.style.position = 'absolute';
    div.style.top = '0';
    div.style.left = '0';
    return div;
  }

  return {
    /**
     * 初始化场景管理器
     * @param {string} containerId - DOM容器元素的ID
     * @throws {Error} 容器不存在时抛出错误
     */
    init: function(containerId) {
      if (!containerId || typeof containerId !== 'string') {
        throw new Error('[SceneManager] init() 需要一个有效的容器ID');
      }
      container = document.getElementById(containerId);
      if (!container) {
        throw new Error('[SceneManager] 找不到容器元素: ' + containerId);
      }
      // 确保容器有定位上下文和完整尺寸
      var position = window.getComputedStyle(container).position;
      if (position === 'static') {
        container.style.position = 'relative';
      }
      container.style.overflow = 'hidden';
      container.style.width = '100%';
      container.style.height = '100%';
      scenes = {};
      sceneStack = [];
      currentScene = null;
      isTransitioning = false;
    },

    /**
     * 注册场景实例
     * 支持两种调用方式：
     *   register(id, sceneInstance) - 传递ID和场景实例
     *   register(sceneInstance) - 场景实例自带id属性
     * @param {string|Object} idOrScene - 场景ID或场景实例对象
     * @param {Object} [sceneInstance] - 场景实例对象（当第一个参数为ID时）
     */
    register: function(idOrScene, sceneInstance) {
      var id, scene;

      if (typeof idOrScene === 'string') {
        // register(id, sceneInstance) 形式
        id = idOrScene;
        scene = sceneInstance;
      } else if (idOrScene && typeof idOrScene === 'object') {
        // register(sceneInstance) 形式，场景对象自带id属性
        scene = idOrScene;
        id = scene.id;
      }

      if (!id || typeof id !== 'string') {
        console.warn('[SceneManager] register() 需要有效的场景ID');
        return;
      }
      if (!scene || typeof scene !== 'object') {
        console.warn('[SceneManager] register() 需要有效的场景实例');
        return;
      }
      scenes[id] = scene;
    },

    /**
     * 切换到指定场景（带转场动画）
     * @param {string} sceneId - 目标场景ID
     * @param {*} [data] - 传递给目标场景的数据
     * @returns {Promise<void>}
     */
    goto: function(sceneId, data) {
      var self = this;

      if (isTransitioning) {
        console.warn('[SceneManager] 转场进行中，忽略跳转请求: ' + sceneId);
        return Promise.resolve();
      }

      if (!scenes[sceneId]) {
        console.error('[SceneManager] 未注册的场景: ' + sceneId);
        return Promise.reject(new Error('未注册的场景: ' + sceneId));
      }

      if (!container) {
        console.error('[SceneManager] 未初始化，请先调用init()');
        return Promise.reject(new Error('SceneManager未初始化'));
      }

      isTransitioning = true;

      return Promise.resolve().then(function() {
        // 1. 调用当前场景的exit()
        if (currentScene && scenes[currentScene]) {
          var exitScene = scenes[currentScene];
          var exitContainer = container.querySelector('[data-scene="' + currentScene + '"]');

          // 添加离场动画类
          if (exitContainer) {
            exitContainer.classList.remove('scene-entering');
            exitContainer.classList.add('scene-exiting');
          }

          if (typeof exitScene.exit === 'function') {
            return Promise.resolve(exitScene.exit());
          }
        }
        return Promise.resolve();
      }).then(function() {
        // 2. 从DOM移除旧场景元素
        var oldContainer = container.querySelector('[data-scene="' + currentScene + '"]');
        if (oldContainer && oldContainer.parentNode) {
          oldContainer.parentNode.removeChild(oldContainer);
        }

        // 3. 创建新场景容器
        var newContainer = createSceneContainer(sceneId);
        container.appendChild(newContainer);

        // 4. 调用新场景的init(container)
        var newScene = scenes[sceneId];
        if (typeof newScene.init === 'function') {
          newScene.init(newContainer);
        }

        // 5. 调用新场景的enter(data)
        var enterPromise = Promise.resolve();
        if (typeof newScene.enter === 'function') {
          enterPromise = Promise.resolve(newScene.enter(data));
        }

        return enterPromise.then(function() {
          // 6. 等待入场动画完成（超时略大于动画时长800ms）
          return waitAnimationEnd(newContainer, 1200);
        }).then(function() {
          // 7. 移除动画类，确保场景可见
          newContainer.classList.remove('scene-entering');
          newContainer.classList.add('scene-active');
          newContainer.style.opacity = '1';
        });
      }).then(function() {
        // 8. 更新场景栈
        if (currentScene) {
          sceneStack.push(currentScene);
        }
        currentScene = sceneId;
        isTransitioning = false;
      }).catch(function(err) {
        isTransitioning = false;
        console.error('[SceneManager] 场景切换出错:', err);
        throw err;
      });
    },

    /**
     * 返回上一场景
     * @returns {Promise<void>}
     */
    back: function() {
      if (sceneStack.length === 0) {
        console.warn('[SceneManager] 场景栈为空，无法返回');
        return Promise.resolve();
      }
      var prevSceneId = sceneStack.pop();
      // 从栈中弹出后直接goto，但不要再push到栈里
      // 需要临时移除currentScene避免重复push
      var tempCurrent = currentScene;
      currentScene = null;

      var self = this;
      return this.goto(prevSceneId).then(function() {
        // goto会把null push进栈，需要移除
        var idx = sceneStack.indexOf(null);
        if (idx !== -1) {
          sceneStack.splice(idx, 1);
        }
        // 不需要把tempCurrent放回栈
      });
    },

    /**
     * 获取当前活动场景ID
     * @returns {string|null}
     */
    getCurrent: function() {
      return currentScene;
    },

    /**
     * 获取场景栈（副本）
     * @returns {string[]}
     */
    getStack: function() {
      return sceneStack.slice();
    },

    /**
     * 获取已注册的场景列表
     * @returns {string[]}
     */
    getRegisteredScenes: function() {
      return Object.keys(scenes);
    },

    /**
     * 是否正在转场
     * @returns {boolean}
     */
    isTransitioning: function() {
      return isTransitioning;
    },

    /**
     * 获取DOM容器
     * @returns {HTMLElement|null}
     */
    getContainer: function() {
      return container;
    },

    /**
     * 销毁所有场景并重置状态
     */
    destroy: function() {
      // 销毁所有场景
      Object.keys(scenes).forEach(function(id) {
        var scene = scenes[id];
        if (typeof scene.destroy === 'function') {
          try {
            scene.destroy();
          } catch (e) {
            console.warn('[SceneManager] 销毁场景出错: ' + id, e);
          }
        }
      });

      // 清空容器
      if (container) {
        container.innerHTML = '';
      }

      scenes = {};
      sceneStack = [];
      currentScene = null;
      isTransitioning = false;
    }
  };
})();

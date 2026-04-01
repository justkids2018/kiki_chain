/**
 * 魔法森林大冒险 - 应用入口
 * PDP儿童性格测试应用主初始化脚本
 */
(function() {
  'use strict';

  // 应用配置
  const CONFIG = {
    version: '1.0.0',
    debug: false,
    defaultScene: 'welcome',
  };

  /**
   * 应用初始化
   */
  async function init() {
    try {
      if (CONFIG.debug) {
        console.log('[MagicForest] Initializing v' + CONFIG.version);
      }

      // 1. 设置rem基准 & 监听窗口变化
      Device.setRemBase();
      Device.onResize(function() {
        Device.setRemBase();
      });

      // 2. 初始化核心引擎
      SceneManager.init('app');
      AudioManager.init();
      AnimationEngine.start();
      ScoreEngine.reset();

      // 3. 注册所有场景
      SceneManager.register('welcome', WelcomeScene);
      SceneManager.register('prologue', PrologueScene);
      SceneManager.register('story', StoryScene);
      SceneManager.register('climax', ClimaxScene);
      SceneManager.register('result', ResultScene);
      SceneManager.register('share', ShareScene);

      // 4. 隐藏loading，显示app
      await hideLoading();

      // 5. 跳转到默认场景
      await SceneManager.goto(CONFIG.defaultScene);

      console.log('[MagicForest] App initialized successfully v' + CONFIG.version);
    } catch (error) {
      console.error('[MagicForest] Init failed:', error);
      showError('魔法施展失败了，请刷新重试~');
    }
  }

  /**
   * 隐藏loading画面，渐显app容器
   * @returns {Promise}
   */
  function hideLoading() {
    return new Promise(function(resolve) {
      var loading = document.getElementById('loading-screen');
      var app = document.getElementById('app');

      if (!loading || !app) {
        resolve();
        return;
      }

      loading.style.transition = 'opacity 0.5s ease';
      loading.style.opacity = '0';

      setTimeout(function() {
        loading.style.display = 'none';
        app.style.display = 'block';
        app.style.width = '100%';
        app.style.height = '100%';
        app.style.position = 'relative';
        app.style.overflow = 'hidden';
        app.style.opacity = '0';
        app.style.transition = 'opacity 0.3s ease';

        // 触发reflow确保transition生效
        void app.offsetHeight;
        app.style.opacity = '1';

        setTimeout(function() {
          resolve();
        }, 300);
      }, 500);
    });
  }

  /**
   * 显示友好的错误提示
   * @param {string} message - 错误信息
   */
  function showError(message) {
    // 隐藏loading
    var loading = document.getElementById('loading-screen');
    if (loading) {
      loading.style.display = 'none';
    }

    // 创建错误提示覆盖层
    var overlay = document.createElement('div');
    overlay.className = 'error-overlay';
    overlay.innerHTML =
      '<div class="error-icon">🌙</div>' +
      '<div class="error-message">' + message + '</div>' +
      '<button class="error-retry" onclick="location.reload()">重新施展魔法</button>';

    document.body.appendChild(overlay);
  }

  // DOM Ready后启动
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

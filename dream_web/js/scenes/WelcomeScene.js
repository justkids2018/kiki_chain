/**
 * WelcomeScene - 欢迎页（视觉小说风格）
 * 上：漫画主视觉 / 下：标题+开始按钮
 */
window.WelcomeScene = {
  id: 'welcome',
  container: null,
  _running: false,

  init: function(container) {
    this.container = container;
    container.className = 'scene scene-welcome scene-entering';
    container.innerHTML = '';

    // 漫画画面
    var comic = document.createElement('div');
    comic.className = 'welcome-comic';
    var img = document.createElement('img');
    img.src = 'assets/welcome/welcome.jpg';
    img.alt = '魔法森林的四位守护者';
    img.style.pointerEvents = 'none';
    comic.appendChild(img);

    // 声音按钮
    var soundBtn = document.createElement('button');
    soundBtn.className = 'vn-sound-btn';
    soundBtn.textContent = window.AudioManager && AudioManager.isEnabled() ? '🔊' : '🔇';
    soundBtn.onclick = function() {
      if (window.AudioManager) {
        var muted = AudioManager.toggle();
        soundBtn.textContent = muted ? '🔇' : '🔊';
        soundBtn.className = 'vn-sound-btn' + (muted ? ' muted' : '');
      }
    };
    comic.appendChild(soundBtn);

    container.appendChild(comic);

    // 下半区
    var bottom = document.createElement('div');
    bottom.className = 'welcome-bottom';

    var title = document.createElement('div');
    title.className = 'welcome-title';
    title.textContent = '魔法森林大冒险';
    bottom.appendChild(title);

    var subtitle = document.createElement('div');
    subtitle.className = 'welcome-subtitle';
    subtitle.textContent = '发现你的动物守护者';
    bottom.appendChild(subtitle);

    var btn = document.createElement('button');
    btn.className = 'welcome-start-btn';
    btn.textContent = '开始冒险';
    btn.id = 'welcome-start-btn';
    bottom.appendChild(btn);

    var tip = document.createElement('div');
    tip.className = 'welcome-age-tip';
    tip.textContent = '适合 6-12 岁小朋友';
    bottom.appendChild(tip);

    container.appendChild(bottom);
  },

  enter: function() {
    var self = this;
    self._running = true;

    // 标题弹入动画
    var title = self.container.querySelector('.welcome-title');
    if (title) title.style.animation = 'bounceIn 0.8s cubic-bezier(0.68,-0.55,0.265,1.55) forwards';

    // 副标题淡入
    var subtitle = self.container.querySelector('.welcome-subtitle');
    if (subtitle) {
      subtitle.style.opacity = '0';
      subtitle.style.animation = 'fadeIn 0.5s ease 0.4s forwards';
    }

    // 按钮延迟淡入
    var btn = document.getElementById('welcome-start-btn');
    if (btn) {
      btn.style.opacity = '0';
      btn.style.animation = 'fadeIn 0.5s ease 0.8s forwards';
      btn.addEventListener('click', function() {
        btn.style.transform = 'scale(0.93)';
        setTimeout(function() {
          if (window.SceneManager) SceneManager.goto('prologue');
        }, 150);
      });
    }

    return Promise.resolve();
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

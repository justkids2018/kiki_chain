/**
 * PrologueScene - 序章（视觉小说风格）
 * 上：漫画画面 / 下：逐字对话文本，点击推进
 */
window.PrologueScene = {
  id: 'prologue',
  container: null,
  _running: false,
  _dialogIndex: 0,
  _typing: false,
  _skipResolve: null,

  init: function(container) {
    this.container = container;
    container.className = 'scene scene-prologue scene-entering';
    container.innerHTML = '';

    // 漫画区
    var comic = document.createElement('div');
    comic.className = 'vn-comic';
    comic.id = 'prologue-comic';
    var img = document.createElement('img');
    img.src = 'assets/welcome/welcome.jpg';
    img.alt = '魔法森林';
    comic.appendChild(img);

    // 声音按钮
    var soundBtn = document.createElement('button');
    soundBtn.className = 'vn-sound-btn';
    soundBtn.id = 'sound-toggle';
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

    // 文字面板
    var panel = document.createElement('div');
    panel.className = 'vn-panel';
    panel.id = 'prologue-panel';

    // 对话框
    var frame = document.createElement('div');
    frame.className = 'vn-dialog-frame';
    frame.id = 'prologue-dialog-frame';

    var textBox = document.createElement('div');
    textBox.className = 'vn-text-box';
    textBox.id = 'prologue-text';
    frame.appendChild(textBox);
    panel.appendChild(frame);

    var hint = document.createElement('div');
    hint.className = 'vn-continue-hint';
    hint.id = 'prologue-hint';
    hint.textContent = '点击继续';
    hint.style.display = 'none';
    panel.appendChild(hint);

    // 开始冒险按钮（最后显示）
    var btn = document.createElement('button');
    btn.className = 'welcome-start-btn';
    btn.id = 'prologue-continue';
    btn.textContent = '开始冒险';
    btn.style.display = 'none';
    btn.style.margin = '12px auto 0';
    btn.style.fontSize = '16px';
    btn.style.padding = '12px 40px';
    panel.appendChild(btn);

    container.appendChild(panel);
  },

  enter: function() {
    var self = this;
    self._running = true;
    self._dialogIndex = 0;

    var dialogues = (window.DialogData && DialogData.prologueDialogues) || [];

    // 启动背景音乐
    if (window.AudioManager) AudioManager.playBGM();

    // 整个场景容器都可点击推进（不仅仅是下半区 panel）
    self.container.addEventListener('click', function(e) {
      console.log('[Prologue] click event, target:', e.target.tagName, 'skipResolve:', !!self._skipResolve, 'typing:', self._typing);
      // 不要拦截按钮的点击
      if (e.target.tagName === 'BUTTON') return;
      if (self._skipResolve) {
        console.log('[Prologue] calling skipResolve');
        self._skipResolve();
      }
    });

    self._playDialogues(dialogues).then(function() {
      if (!self._running) return;
      var btn = document.getElementById('prologue-continue');
      var hint = document.getElementById('prologue-hint');
      if (hint) hint.style.display = 'none';
      if (btn) {
        btn.style.display = 'block';
        btn.style.opacity = '0';
        btn.style.animation = 'fadeIn 0.5s ease forwards';
        btn.onclick = function() {
          if (window.SceneManager) SceneManager.goto('story', { sceneIndex: 0 });
        };
      }
    });

    return Promise.resolve();
  },

  _playDialogues: function(dialogues) {
    var self = this;
    var index = 0;

    function next() {
      if (!self._running || index >= dialogues.length) return Promise.resolve();
      var line = dialogues[index];
      self._updateSpeaker(line);

      // 播放对应的预生成语音
      var voiceFile = 'assets/audio/voice/prologue_' + (index < 10 ? '0' : '') + index + '.mp3';
      if (window.AudioManager) AudioManager.playVoice(voiceFile);

      return self._typeText(line.text).then(function() {
        index++;
        return self._waitForClick().then(function() {
          // 点击时停止当前语音
          if (window.AudioManager) AudioManager.stopVoice();
          if (index < dialogues.length) {
            return next();
          }
          return Promise.resolve();
        });
      });
    }
    return next();
  },

  _updateSpeaker: function(line) {
    var old = this.container.querySelector('.vn-speaker');
    if (old) old.remove();

    if (line.speaker === 'narrator') return;

    var frame = document.getElementById('prologue-dialog-frame');
    var textBox = document.getElementById('prologue-text');
    if (!frame) return;

    var names = { tiger: '勇勇', peacock: '彩彩', koala: '暖暖', owl: '慧慧' };

    var bubble = document.createElement('div');
    bubble.className = 'vn-speaker';

    var avatar = document.createElement('img');
    avatar.className = 'vn-speaker-avatar ' + line.speaker;
    avatar.src = 'assets/avatars/' + line.speaker + '.jpg';
    avatar.alt = names[line.speaker] || '';
    bubble.appendChild(avatar);

    var info = document.createElement('div');
    info.className = 'vn-speaker-info';
    var nameEl = document.createElement('div');
    nameEl.className = 'vn-speaker-name ' + line.speaker;
    nameEl.textContent = names[line.speaker] || line.speaker;
    info.appendChild(nameEl);
    bubble.appendChild(info);

    if (textBox) {
      frame.insertBefore(bubble, textBox);
    }
  },

  _typeText: function(text) {
    var self = this;
    var el = document.getElementById('prologue-text');
    var hint = document.getElementById('prologue-hint');
    if (!el) return Promise.resolve();

    el.textContent = '';
    el.classList.add('typing');
    if (hint) hint.style.display = 'none';
    self._typing = true;

    return new Promise(function(resolve) {
      var i = 0;
      var skipped = false;

      self._skipResolve = function() {
        if (!skipped) {
          skipped = true;
          el.textContent = text;
          el.classList.remove('typing');
          self._typing = false;
          self._skipResolve = null;
          resolve();
        }
      };

      function tick() {
        if (skipped || !self._running) return;
        if (i < text.length) {
          el.textContent += text[i];
          i++;
          setTimeout(tick, 45);
        } else {
          el.classList.remove('typing');
          self._typing = false;
          // 不清除 _skipResolve，让 _waitForClick 接管
          resolve();
        }
      }
      tick();
    });
  },

  _waitForClick: function() {
    var self = this;
    var hint = document.getElementById('prologue-hint');
    if (hint) hint.style.display = 'block';
    console.log('[Prologue] _waitForClick: waiting for click...');

    return new Promise(function(resolve) {
      self._skipResolve = function() {
        console.log('[Prologue] _waitForClick: resolved!');
        if (hint) hint.style.display = 'none';
        self._skipResolve = null;
        resolve();
      };
    });
  },

  exit: function() {
    this._running = false;
    if (window.AudioManager) AudioManager.stop();
    return Promise.resolve();
  },

  destroy: function() {
    this._running = false;
    this.container = null;
  }
};

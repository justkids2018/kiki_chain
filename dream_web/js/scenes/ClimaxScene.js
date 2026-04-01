/**
 * ClimaxScene - 高潮对决（视觉小说风格）
 * 上：高潮漫画画面 / 下：自动/点击推进对话
 */
window.ClimaxScene = {
  id: 'climax',
  container: null,
  _running: false,
  _typing: false,
  _skipResolve: null,

  init: function(container) {
    this.container = container;
    container.className = 'scene scene-climax scene-entering';
    container.innerHTML = '';

    // 漫画区
    var comic = document.createElement('div');
    comic.className = 'vn-comic';
    comic.id = 'climax-comic';
    var img = document.createElement('img');
    img.src = 'assets/story/climax_battle.jpg';
    img.alt = '高潮对决';
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

    // 文字面板
    var panel = document.createElement('div');
    panel.className = 'vn-panel';
    panel.id = 'climax-panel';

    var frame = document.createElement('div');
    frame.className = 'vn-dialog-frame';
    frame.id = 'climax-dialog-frame';

    var textBox = document.createElement('div');
    textBox.className = 'vn-text-box';
    textBox.id = 'climax-text';
    frame.appendChild(textBox);
    panel.appendChild(frame);

    container.appendChild(panel);
  },

  enter: function() {
    var self = this;
    self._running = true;

    var panel = document.getElementById('climax-panel');
    // 点击推进（整个场景区域）
    self.container.addEventListener('click', function(e) {
      if (e.target.tagName === 'BUTTON') return;
      if (self._skipResolve) {
        self._skipResolve();
      }
    });

    var dialogues = (window.DialogData && DialogData.climaxDialogues) || [];
    self._playDialogues(dialogues).then(function() {
      if (!self._running) return;
      return self._wait(800);
    }).then(function() {
      if (window.SceneManager) SceneManager.goto('result');
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

      // 播放预生成语音（只有前8条有预生成）
      if (index < 8) {
        var voiceFile = 'assets/audio/voice/climax_' + (index < 10 ? '0' : '') + index + '.mp3';
        if (window.AudioManager) AudioManager.playVoice(voiceFile);
      }

      return self._showText(line.text).then(function() {
        index++;
        if (index < dialogues.length) {
          return self._waitForClick().then(function() {
            if (window.AudioManager) AudioManager.stopVoice();
            return next();
          });
        }
        return Promise.resolve();
      });
    }
    return next();
  },

  _updateSpeaker: function(line) {
    var old = this.container.querySelector('.vn-speaker');
    if (old) old.remove();
    if (!line || line.speaker === 'narrator') return;

    var frame = document.getElementById('climax-dialog-frame');
    var textBox = document.getElementById('climax-text');
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

  _showText: function(text) {
    var self = this;
    var el = document.getElementById('climax-text');
    if (!el) return Promise.resolve();

    el.textContent = '';
    el.classList.add('typing');
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
          el.textContent += text[i]; i++;
          setTimeout(tick, 35);
        } else {
          el.classList.remove('typing');
          self._typing = false;
          resolve();
        }
      }
      tick();
    });
  },

  _waitForClick: function() {
    var self = this;
    return new Promise(function(resolve) {
      self._skipResolve = resolve;
    });
  },

  _wait: function(ms) {
    return new Promise(function(r) { setTimeout(r, ms); });
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

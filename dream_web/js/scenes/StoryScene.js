/**
 * StoryScene - 冒险场景（视觉小说风格）
 * 上：场景漫画画面 + 进度条 / 下：对话文本 + 2x2图文选项
 */
window.StoryScene = {
  id: 'story',
  container: null,
  _currentIndex: 0,
  _running: false,
  _optionsLocked: false,
  _typing: false,
  _skipResolve: null,

  // 场景图片映射
  _sceneImages: [
    'assets/story/scene1_forest_rabbit.jpg',
    'assets/story/scene2_broken_bridge.jpg',
    'assets/story/scene3_crystal_cave.jpg',
    'assets/story/scene4_starlight_meadow.jpg',
    'assets/story/scene5_ancient_tree.jpg',
    'assets/story/scene6_rainbow_waterfall.jpg',
    'assets/story/scene7_shadow_valley.jpg',
    'assets/story/scene8_golden_peak.jpg'
  ],

  init: function(container) {
    this.container = container;
    container.className = 'scene scene-story scene-entering';
    container.innerHTML = '';

    // 漫画区
    var comic = document.createElement('div');
    comic.className = 'vn-comic';
    comic.id = 'story-comic';

    var img = document.createElement('img');
    img.id = 'story-scene-img';
    img.alt = '冒险场景';
    comic.appendChild(img);

    var progress = document.createElement('div');
    progress.className = 'vn-progress';
    progress.id = 'story-progress';
    comic.appendChild(progress);

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

    // 文字面板（可滚动）
    var panel = document.createElement('div');
    panel.className = 'vn-panel';
    panel.id = 'story-panel';

    // 对话框（带精美外框）
    var frame = document.createElement('div');
    frame.className = 'vn-dialog-frame';
    frame.id = 'story-dialog-frame';

    var textBox = document.createElement('div');
    textBox.className = 'vn-text-box';
    textBox.id = 'story-text';
    frame.appendChild(textBox);
    panel.appendChild(frame);

    // 选项区域（在对话框外面，不会重叠）
    var options = document.createElement('div');
    options.className = 'vn-options';
    options.id = 'story-options';
    options.style.display = 'none';
    panel.appendChild(options);

    container.appendChild(panel);
  },

  enter: function(data) {
    var self = this;
    self._running = true;
    self._optionsLocked = false;
    self._currentIndex = (data && data.sceneIndex !== undefined) ? data.sceneIndex : 0;

    var scenes = (window.StoryData && StoryData.scenes) || [];
    var sceneData = scenes[self._currentIndex];
    if (!sceneData) {
      if (window.SceneManager) SceneManager.goto('climax');
      return Promise.resolve();
    }

    // 设置场景图
    var img = document.getElementById('story-scene-img');
    if (img) {
      img.src = self._sceneImages[self._currentIndex] || self._sceneImages[0];
    }

    // 渲染进度
    self._renderProgress(self._currentIndex, scenes.length);

    // 点击推进
    var panel = document.getElementById('story-panel');
    // 点击推进（整个场景区域）
    self.container.addEventListener('click', function(e) {
      if (e.target.closest('.vn-option-card') || e.target.tagName === 'BUTTON') return;
      if (self._skipResolve) {
        self._skipResolve();
      }
    });

    // 播放场景
    self._playScene(sceneData);

    return Promise.resolve();
  },

  _renderProgress: function(current, total) {
    var el = document.getElementById('story-progress');
    if (!el) return;
    el.innerHTML = '';
    for (var i = 0; i < total; i++) {
      if (i > 0) {
        var line = document.createElement('div');
        line.className = 'line' + (i <= current ? ' done' : '');
        el.appendChild(line);
      }
      var dot = document.createElement('div');
      dot.className = 'dot';
      if (i < current) dot.className += ' done';
      else if (i === current) dot.className += ' now';
      el.appendChild(dot);
    }
  },

  _playScene: function(sceneData) {
    var self = this;
    var optionsEl = document.getElementById('story-options');
    if (optionsEl) optionsEl.style.display = 'none';

    // 播放旁白语音
    var sceneNum = self._currentIndex + 1;
    var narrationFile = 'assets/audio/voice/story_' + (sceneNum < 10 ? '0' : '') + sceneNum + '_narration.mp3';
    if (window.AudioManager) AudioManager.playVoice(narrationFile);

    // 步骤1：旁白
    self._showText(sceneData.narration, 'narrator').then(function() {
      if (!self._running) return;
      return self._waitForClick();
    }).then(function() {
      if (!self._running) return;
      // 点击后停止旁白语音
      if (window.AudioManager) AudioManager.stopVoice();
      // 步骤2：角色对话
      return self._playDialogSequence(sceneData.dialogue || []);
    }).then(function() {
      if (!self._running) return;
      // 步骤3：显示选项
      self._showOptions(sceneData);
    });
  },

  _playDialogSequence: function(dialogues) {
    var self = this;
    var index = 0;

    function next() {
      if (!self._running || index >= dialogues.length) return Promise.resolve();
      var line = dialogues[index];
      self._updateSpeaker(line);

      // 播放角色对话语音
      var sceneNum = self._currentIndex + 1;
      var dialogFile = 'assets/audio/voice/story_' + (sceneNum < 10 ? '0' : '') + sceneNum + '_dialog_' + index + '.mp3';
      if (window.AudioManager) AudioManager.playVoice(dialogFile);

      return self._showText(line.text, line.speaker).then(function() {
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
    // 清理旧的角色气泡
    var old = this.container.querySelector('.vn-speaker');
    if (old) old.remove();

    if (!line || line.speaker === 'narrator') return;

    var frame = document.getElementById('story-dialog-frame');
    var textBox = document.getElementById('story-text');
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

  _showText: function(text, speaker) {
    var self = this;
    var el = document.getElementById('story-text');
    if (!el || !text) return Promise.resolve();

    // 移除角色标签（旁白时）
    if (speaker === 'narrator') {
      var old = self.container.querySelector('.vn-speaker');
      if (old) old.remove();
    }

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
          el.textContent += text[i];
          i++;
          setTimeout(tick, 40);
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

  _showOptions: function(sceneData) {
    var self = this;
    var container = document.getElementById('story-options');
    var panel = document.getElementById('story-panel');
    var frame = document.getElementById('story-dialog-frame');
    var textBox = document.getElementById('story-text');
    if (!container || !panel) return;

    // 清理旧角色气泡
    var oldSpeaker = frame ? frame.querySelector('.vn-speaker') : null;
    if (oldSpeaker) oldSpeaker.remove();

    // 在对话框内显示完整题目
    if (textBox) {
      var lastDialog = sceneData.dialogue && sceneData.dialogue.length > 0
        ? sceneData.dialogue[sceneData.dialogue.length - 1] : null;
      textBox.textContent = lastDialog ? lastDialog.text : (sceneData.narration || '');
    }

    // 在选项区上方加题目提示
    var prompt = document.createElement('div');
    prompt.className = 'vn-question-prompt';
    prompt.textContent = '✦ 你会怎么做？';
    panel.insertBefore(prompt, container);

    // 记住当前滚动位置
    var savedScrollTop = panel.scrollTop;

    container.innerHTML = '';
    container.style.display = 'grid';


    // 性格倾向配置（用 AI 生成的图片）
    var typeConfig = {
      tiger:   { img: 'assets/options/tiger.jpg', label: '勇敢行动' },
      peacock: { img: 'assets/options/peacock.jpg', label: '热情感染' },
      koala:   { img: 'assets/options/koala.jpg', label: '温暖关怀' },
      owl:     { img: 'assets/options/owl.jpg', label: '冷静分析' }
    };

    sceneData.options.forEach(function(opt, i) {
      // 判断该选项的主要性格倾向
      var mainType = 'tiger';
      var maxScore = 0;
      if (opt.scores) {
        Object.keys(opt.scores).forEach(function(key) {
          if (opt.scores[key] > maxScore) {
            maxScore = opt.scores[key];
            mainType = key;
          }
        });
      }
      var cfg = typeConfig[mainType];

      var card = document.createElement('div');
      card.className = 'vn-option-card';
      card.setAttribute('data-type', mainType);

      // AI生成的性格图片
      var imgEl = document.createElement('img');
      imgEl.className = 'vn-option-img';
      imgEl.src = cfg.img;
      imgEl.alt = cfg.label;
      imgEl.style.pointerEvents = 'none';
      card.appendChild(imgEl);

      // 性格标签
      var traitEl = document.createElement('div');
      traitEl.className = 'vn-option-trait';
      traitEl.textContent = cfg.label;
      card.appendChild(traitEl);

      var textEl = document.createElement('div');
      textEl.className = 'vn-option-text';
      textEl.textContent = opt.text;
      card.appendChild(textEl);

      setTimeout(function() {
        card.classList.add('visible');
      }, i * 100);

      card.addEventListener('click', function() {
        if (self._optionsLocked) return;
        var allCards = container.querySelectorAll('.vn-option-card');
        allCards.forEach(function(c) { c.classList.remove('selected'); });
        card.classList.add('selected');
        self._selectedIndex = i;
        self._showConfirmBtn(container, sceneData);
      });

      container.appendChild(card);
    });

    // 恢复滚动位置
    panel.scrollTop = savedScrollTop;
    requestAnimationFrame(function() {
      panel.scrollTop = savedScrollTop;
    });
  },

  _selectedIndex: -1,

  _showConfirmBtn: function(optContainer, sceneData) {
    var self = this;
    // 移除旧的
    var old = self.container.querySelector('.vn-confirm-mask');
    if (old) old.remove();

    // 全屏半透明蒙层
    var mask = document.createElement('div');
    mask.className = 'vn-confirm-mask';

    // 底部浮动面板
    var panel = document.createElement('div');
    panel.className = 'vn-confirm-panel';

    // 提示文字
    var hint = document.createElement('div');
    hint.className = 'vn-confirm-hint';
    hint.textContent = '你确定这个选择吗？';
    panel.appendChild(hint);

    // 按钮行
    var btnRow = document.createElement('div');
    btnRow.className = 'vn-confirm-btns';

    // 重新选择按钮
    var retryBtn = document.createElement('button');
    retryBtn.className = 'vn-confirm-retry';
    retryBtn.textContent = '重新选择';
    retryBtn.addEventListener('click', function() {
      // 取消选中，移除蒙层
      var allCards = optContainer.querySelectorAll('.vn-option-card');
      allCards.forEach(function(c) { c.classList.remove('selected'); });
      self._selectedIndex = -1;
      mask.remove();
    });
    btnRow.appendChild(retryBtn);

    // 确定按钮
    var confirmBtn = document.createElement('button');
    confirmBtn.className = 'vn-confirm-btn';
    confirmBtn.textContent = '确定选择';
    confirmBtn.addEventListener('click', function() {
      if (self._optionsLocked) return;
      self._optionsLocked = true;
      confirmBtn.style.pointerEvents = 'none';
      confirmBtn.textContent = '已提交 ✓';
      confirmBtn.style.background = '#4CAF50';
      confirmBtn.style.color = '#fff';
      // 移除蒙层
      setTimeout(function() { mask.remove(); }, 300);
      self._onConfirm(optContainer, self._selectedIndex, sceneData);
    });
    btnRow.appendChild(confirmBtn);

    panel.appendChild(btnRow);
    mask.appendChild(panel);
    self.container.appendChild(mask);
  },

  _onConfirm: function(container, index, sceneData) {
    var self = this;
    var cards = container.querySelectorAll('.vn-option-card');
    var opt = sceneData.options[index];

    // 其他选项变暗
    cards.forEach(function(card, i) {
      if (i !== index) card.classList.add('dimmed');
    });

    // 1. 播放确认音效
    if (window.AudioManager) {
      AudioManager.playVoice('assets/audio/voice/confirm_ding.wav');
    }

    // 2. 播放星星爆发动效
    self._playStarBurst();

    // 3. 记分
    if (window.ScoreEngine && opt.scores) {
      ScoreEngine.addScore(sceneData.id, index, opt.scores);
    }

    // 4. 显示 feedback + 播放场景专属 feedback 语音
    setTimeout(function() {
      if (opt.feedback) {
        // 在对话框中显示 feedback 文字
        var frame = document.getElementById('story-dialog-frame');
        var textBox = document.getElementById('story-text');
        if (textBox) textBox.textContent = opt.feedback;

        // 移除角色气泡，换成旁白模式
        var speaker = frame ? frame.querySelector('.vn-speaker') : null;
        if (speaker) speaker.remove();

        // 播放场景专属 feedback 语音
        var sceneNum = self._currentIndex + 1;
        var feedbackFile = 'assets/audio/voice/feedback_s' + sceneNum + '_o' + index + '.mp3';
        if (window.AudioManager) {
          AudioManager.playVoice(feedbackFile, {
            onEnd: function() {
              // 语音播完后跳转
              self._gotoNext();
            }
          });
        } else {
          setTimeout(function() { self._gotoNext(); }, 2500);
        }
      } else {
        setTimeout(function() { self._gotoNext(); }, 1500);
      }
    }, 600); // 等音效和动效播完
  },

  _gotoNext: function() {
    var self = this;
    if (!self._running) return;
    var scenes = (window.StoryData && StoryData.scenes) || [];
    var nextIndex = self._currentIndex + 1;
    if (nextIndex >= scenes.length) {
      if (window.SceneManager) SceneManager.goto('climax');
    } else {
      if (window.SceneManager) SceneManager.goto('story', { sceneIndex: nextIndex });
    }
  },

  _playStarBurst: function() {
    var overlay = document.createElement('div');
    overlay.className = 'vn-celebrate-overlay';

    // 中心光波
    var ring = document.createElement('div');
    ring.className = 'vn-celebrate-ring';
    overlay.appendChild(ring);

    // 金色粒子（12个小圆点向四周飘散）
    for (var i = 0; i < 12; i++) {
      var p = document.createElement('div');
      p.className = 'vn-celebrate-particle';
      var angle = (i / 12) * 360;
      var dist = 60 + Math.random() * 40;
      p.style.setProperty('--angle', angle + 'deg');
      p.style.setProperty('--dist', dist + 'px');
      p.style.animationDelay = (Math.random() * 0.2) + 's';
      overlay.appendChild(p);
    }

    this.container.appendChild(overlay);
    setTimeout(function() {
      if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
    }, 1400);
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

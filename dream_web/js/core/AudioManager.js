/**
 * AudioManager - 音频管理器 V2
 * 支持：预生成角色配音(mp3) + 背景音乐(循环) + 全局开关
 */
window.AudioManager = (function() {
  'use strict';

  var enabled = true;
  var bgm = null;
  var currentVoice = null;
  var bgmVolume = 0.15;
  var voiceVolume = 0.9;

  return {
    init: function() {
      // 预创建 BGM 元素
      bgm = new Audio('assets/audio/bgm/forest_magic.wav');
      bgm.loop = true;
      bgm.volume = bgmVolume;
      bgm.preload = 'auto';
    },

    /**
     * 播放背景音乐
     */
    playBGM: function() {
      if (!enabled || !bgm) return;
      bgm.volume = bgmVolume;
      var playPromise = bgm.play();
      if (playPromise) {
        playPromise.catch(function() {
          // 自动播放被阻止，等用户交互后再播
        });
      }
    },

    /**
     * 停止背景音乐
     */
    stopBGM: function() {
      if (bgm) {
        bgm.pause();
        bgm.currentTime = 0;
      }
    },

    /**
     * 播放角色配音
     * @param {string} file - 音频文件路径 如 'assets/audio/voice/prologue_00.mp3'
     * @param {Object} [options]
     * @param {Function} [options.onEnd] - 播放结束回调
     * @returns {HTMLAudioElement|null}
     */
    playVoice: function(file, options) {
      options = options || {};
      if (!enabled) {
        if (typeof options.onEnd === 'function') {
          setTimeout(options.onEnd, 100);
        }
        return null;
      }

      // 停止当前配音
      this.stopVoice();

      currentVoice = new Audio(file);
      currentVoice.volume = voiceVolume;

      // 播放时压低 BGM
      if (bgm && !bgm.paused) {
        bgm.volume = bgmVolume * 0.3;
      }

      currentVoice.onended = function() {
        // 恢复 BGM 音量
        if (bgm && !bgm.paused) {
          bgm.volume = bgmVolume;
        }
        currentVoice = null;
        if (typeof options.onEnd === 'function') {
          options.onEnd();
        }
      };

      currentVoice.onerror = function() {
        if (bgm && !bgm.paused) {
          bgm.volume = bgmVolume;
        }
        currentVoice = null;
        if (typeof options.onEnd === 'function') {
          options.onEnd();
        }
      };

      currentVoice.play().catch(function() {
        // 播放失败
        if (typeof options.onEnd === 'function') {
          options.onEnd();
        }
      });

      return currentVoice;
    },

    /**
     * 停止当前配音
     */
    stopVoice: function() {
      if (currentVoice) {
        currentVoice.pause();
        currentVoice.onended = null;
        currentVoice.onerror = null;
        currentVoice = null;
      }
      // 恢复 BGM 音量
      if (bgm && !bgm.paused) {
        bgm.volume = bgmVolume;
      }
    },

    /**
     * 停止所有音频
     */
    stop: function() {
      this.stopVoice();
    },

    /**
     * 切换开关
     */
    toggle: function() {
      enabled = !enabled;
      if (!enabled) {
        this.stopVoice();
        if (bgm) bgm.pause();
      } else {
        this.playBGM();
      }
      return !enabled; // 返回 isMuted
    },

    isEnabled: function() { return enabled; },
    setEnabled: function(state) {
      enabled = !!state;
      if (!enabled) {
        this.stopVoice();
        if (bgm) bgm.pause();
      }
    },
    isSupported: function() { return true; },
    isSpeaking: function() { return !!currentVoice; },

    // 兼容旧接口
    speak: function(text, options) {
      if (options && typeof options.onEnd === 'function') {
        setTimeout(options.onEnd, 100);
      }
    },
    speakWithTypewriter: function(text, element, options) {
      // 降级为纯打字效果
      if (options && typeof options.onComplete === 'function') {
        setTimeout(options.onComplete, 100);
      }
      return Promise.resolve();
    },
    pause: function() {},
    resume: function() {},
    queueSpeak: function() {},
    clearQueue: function() {}
  };
})();

/**
 * ShareScene - 分享页
 */
window.ShareScene = {
  id: 'share',
  container: null,
  _running: false,

  init: function(container) {
    this.container = container;
    container.className = 'scene scene-share scene-entering';
    container.innerHTML = '';

    var wrapper = document.createElement('div');
    wrapper.className = 'share-card-wrapper';
    wrapper.id = 'share-card-wrapper';
    container.appendChild(wrapper);

    var tip = document.createElement('div');
    tip.className = 'share-tip';
    tip.textContent = '💾 长按图片保存到相册';
    container.appendChild(tip);

    var btn = document.createElement('button');
    btn.className = 'share-restart-btn';
    btn.textContent = '重新冒险';
    btn.onclick = function() {
      if (window.ScoreEngine) ScoreEngine.reset();
      if (window.SceneManager) SceneManager.goto('welcome');
    };
    container.appendChild(btn);
  },

  enter: function(data) {
    var self = this;
    self._running = true;

    var result = (data && data.result) || null;
    if (!result && window.ScoreEngine) {
      result = ScoreEngine.getResultData();
    }
    if (!result) {
      result = { primary: 'tiger', title: '勇敢的小领袖', traits: ['勇敢', '果断'] };
    }

    var wrapper = document.getElementById('share-card-wrapper');
    if (window.CardRenderer && wrapper) {
      CardRenderer.render(result).then(function(cardResult) {
        if (!self._running) return;
        wrapper.innerHTML = '';
        var img = document.createElement('img');
        img.className = 'share-card-img';
        img.src = cardResult.dataUrl;
        img.alt = '我的动物性格卡片';
        img.style.pointerEvents = 'auto';
        wrapper.appendChild(img);
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

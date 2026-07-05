<template>
  <div class="app-shell">
    <div class="app-content">
      <router-view />
    </div>
    <footer class="site-footer">
      <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener noreferrer">
        冀ICP备2021022256号-2
      </a>
    </footer>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.app-shell {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-content {
  min-height: 0;
  flex: 1;
}

.site-footer {
  min-height: 40px;
  display: flex;
  flex: 0 0 auto;
  align-items: center;
  justify-content: center;
  border-top: 1px solid #e8eaed;
  background: #fff;
  color: #7a8494;
  font-size: 12px;
  line-height: 1.5;
  padding: 8px 16px;
}

.site-footer a {
  color: inherit;
  text-decoration: none;
}

.site-footer a:hover {
  color: #409eff;
}
</style>

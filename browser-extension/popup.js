// 弹出窗口脚本
document.addEventListener('DOMContentLoaded', function() {
  const navServerUrlInput = document.getElementById('navServerUrl');
  const saveUrlBtn = document.getElementById('saveUrl');
  const addCurrentPageBtn = document.getElementById('addCurrentPage');
  const statusDiv = document.getElementById('status');
  
  // 加载保存的服务器地址
  chrome.runtime.sendMessage({ action: "getNavServerUrl" }, (response) => {
    if (response && response.url) {
      navServerUrlInput.value = response.url;
    }
  });
  
  // 保存服务器地址
  saveUrlBtn.addEventListener('click', function() {
    const url = navServerUrlInput.value.trim();
    
    if (!url) {
      showStatus('请输入导航服务器地址', 'error');
      return;
    }
    
    if (!isValidUrl(url)) {
      showStatus('请输入有效的URL地址', 'error');
      return;
    }
    
    chrome.runtime.sendMessage({ 
      action: "setNavServerUrl", 
      url: url 
    }, (response) => {
      if (response && response.success) {
        showStatus('设置保存成功！', 'success');
      } else {
        showStatus('设置保存失败，请重试', 'error');
      }
    });
  });
  
  // 添加当前页面
  addCurrentPageBtn.addEventListener('click', function() {
    chrome.runtime.sendMessage({ action: "addCurrentPage" });
    window.close();
  });
  
  // 显示状态信息
  function showStatus(message, type) {
    statusDiv.textContent = message;
    statusDiv.className = `status ${type}`;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
      statusDiv.style.display = 'none';
    }, 3000);
  }
  
  // 验证URL格式
  function isValidUrl(string) {
    try {
      new URL(string);
      return true;
    } catch (_) {
      return false;
    }
  }
  
  // 回车键保存
  navServerUrlInput.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
      saveUrlBtn.click();
    }
  });
}); 
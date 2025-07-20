// 后台脚本
let navServerUrl = '';

// 初始化右键菜单
chrome.runtime.onInstalled.addListener(() => {
  // 创建右键菜单
  chrome.contextMenus.create({
    id: "addToNav",
    title: "添加到团队导航",
    contexts: ["page", "link"]
  });
  
  // 从存储中获取导航服务器地址
  chrome.storage.sync.get(['navServerUrl'], (result) => {
    navServerUrl = result.navServerUrl || '';
  });
});

// 处理右键菜单点击
chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "addToNav") {
    // 获取当前页面信息
    const pageInfo = {
      url: info.linkUrl || tab.url,
      title: tab.title,
      favicon: tab.favIconUrl
    };
    
    // 发送消息到content script获取更多页面信息
    chrome.tabs.sendMessage(tab.id, {
      action: "getPageInfo",
      pageInfo: pageInfo
    }, (response) => {
      if (response && response.success) {
        // 打开添加页面
        openAddCardPage(response.pageInfo);
      }
    });
  }
});

// 处理来自popup的消息
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "setNavServerUrl") {
    navServerUrl = request.url;
    chrome.storage.sync.set({ navServerUrl: request.url });
    sendResponse({ success: true });
  } else if (request.action === "getNavServerUrl") {
    sendResponse({ url: navServerUrl });
  } else if (request.action === "addCurrentPage") {
    // 获取当前活动标签页
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      const tab = tabs[0];
      const pageInfo = {
        url: tab.url,
        title: tab.title,
        favicon: tab.favIconUrl
      };
      
      chrome.tabs.sendMessage(tab.id, {
        action: "getPageInfo",
        pageInfo: pageInfo
      }, (response) => {
        if (response && response.success) {
          openAddCardPage(response.pageInfo);
        }
      });
    });
  }
});

// 打开添加卡片页面
function openAddCardPage(pageInfo) {
  if (!navServerUrl) {
    // 如果没有设置服务器地址，打开设置页面
    chrome.tabs.create({
      url: chrome.runtime.getURL("popup.html")
    });
    return;
  }
  
  // 构建添加卡片的URL
  const addCardUrl = `${navServerUrl}/admin/card?url=${encodeURIComponent(pageInfo.url)}&title=${encodeURIComponent(pageInfo.title)}&favicon=${encodeURIComponent(pageInfo.favicon || '')}`;
  
  chrome.tabs.create({
    url: addCardUrl
  });
} 
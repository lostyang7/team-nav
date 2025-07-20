// 内容脚本
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "getPageInfo") {
    const pageInfo = request.pageInfo;
    
    // 获取页面描述
    const metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription) {
      pageInfo.description = metaDescription.getAttribute('content');
    }
    
    // 获取页面关键词
    const metaKeywords = document.querySelector('meta[name="keywords"]');
    if (metaKeywords) {
      pageInfo.keywords = metaKeywords.getAttribute('content');
    }
    
    // 获取页面作者
    const metaAuthor = document.querySelector('meta[name="author"]');
    if (metaAuthor) {
      pageInfo.author = metaAuthor.getAttribute('content');
    }
    
    // 获取页面图标（如果没有favicon）
    if (!pageInfo.favicon) {
      const iconLink = document.querySelector('link[rel="icon"], link[rel="shortcut icon"]');
      if (iconLink) {
        pageInfo.favicon = iconLink.href;
      }
    }
    
    // 获取页面主要内容（前200个字符）
    const bodyText = document.body.innerText || document.body.textContent;
    if (bodyText) {
      pageInfo.content = bodyText.substring(0, 200).trim();
    }
    
    // 获取页面语言
    pageInfo.language = document.documentElement.lang || 'zh-CN';
    
    // 获取页面域名
    pageInfo.domain = window.location.hostname;
    
    sendResponse({
      success: true,
      pageInfo: pageInfo
    });
  }
}); 
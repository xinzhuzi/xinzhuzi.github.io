/**
 * 自定义分类栏逻辑 + 主页文章过滤
 */
(function() {
  // 技术文章的实际子分类（当前已存在的）
  const techCategories = [
    { name: 'AI-游戏设计', url: '/categories/技术文章/AI-游戏设计/' },
    { name: 'Lua-热更新', url: '/categories/技术文章/Lua-热更新/' },
    { name: 'Unity开发', url: '/categories/技术文章/Unity开发/' },
    { name: '其他', url: '/categories/技术文章/其他/' },
    { name: '工具使用', url: '/categories/技术文章/工具使用/' },
    { name: '编程基础', url: '/categories/技术文章/编程基础/' },
    { name: '网络编程', url: '/categories/技术文章/网络编程/' }
  ];

  // 千年志*道劫的子分类
  const daoJieCategories = [
    { name: '游戏', url: '/categories/千年志-道劫/游戏/' },
    { name: '小说', url: '/categories/千年志-道劫/小说/' }
  ];

  function updateCategoryBar() {
    const currentPath = window.location.pathname;

    const categoryBarItems = document.querySelector('#category-bar-items');
    if (!categoryBarItems) return;

    // 主页：只显示千年志*道劫的子分类
    if (currentPath === '/' || currentPath === '/index.html' || currentPath === '/page/') {
      categoryBarItems.innerHTML = '';

      // 只添加子分类
      daoJieCategories.forEach(cat => {
        const div = document.createElement('div');
        div.className = 'category-bar-item';
        div.id = cat.name;
        div.innerHTML = `<a href="${cat.url}">${cat.name}</a>`;
        categoryBarItems.appendChild(div);
      });
      return;
    }

    // 检查是否是"千年志*道劫"分类页面（主分类页，不是子分类页）
    if (currentPath.includes('/categories/%E5%8D%83%E5%B9%B4%E5%BF%97-') ||
        (currentPath.includes('千年志') && !currentPath.includes('/游戏/') && !currentPath.includes('/小说/'))) {
      categoryBarItems.innerHTML = '';
      daoJieCategories.forEach(cat => {
        const div = document.createElement('div');
        div.className = 'category-bar-item';
        div.id = cat.name;
        div.innerHTML = `<a href="${cat.url}">${cat.name}</a>`;
        categoryBarItems.appendChild(div);
      });
      return;
    }

    // 检查是否是"技术文章"分类页面
    if (currentPath === '/categories/%E6%8A%80%E6%9C%AF%E6%96%87%E7%AB%A0/' ||
        currentPath === '/categories/%E6%8A%80%E6%9C%AF%E6%96%87%E7%AB%A0' ||
        currentPath.includes('/categories/%E6%8A%80%E6%9C%AF%E6%96%87%E7%AB%A0/page')) {
      categoryBarItems.innerHTML = '';
      techCategories.forEach(cat => {
        const div = document.createElement('div');
        div.className = 'category-bar-item';
        div.id = cat.name;
        div.innerHTML = `<a href="${cat.url}">${cat.name}</a>`;
        categoryBarItems.appendChild(div);
      });
      return;
    }
  }

  // 主页只显示千年志*道劫分类的文章
  function filterHomePagePosts() {
    const currentPath = window.location.pathname;

    // 只在主页执行
    if (currentPath !== '/' && currentPath !== '/index.html' && !currentPath.match(/^\/page\/\d+\/?$/)) {
      return;
    }

    const posts = document.querySelectorAll('.recent-post-item');
    posts.forEach(post => {
      const tips = post.querySelector('.recent-post-info-top-tips');
      if (tips) {
        const categories = tips.querySelectorAll('.original');
        let isDaoJie = false;
        categories.forEach(cat => {
          if (cat.textContent.includes('千年志')) {
            isDaoJie = true;
          }
        });
        // 只显示千年志*道劫的文章，隐藏其他
        if (!isDaoJie) {
          post.style.display = 'none';
        } else {
          post.style.display = '';
        }
      }
    });

    // 处理分页
    const pagination = document.querySelector('#pagination');
    if (pagination) {
      pagination.style.display = 'none';
    }
  }

  // 页面加载完成后执行
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      updateCategoryBar();
      filterHomePagePosts();
    });
  } else {
    updateCategoryBar();
    filterHomePagePosts();
  }

  // PJAX 完成后执行
  document.addEventListener('pjax:complete', () => {
    updateCategoryBar();
    filterHomePagePosts();
  });
})();

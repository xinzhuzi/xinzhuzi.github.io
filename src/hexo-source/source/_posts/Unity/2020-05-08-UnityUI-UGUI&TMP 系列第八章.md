---
title: "Unity UI 系列第八章：UI 图集与资源优化策略"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UGUI, Sprite Atlas, 图集, 资源优化, 打包策略]
image: /images/unity-ui-series-chapter8-banner.jpg
---

# 🎨 Unity UI 系列第八章：UI 图集与资源优化策略

> 💡 **图集优化的价值**：
> - Sprite Atlas 如何正确使用？
> - 图集打包策略有哪些最佳实践？
> - 如何减少 UI 资源的内存占用？
> - UI 资源的加载和释放优化？
>
> **系列第八章**，深入讲解 UI 图集与资源优化策略！

过渡绘制OverDraw

OverDraw就是指GPU对屏幕一片区域的重复绘制次数,单位像素的重新绘制次数
重叠就会产生OverDraw

- Image Type 为Sliced、Tiled的Image 不需要填充九宫格的不要勾选Fill Center属性，例如头像边框这种，这可以将中间镂空减少重叠区域

- 慎用Mask组件，它自带两层OverDraw；

- 慎用Text组件的OutLine和Shadow，Shadow会增加一层OverDraw，而OutLine是复制了四份Shadow实现的；

- 不使用空白或透明的Image，尽管alpha = 0，还是会渲染并增加一层OverDraw，可以重写脚本替代(Empty4Raycast)

      
        转载请注明来源，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

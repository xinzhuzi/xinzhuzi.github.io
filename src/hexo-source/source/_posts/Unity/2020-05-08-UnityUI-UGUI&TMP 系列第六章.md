---
title: "Unity UI 系列第六章：UI 动画与过渡效果实现"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UGUI, DoTween, 动画, 过渡效果, UI动效]
image: /images/unity-ui-series-chapter6-banner.jpg
---

# ✨ Unity UI 系列第六章：UI 动画与过渡效果实现

> 💡 **UI 动画的价值**：
> - 如何实现流畅的 UI 过渡动画？
> - DoTween 和 Animator 该怎么选？
> - 如何优化大量 UI 动画的性能？
> - 常见的 UI 动效实现技巧？
>
> **系列第六章**，深入讲解 UI 动画与过渡效果实现！

Layout

- Layout 静态时可以用,动态时最好不要使用.非要用的话就加一个 canvas,动态时不让它与外部 UI 进行合批

- 推荐插件  UITableView 来解决重用 cell ,使 UI 布局的 Cell 计算是按需计算,而不是按次计算.

- 能少用就少用,用了尽量不要动态!

ScrollView

在 ViewPort 上使用 RectMask2D 比使用 Mask 与 Image 少一个 Batch,添加 Canvas 进行动静分离.
原因是每当滑动时,组件都会被移动,需要重新布局,重新渲染.

- 当 scroll view 上有很多 Layout UI重建成本非常高,不建议嵌套使用.

- 推荐插件  UITableView 来解决重用 cell ,使 UI 布局的 Cell 计算是按需计算,而不是按次计算.

- UITableView 缓存池,按需计算

      
        转载请注明来源，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

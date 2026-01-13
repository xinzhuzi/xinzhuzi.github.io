---
title: "Unity UI 系列第五章：TextMeshPro 文本系统完全指南"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, TextMeshPro, TMP, 文本渲染, 字体, 富文本]
image: /images/unity-ui-series-chapter5-banner.jpg
---

# ✍️ Unity UI 系列第五章：TextMeshPro 文本系统完全指南

> 💡 **TextMeshPro 的价值**：
> - 为什么推荐使用 TextMeshPro 而不是 Text？
> - TMP 的富文本和样式系统怎么用？
> - 如何优化字体图集和性能？
> - TMP 的动画和特效实现？
>
> **系列第五章**，全面讲解 TextMeshPro 文本系统！

Canvas

用多个Canvas将屏幕划分出不同的区域，降低网格重建带来的性能损耗,动静分离.
使用嵌套/多个Canvas,来避免整个网格重建,此项是分割动静 UI 的一项手段.
如果是静态的布局,不要使用Scroll View,单独使用布局软件效果更好.
添加GameObject/UI/Panel Canvas 与GameObject/UI/Panel Image 标签,进行区分,方便动静分离

在Scroll View 下面的 Content 上尽量带有Canvas组件,可以很好的避免因合批/动静UI 带来的性能负担.
对应的Mask 子元素依然参与全局的Depth排序，避免因拖动打乱原有的Depth排序，造成合批失败.

- 在 避免使用Blocking Objects来遮挡射线，因为这是一个相当消耗性能的操作

Screen Space 和 World Space 中的Camera必须要指定,否则会造成性能浪费.
不指定摄像机,画布也会接收事件,也会查找摄像机,造成性能浪费.

频繁需要SetActive的物体可以使用 CanvasGroup 组件，可以有效降低重建消耗
CanvasGroup的 alpha 属性设置为 0,可以降低 Batch,并且性能比SetActive要好.

- 在 UGUI 中可以使用设置alpha的方式去替换 SetActive 的API.

- 修改了 Canvas 初始属性,设置为对 UI 更友好的方式,设置 Canvas Scaler的某些属性,适配横屏游戏,采用 2400x1080 作为适配方案.

禁用 Canvas 组件,而不是删除,禁用不会触发画布层次结构上的OnDisable/OnEnable回调,也不会丢弃它的顶点缓冲区,
它会保留所有的网格和顶点,重新启用时,不会触发重建,只会重新开始绘制

- 当父 Canvas 修改了本身大小,有可能就导致了 子Canvas 进行重建.

- 如果一个canvas 全面被另外一个 canvas 覆盖了,如果没有其他问题,请将看不见的那个 canvas 设置 alpha 为 0,或者禁用.

Canvas 的表现形态![Canvas1](/2021/08/12/UnityUI/UGUI&TMP%20%E7%B3%BB%E5%88%97%E7%AC%AC%E4%BA%94%E7%AB%A0/Canvas1.png)

![Canvas2](/2021/08/12/UnityUI/UGUI&TMP%20%E7%B3%BB%E5%88%97%E7%AC%AC%E4%BA%94%E7%AB%A0/Canvas1.png)

![Canvas3](/2021/08/12/UnityUI/UGUI&TMP%20%E7%B3%BB%E5%88%97%E7%AC%AC%E4%BA%94%E7%AB%A0/Canvas1.png)

Canvas 嵌套 Canvas 时 的表现形态,此时如果需要事件发生,需要添加上 GraphicRaycaster
![Canvas4](/2021/08/12/UnityUI/UGUI&TMP%20%E7%B3%BB%E5%88%97%E7%AC%AC%E4%BA%94%E7%AB%A0/Canvas1.png)
![CanvasBatch性能记录](/2021/08/12/UnityUI/UGUI&TMP%20%E7%B3%BB%E5%88%97%E7%AC%AC%E4%BA%94%E7%AB%A0/CanvasBatch%E6%80%A7%E8%83%BD%E8%AE%B0%E5%BD%95.png)

      
        转载请注明来源，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

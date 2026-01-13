---
title: "Unity UI 系列第一章：UGUI 核心概念与架构解析"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UGUI, TextMeshPro, UI系统, 架构设计]
image: /images/unity-ui-series-chapter1-banner.jpg
---

# 🎨 Unity UI 系列第一章：UGUI 核心概念与架构解析

> 💡 **UGUI 的价值**：
> - 想系统掌握 Unity UI 系统的核心架构？
> - Canvas、EventSystem、GraphicRaycaster 有什么关系？
> - UGUI 的事件系统和渲染流程是如何工作的？
> - 从零开始学习 UGUI，该如何入门？
>
> **这是系列第一章**，将带你深入了解 UGUI 的核心概念和整体架构！

- 参考资料

- [https://www.jianshu.com/p/9bd461de19a7](https://www.jianshu.com/p/9bd461de19a7)  博客

- UWA

- [https://blog.uwa4d.com/archives/video_UI.html](https://blog.uwa4d.com/archives/video_UI.html)

- [https://blog.uwa4d.com/archives/1875.html](https://blog.uwa4d.com/archives/1875.html)

- Unity 4.6f 源码

- 何冠峰(文西) 的 UGUI 原理和优化 PPT

- [https://www.cnblogs.com/alps/p/7773149.html](https://www.cnblogs.com/alps/p/7773149.html) 

- [https://zhuanlan.zhihu.com/p/340508875](https://zhuanlan.zhihu.com/p/340508875)

- [https://blog.csdn.net/zcaixzy5211314/article/details/86515168](https://blog.csdn.net/zcaixzy5211314/article/details/86515168)

- [https://github.com/BlueMonk1107/UGUISolution](https://github.com/BlueMonk1107/UGUISolution)

- [https://github.com/ExcelDataReader/ExcelDataReader](https://github.com/ExcelDataReader/ExcelDataReader)

- [https://github.com/monitor1394/unity-ugui-XCharts](https://github.com/monitor1394/unity-ugui-XCharts)  雷达图    

[https://blog.csdn.net/cyf649669121/article/details/83661023](https://blog.csdn.net/cyf649669121/article/details/83661023)
[https://blog.csdn.net/cyf649669121/article/details/83785539](https://blog.csdn.net/cyf649669121/article/details/83785539)
[https://blog.csdn.net/cyf649669121/article/details/86484168](https://blog.csdn.net/cyf649669121/article/details/86484168)
EventSystem耗时过长

学习资料群:
- 因涉及到收费插件,请加QQ 群:861960832

1.UI 基础:
- √ UGUI整体解决方案.
- TMP 视频.  需要自己先尝试一下, TMP 自带的例子.
- NGUI 与 UGUI 进行对比学习.

2. UI 扩展:
- mob-sakai的 UI 方案:UIEffect & ParticleEffectForUGUI & SoftMaskForUGUI 特殊效果
- Psd 2 Unity uGUI Pro 3.4.0 扩展插件,输出的都是半成品,美术极度反感,一定要慎重使用.
- ui-extensions 一套UI框架(GitHub)
- unity-ugui-XCharts 雷达图
- Unity手游UI框架一站式解决方案_by_卢成浩,UI框架搭建
- DoozyUI Complete UI Management System.unitypackage  assetstore的 UI动画方案
- I2 Localization.unitypackage 多主题,多地区,多语言解决方案,过于臃肿,不建议使用
- New UI Widgets v1.14.1 ,UGUI 的扩展方案
- UGUI Super ScrollView ,滑动视图方案.
- puremvc-csharp-multicore-framework-master Unity.PureMVC-master ,  MVC 模式,可以借鉴,但不使用.鉴于 UI 变动过于频繁,不建议使用乱七八糟的模式,以易用,好用为基础,直接选用 MVC 模式.(除了 MVC,其他都是异端)
- UGUI-Editor-master ,UI 的辅助插件,为了开发人更容易制作 UI.
- Optimized ScrollView Adapter 5.3.1 比 UGUI Super ScrollView ,滑动视图方案好,UGUI Super ScrollView缓存池子有 bug.

3. UI 优化:
- UI 模块优化案例分析, UWA 优化视频
- Unity引擎渲染、UI、逻辑代码模块的量化分析和优化方法_by_UWA官方 
- Unity引擎UI模块知识Tree.pdf
- UGUI原理和优化.pptx
- UGUI DrawCall与Canvas的Rebuild  偏邪教用法,不建议使用,不用看
- UGUIOptimizeExample-master 合批优化规则
- Unity 4.6 C++ 的 UI 源码
- UnityResourceStaticAnalyzeTool-master UI 的合批分析是参照Unity源码编写的,可以深度理解合批原理.
- LoopScrollRect 滑动视图解决方案.

4. UI 综合项目
- UIPure 纯净版,支持 2019,2020 版本.包含分析文章,Unity4.6 UGUI 的 C++源码部分,合批规则在BatchSorting.cpp 类中的 PrepareDepthEntries 中;重叠,material.id,texture.id 三个核心点.
- UIExample 例子版,将所需要的例子导入进项目中进行翻阅例子学习 UI.
- UGUI&TMP 制作以及验证.

      
        转载请注明来源，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

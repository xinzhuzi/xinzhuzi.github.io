---
title: "Unity UGUI 深度优化指南：Canvas、合批与重建的完全解析"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UGUI, UI优化, 性能优化, Canvas, DrawCall, 合批, 网格重建]
image: /images/unity-ugui-optimization-banner.jpg
---

# 🎯 Unity UGUI 深度优化指南：Canvas、合批与重建的完全解析

> 💡 **UGUI 优化的核心**：
> - Canvas 刷新太频繁，导致性能问题？
> - 不理解网格重建机制，优化无从下手？
> - 想降低 DrawCall，却不知道怎么合批？
> - 如何平衡 UI 复杂度和渲染性能？
>
> **这篇文章！** 将深入剖析 UGUI 核心机制，从 Canvas 渲染流程到网格重建原理，提供完整的性能优化策略！

---

## 一、UGUI 概述

### 1.1 UI 系统对比

| UI 系统 | 类型 | 开发方 | C++ 层 | 适用场景 |
|---------|------|--------|--------|---------|
| **UGUI** | 游戏运行时 | Unity (NGUI作者) | ✅ 有 | Unity 游戏 |
| **NGUI** | 游戏运行时 | Tasharen | ❌ 无 | Unity 游戏 |
| **FGUI** | 游戏运行时 | FairyGUI | ❌ 无 | 跨引擎 |
| **UIWidgets** | APP UI | Flutter | - | 应用程序 |
| **IMGUI** | 编辑器 UI | Unity | ✅ 有 | 调试/Inspector |
| **UI Elements** | 编辑器 UI | Unity | ✅ 有 | 2019+ 编辑器 |

### 1.2 UGUI 特点

```
UGUI 架构优势:
┌─────────────────────────────────────┐
│  C++ 层优化:                         │
│  ├─ Canvas.cs (部分)                │
│  ├─ CanvasGroup.cs (部分)           │
│  └─ CanvasRenderer.cs (核心)        │
│                                     │
│  多线程支持:                         │
│  └─ 部分方法可在子线程执行           │
└─────────────────────────────────────┘
```

---

## 二、RectTransform 基础

### 2.1 Pivot (轴心)

| 属性 | 说明 | 影响 |
|-----|------|------|
| **定义** | 相对于控件本身的位置 | 旋转、缩放、大小调整的中心点 |
| **表示** | (0,0) 左下角 ~ (1,1) 右上角 | 比例坐标 |
| **可视化** | Inspector 中蓝色小圆点 | 可在矩形内部或外部 |

```csharp
// Pivot 设置示例
rectTransform.pivot = new Vector2(0.5f, 0.5f);  // 中心点
rectTransform.pivot = new Vector2(0, 0);        // 左下角
rectTransform.pivot = new Vector2(1, 1);        // 右上角
```

### 2.2 Anchors (锚点)

| 属性 | 说明 | 用途 |
|-----|------|------|
| **定义** | 相对于父控件的位置参考点 | 保持相对位置 |
| **数量** | 4 个锚点 (可分开) | 精确控制 |
| **可视化** | Inspector 中 4 个"花瓣" | Min/Max 坐标 |

```
锚点示意图:
┌─────────────────────────────────────┐
│  父控件                              │
│  ┌─────┴─────┐                      │
│  │  Min (0,0)──────┐               │
│  │         │       │               │
│  │    子控件 │      │               │
│  │         │       │               │
│  │         └──────(1,1) Max         │
│  └───────────────────┘              │
│                                     │
│  父控件变换 → 子控件自动跟随         │
└─────────────────────────────────────┘
```

---

## 三、UGUI 核心类

### 3.1 CanvasRenderer

| 功能 | 说明 | 对比 NGUI |
|-----|------|----------|
| **原材料** | Material、颜色、Mesh、透明度 | 类似 UIDrawCall |
| **渲染核心** | 必须存在才能正常显示 | 类比 NGUI 渲染器 |
| **VBO 管理** | 顶点缓冲对象 | Mesh 的另一种表示 |

```csharp
// CanvasRenderer 关键方法
CanvasRenderer renderer = GetComponent<CanvasRenderer>();
renderer.SetColor(Color.white);           // 设置颜色
renderer.SetMaterial(material, 0);       // 设置材质
renderer.SetTexture(mainTexture);        // 设置纹理
```

### 3.2 VertexHelper

| 功能 | 说明 | 对比 NGUI |
|-----|------|----------|
| **记录内容** | 位置、UV、颜色、三角形 | 类似 UIGeometry |
| **数据结构** | 原生 List | ObjectPool 优化 |

```csharp
// VertexHelper 使用示例
VertexHelper vh = new VertexHelper();
vh.AddVert(new Vector3(0, 0), Color.white, new Vector2(0, 0));
vh.AddVert(new Vector3(1, 0), Color.white, new Vector2(1, 0));
vh.AddVert(new Vector3(0, 1), Color.white, new Vector2(0, 1));
vh.AddTriangle(0, 1, 2);
```

### 3.3 Graphic

| 继承关系 | 说明 |
|---------|------|
| `Text → MaskableGraphic → Graphic → UIBehaviour → MonoBehaviour` | 文本控件 |
| `Image → MaskableGraphic → Graphic → UIBehaviour → MonoBehaviour` | 图片控件 |

| 功能 | 说明 |
|-----|------|
| **Mesh 组装** | 将数据塞给 CanvasRenderer |
| **类比 NGUI** | 类似 UIWidget |

### 3.4 Canvas

| 对比 | UGUI | NGUI |
|-----|------|------|
| **管理单位** | Canvas | UIPanel |
| **合批范围** | Canvas 内元素 | UIPanel 内元素 |
| **嵌套支持** | ✅ 子 Canvas 独立 dirty | ❌ 不支持嵌套 |

---

## 四、Canvas 合批机制

### 4.1 合批流程

```
Canvas 合批流程:
┌─────────────────────────────────────┐
│  1. 收集可绘制 UI 元素               │
│                                     │
│  2. 按材质和渲染顺序重排             │
│     └─ 相同材质的元素合并到 SubMesh  │
│                                     │
│  3. 缓存合批结果                     │
│     └─ 直到标记为 dirty             │
│                                     │
│  4. 渲染                             │
│     └─ 每个 SubMesh = 一个 DrawCall │
└─────────────────────────────────────┘
```

### 4.2 合批调用栈

```
Camera.Render
  └─ Drawing
      └─ Camera.RenderSkybox
      └─ Render.TransparentGeometry
          └─ RenderForwardAlpha.Render
              └─ RenderForwardAlpha.RenderLoopJob
                  └─ Canvas.RenderSubBatch  ← 合批发生点
                      └─ Draw Mesh
```

### 4.3 影响合批的因素

| 变更类型 | 触发条件 | 影响 |
|---------|---------|------|
| **Sprite 变更** | 修改 sprite renderer 的 sprite | 重新合批 |
| **Transform 变更** | 修改 position、scale、rotation | 重新合批 |
| **Text 变更** | 修改文本网格内容 | 重新合批 |
| **颜色变更** | 修改顶点颜色 | ⚠️ 产生新 DrawCall |

> ⚠️ **重要**：任何 UI 元素的外观变更都会触发整个 Canvas 重新合批，不管其他元素是否被修改。

### 4.4 Canvas 嵌套

```csharp
// ✅ Canvas 嵌套优势
// 子 Canvas dirty 不会触发父 Canvas rebuild

Canvas parentCanvas = rootGO.AddComponent<Canvas>();
Canvas childCanvas = childGO.AddComponent<Canvas>();
// 独立的重建机制，提高性能
```

---

## 五、网格重建机制

### 5.1 重建流程

```
网格重建流程:
┌─────────────────────────────────────┐
│  CanvasUpdateRegistry 监听           │
│  Canvas.WillRenderCanvases           │
│         │                           │
│         ▼                           │
│  ┌─────────────────────────────┐   │
│  │ 1. Layout Rebuild 排序      │   │
│  │    (按层次深度排序)          │   │
│  └─────────────────────────────┘   │
│         │                           │
│         ▼                           │
│  ┌─────────────────────────────┐   │
│  │ 2. Rebuild Layout          │   │
│  │    (计算位置、Rect大小)      │   │
│  └─────────────────────────────┘   │
│         │                           │
│         ▼                           │
│  ┌─────────────────────────────┐   │
│  │ 3. Rebuild Graphic         │   │
│  │    ├── UpdateGeometry       │   │
│  │    └── UpdateMaterial       │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 5.2 触发重建的操作

| 操作 | 影响 |
|-----|------|
| **SetActive** | 触发 Layout Rebuild |
| **Position 变更** | 可能触发 Graphic Rebuild |
| **Size 变更** | 触发 Layout + Graphic Rebuild |
| **Color 变更** | 修改顶点颜色，不产生新 DC |
| **Anchor/Pivot 变更** | 触发 Layout Rebuild |

### 5.3 性能分析函数

| 函数 | 说明 | 问题定位 |
|-----|------|---------|
| **Canvas.BuildBatch** | 合并 Canvas 下所有 UI 元素 | 检查合批开销 |
| **Canvas.SendWillRenderCanvases** | 通知重建 Layout 或 Graphic | 检查重建频率 |
| **WaitingForJob** | 等待子线程网格合并 | 网格开销巨大 |
| **PutGeometryJobFence** | 网格合并同步点 | 多线程等待 |

---

## 六、事件系统

### 6.1 EventSystem 核心

```
EventSystem 架构:
┌─────────────────────────────────────┐
│  EventSystem                        │
│  ├─ EventTriggerType (事件类型)     │
│  ├─ EventData (事件数据)            │
│  ├─ InputModules (输入模块)         │
│  └─ Raycasters (射线检测)           │
│                                     │
│  核心原理:                           │
│  Camera.ScreenPointToRay            │
│    ↓                                │
│  Physics.Raycast (使用反射)         │
│    ↓                                │
│  RaycastHit / RaycastHit2D          │
│    ↓                                │
│  RaycastResult (发送事件)           │
└─────────────────────────────────────┘
```

### 6.2 Raycast 开销

| 问题 | 影响 | 解决方案 |
|-----|------|---------|
| **默认全部检测** | 所有可见 Graphic 都调用 raycast | 禁用不需要的 Raycast Target |

```csharp
// ✅ 禁用不需要的 Raycast
Image image = GetComponent<Image>();
image.raycastTarget = false;  // 纯展示元素
```

---

## 七、常见性能问题

### 7.1 四大问题

| 问题类型 | 说明 |
|---------|------|
| **GPU 片段着色器** | 屏幕填充率过高 (OverDraw) |
| **CPU 重建画布** | 过多 CPU 时间用于重建 Canvas |
| **CPU 生成顶点** | 文本顶点生成开销大 |
| **画布重建次数** | 重建频率过高 |

### 7.2 问题原因

| 原因 | 说明 | 解决方案 |
|-----|------|---------|
| **UI 重叠** | 拓扑关系复杂 | 优化层级结构 |
| **渲染顺序** | 层级不一致 | 同步层级 |
| **图集分配** | 图集不合理 | 重新规划图集 |
| **Layout 重绘** | 频率过高 | 禁用或优化 |
| **Graphic 重建** | 频繁添加删除 | 使用 Scale 替代 SetActive |
| **Text Best Fit** | 预生成所有字号 | 使用固定字号 |
| **Outline/Shadow** | 顶点数 x4 | 使用 TextMeshPro |

---

## 八、优化策略

### 8.1 网格重建优化

| 策略 | 说明 | 效果 |
|-----|------|------|
| **减少 UI 元素** | 删除不必要的 UI | 减少排序和重建时间 |
| **动静分离** | 动态/静态 UI 分 Canvas | 限制重建范围 |
| **慎用 SetActive** | 使用 Scale/Alpha 替代 | 避免触发 rebuild |
| **慎用 Pixel Perfect** | 移动时微调导致 rebuild | 仅桌面端使用 |
| **Animator 替换** | 使用 DoTween 替代 | 避免每帧修改 |
| **慎用 Tiled Image** | 减少纹理采样 | 降低 GPU 开销 |

### 8.2 屏幕填充率优化

| 策略 | 说明 |
|-----|------|
| **禁用不可见面板** | 使用 Layer 或 CanvasGroup 控制 |
| **空 Image 替换** | 使用 Empty4Raycast 方案 |
| **Polygon Mode** | 紧密 Sprite 减少留白 |
| **Fill Center** | 九宫格中心镂空 |

```csharp
// ✅ 空 Graphic 用于 Raycast
public class EmptyGraphic : Graphic
{
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        vh.Clear();  // 不生成顶点
    }
}
```

### 8.3 合批优化

| 策略 | 说明 |
|-----|------|
| **相同层级原则** | 父节点下保持层级结构一致 |
| **减少 Mask** | 使用 RectMask2D 替代 |
| **隐藏 Image** | sprite 为空的 Image 会打断合批 |
| **Camera 模式** | Screen Space-Camera 模式注意事项 |
| **Hierarchy 优化** | 避免 Hierarchy 穿插重叠 |

### 8.4 字体优化

| 策略 | 说明 |
|-----|------|
| **预生成字体** | 使用 Font.RequestCharactersInTexture |
| **美术数字** | 分数使用精灵图片 |
| **慎用 Best Fit** | 固定字号替代 |
| **减少特效** | 避免 Outline/Shadow |
| **TextMeshPro** | 使用 SDF 字体 |

### 8.5 滚动视图优化

| 策略 | 说明 |
|-----|------|
| **对象池** | 复用滚动元素 |
| **RectMask2D** | 屏幕外元素不参与 batch |
| **基于位置缓存** | 自定义滚动视图 |

---

## 九、Canvas 分离策略

### 9.1 分离原则

```
Canvas 分离策略:
┌─────────────────────────────────────┐
│  主 Canvas (静态)                    │
│  ┌─────────┐  ┌─────────┐           │
│  │ 背景    │  │ 装饰    │           │
│  └─────────┘  └─────────┘           │
│                                     │
│  动态 Canvas (频繁更新)              │
│  ┌─────────┐  ┌─────────┐           │
│  │ 血条    │  │ 倒计时   │           │
│  └─────────┘  └─────────┘           │
│                                     │
│  特效 Canvas (粒子/特效)             │
│  ┌─────────┐  ┌─────────┐           │
│  │ 粒子    │  │ 伤害飘字 │           │
│  └─────────┘  └─────────┘           │
└─────────────────────────────────────┘
```

### 9.2 分离示例

```csharp
// ✅ 动态元素自动添加 Canvas
[ExecuteAlways]
public class DynamicUICanvas : MonoBehaviour
{
    void OnEnable()
    {
        // 确保有独立的 Canvas
        if (GetComponent<Canvas>() == null)
        {
            gameObject.AddComponent<Canvas>();
            gameObject.AddComponent<GraphicRaycaster>();
        }
    }
}
```

---

## 十、开发规范

### 10.1 设计规范

| 规范 | 说明 |
|-----|------|
| **模板统一** | 设计大中小三套尺寸模板 |
| **路径一致** | 美术目录与客户端目录保持一致 |
| **图片命名** | 功能_颜色_尺寸 格式 |
| **公用图集** | 多面板共用图片放入公用图集 |
| **出图尺寸** | 合理尺寸减小序列化时间 |

### 10.2 图片分类

| 分类 | 说明 | 处理方式 |
|-----|------|---------|
| **UISprite** | 小图标、按钮 | 九宫格或平铺，复用 |
| **UIFrame** | 大尺寸背景框 | 单独处理 |
| **Icon** | 功能图标 | 打入图集 |
| **Photo** | 英雄形象大图 | 不进图集 |

### 10.3 字体规范

| 规范 | 说明 |
|-----|------|
| **字体大小** | 大中小三号，每级三分，共九种 |
| **色值表** | RGBA + 十六进制值 |
| **颜色模板** | 存储在 Unity 颜色模板里 |

---

## 十一、优化检查清单

### 11.1 DrawCall 检查

- [ ] DrawCall 数量 <30 (正常界面)
- [ ] 复杂界面 DrawCall <50
- [ ] 使用 Frame Debugger 检查
- [ ] 相同图集在同一层级
- [ ] 检查 Hierarchy 穿插问题

### 11.2 重建频率检查

- [ ] Canvas.BuildBatch 开销 <1ms
- [ ] Canvas.SendWillRenderCanvases 频率合理
- [ ] 动静分离完成
- [ ] 避免 Pixel Perfect
- [ ] 减少 Layout 使用

### 11.3 GPU 检查

- [ ] OverDraw <2x
- [ ] 禁用 Raycast Target (不需要交互的)
- [ ] 减少 Mask 使用
- [ ] 移除空 Image
- [ ] 避免全屏透明覆盖

### 11.4 字体检查

- [ ] 避免使用 Outline
- [ ] 避免使用 Best Fit
- [ ] 长文本变动频率低
- [ ] 考虑使用 TextMeshPro

---

## 十二、参考资料

- [腾讯游戏学院 - UGUID](https://gameinstitute.qq.com/community/detail/112745)
- [UWA - UI 优化视频](https://blog.uwa4d.com/archives/video_UI.html)
- [Unity - UI Optimization](https://docs.unity3d.com/Manual/MobileOptimizationPracticalScriptingOptimizations.html)

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

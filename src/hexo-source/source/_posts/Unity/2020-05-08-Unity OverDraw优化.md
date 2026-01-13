---
title: "Unity OverDraw 优化完全手册：移动端 GPU 性能优化核心"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, OverDraw, 性能优化, 移动端, TBR, 带宽优化, GPU]
image: /images/unity-overdraw-optimization-banner.jpg
---

# 🎨 Unity OverDraw 优化完全手册：移动端 GPU 性能优化核心

> 💡 **OverDraw 优化的价值**：
> - 移动游戏发热严重，GPU 是瓶颈？
> - OverDraw 太高，带宽被浪费？
> - 不理解 TBR 架构，优化方向错误？
> - 如何测量和优化 OverDraw？
>
> **这篇文章！** 将深入解析 OverDraw 原理，从测量方法到优化策略，特别针对移动端 TBR 架构，让 GPU 性能翻倍！

---

## 一、OverDraw 概述

### 1.1 什么是 OverDraw

```
OverDraw 示意图:
┌─────────────────────────────────────┐
│  屏幕像素点 (1x1)                   │
│                                     │
│  第1次绘制: 背景层    ████ 1.0x     │
│  第2次绘制: 按钮层    ▓▓▓▓ 2.0x     │
│  第3次绘制: 红点层    ▒▒▒▒ 3.0x     │
│                                     │
│  该像素被重复绘制 3 次 = 3.0x OverDraw │
└─────────────────────────────────────┘
```

| 定义 | 说明 |
|-----|------|
| **OverDraw** | 同一像素在一帧内被多次绘制 |
| **过渡渲染** | 透明/半透明元素叠加导致重复绘制 |
| **性能影响** | 增加内存带宽消耗，降低帧率 |

### 1.2 性能影响

| 影响项 | 说明 |
|-----|------|
| **内存带宽** | 每次绘制都需要读写帧缓冲区 |
| **GPU 负载** | 重复计算相同像素 |
| **帧率差异** | 可能导致 60fps vs 30fps 的差距 |

> ⚠️ **注意**：简单的后处理效果（如 Color Grading）会对每个像素至少计算一次，直接增加 100% (1.0x) 的 OverDraw。

---

## 二、TBR 架构与移动端

### 2.1 TBR 渲染架构

```
TBR (Tile-Based Rendering) 流程:
┌─────────────────────────────────────┐
│  1. 几何处理阶段                    │
│     └─ 收集所有绘制命令             │
│                                     │
│  2. 分块阶段                        │
│     └─ 屏幕分割为小 Tile            │
│                                     │
│  3. 渲染阶段 (每 Tile 独立)         │
│     ├─ On-Chip Memory 缓存          │
│     ├─ Early-Z 剔除                 │
│     └─ 像素着色                     │
│                                     │
│  4. 写回阶段                        │
│     └─ 将结果写回主内存             │
└─────────────────────────────────────┘
```

### 2.2 移动 GPU 特性

| GPU 系列 | 架构 | 特点 |
|---------|------|------|
| **Adreno** | TBR | Qualcomm 芯片 |
| **Mali** | TBR | ARM 芯片 |
| **PowerVR** | TBDR | Apple 芯片 (深度剔除) |
| **Tegra** | IMR | Nvidia 芯片 (非 TBR) |

> 💡 **重要**：所有移动平台（除 Tegra 外）都是 TBR 架构，OverDraw 在移动端的带宽消耗尤为严重。

---

## 三、OverDraw 测量方法

### 3.1 Unity 内置可视化

| 方法 | 说明 | 局限性 |
|-----|------|--------|
| **场景视图模式** | Scene → OverDraw | 未考虑 Z-Test，不透明 OverDraw 为假 |
| **HDRP 工具** | Window → Render Pipeline Debug | 仅限 HDRP 7.1+ |

```
Unity OverDraw 可视化:
┌─────────────────────────────────────┐
│  Scene View → Shaded → OverDraw     │
│                                     │
│  颜色映射:                           │
│  ┌─────────────────────────────┐   │
│  │ 白色   - 0x (无 OverDraw)   │   │
│  │ 浅绿   - 1x                 │   │
│  │ 深绿   - 2x                 │   │
│  │ 黄色   - 3x                 │   │
│  │ 橙色   - 4x                 │   │
│  │ 红色   - 5x+ (严重)          │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 3.2 专业工具

| 工具 | 用途 | 特点 |
|-----|------|------|
| **RenderDoc** | GPU 图形调试器 | 免费，详细分析 |
| **Snapdragon Profiler** | 底层性能分析 | Qualcomm 专用 |
| **Xcode GPU Debugger** | iOS 设备分析 | 精准，Apple 设备 |
| **Compute Shader** | 自行量化 | GitHub: OverdrawMonitor |

### 3.3 性能参数

| 参数 | 定义 | 建议值 |
|-----|------|--------|
| **总填充数值峰** | 单帧总填充像素数量最大值 | 越低越好 |
| **填充倍数峰值** | 单帧最大填充倍数 | <3x |
| **单帧填充倍数** | 总填充数 / 分辨率 | <2x |

---

## 四、不透明 OverDraw 优化

### 4.1 渲染顺序

```
正确渲染顺序:
┌─────────────────────────────────────┐
│  从近到远 (Front to Back)           │
│                                     │
│  摄像机                             │
│     │                               │
│     ▼ (先渲染)                       │
│  ┌─────────┐                        │
│  │ 前景物体 │──> Z-Test 剔除         │
│  └─────────┘      后续被遮挡像素    │
│     │                               │
│     ▼                               │
│  ┌─────────┐                        │
│  │ 中景物体 │──> 只渲染可见像素     │
│  └─────────┘                        │
│     │                               │
│     ▼                               │
│  ┌─────────┐                        │
│  │ 天空盒   │──> 最后渲染           │
│  └─────────┘                        │
└─────────────────────────────────────┘
```

### 4.2 排序规则

| 排序方式 | 说明 | 优化效果 |
|---------|------|---------|
| **距离排序** | 按相机与边界框中心距离排序 | ✅ 默认启用 |
| **天空盒后渲染** | Skybox 在不透明几何后绘制 | ✅ 减少 OverDraw |
| **手动队列** | Geometry±1, Geometry±2 | ⚠️ 需谨慎 |

### 4.3 批处理的副作用

```csharp
// ❌ 静态批处理可能导致 OverDraw 增加
// Unity 合并 DrawCall 后，失去单独排序的能力

// 解决方案 1: 禁用问题对象的批处理
MeshRenderer.receiveGI = ReceiveGI.LightProbes;
MeshRenderer.lightProbeUsage = LightProbeUsage.Off;
// 或使用 MaterialPropertyBlock

// 解决方案 2: 手动设置渲染队列
material.renderQueue = (int)RenderQueue.Geometry - 1;  // 提前渲染
material.renderQueue = (int)RenderQueue.Geometry + 1;  // 延后渲染
```

---

## 五、透明 OverDraw 优化

### 5.1 透明渲染问题

| 特性 | 性能影响 | 原因 |
|-----|---------|------|
| **Alpha Blend** | 额外读写和运算 | 混合计算 |
| **无 Z-Write** | 无法像素剔除 | 必须渲染所有透明像素 |
| **排序要求** | 从后向前绘制 | 无法利用 Early-Z |

### 5.2 优化策略

| 策略 | 说明 | 效果 |
|-----|------|------|
| **减少层数** | 降低透明叠加层级 | 直接减少 OverDraw |
| **缩小尺寸** | 减小屏幕占用面积 | 按比例减少 |
| **裁剪透明像素** | 删除 100% 透明区域 | 精确绘制 |
| **紧密网格** | 用 Mesh 替代矩形 Sprite | 镂空不可见区域 |

```csharp
// ✅ 精灵网格化 (Tight Mesh)
// Unity 和 Texture Packer 支持 Polygon Mode
// 将矩形 Sprite 替换为多边形描述

SpriteRenderer spriteRenderer = GetComponent<SpriteRenderer>();
// 在 Sprite 设置中启用 Tight Mesh 或 Polygon Mode
```

### 5.3 混合模式选择

| 模式 | 性能 | 适用场景 |
|-----|------|---------|
| **Alpha Blend** | 较慢 | 标准半透明 |
| **Additive** | 较快 | 发光、特效 |
| **Multiply** | 较快 | 叠加、阴影 |

```csharp
// ✅ 优先使用 Additive 模式
Material material = new Material(Shader.Find("Mobile/Particles/Additive"));
```

---

## 六、UI OverDraw 优化

### 6.1 UI 系统特点

| UI 系统 | 渲染方式 | OverDraw 问题 |
|---------|---------|--------------|
| **UGUI** | 全四边形渲染 | 容易堆叠，大量 OverDraw |
| **SpriteRenderer** | 支持 Mesh | 可使用 Tight Mesh |

### 6.2 UI 优化策略

```
UI OverDraw 优化:
┌─────────────────────────────────────┐
│  1. 避免全屏四边形                   │
│     └─ 使用 SpriteMesh 替代          │
│                                     │
│  2. 减少透明区域                     │
│     └─ 镂空 100% 透明像素            │
│                                     │
│  3. 分层渲染                         │
│     └─ 静态/动态 Canvas 分离        │
│                                     │
│  4. 禁用不可见面板                   │
│     └─ Layer 或 CanvasGroup 控制    │
└─────────────────────────────────────┘
```

### 6.3 空 Image 优化

```csharp
// ❌ 空 Image 仍会渲染
<Image raycastTarget="true" />

// ✅ 自定义空 Graphic
public class EmptyGraphic : Graphic
{
    protected override void OnPopulateMesh(VertexHelper vh)
    {
        // 不生成任何顶点，不参与渲染
        vh.Clear();
    }
}
```

---

## 七、粒子系统优化

### 7.1 粒子 OverDraw 问题

```
粒子堆叠问题:
┌─────────────────────────────────────┐
│  粒子系统常见问题:                   │
│                                     │
│  • 粒子频繁堆叠                     │
│  • 混乱区域像素爆炸                 │
│  • 后处理增加额外层                 │
│                                     │
│  单个复杂特效可能造成 5x-10x OverDraw │
└─────────────────────────────────────┘
```

### 7.2 优化策略

| 策略 | 说明 |
|-----|------|
| **控制数量** | 限制同屏粒子总数 |
| **使用 Additive** | 替代 Alpha Blend |
| **序列帧替代** | 简单特效用 Sprite 动画 |
| **降低生命周期** | 减少存活时间 |

---

## 八、通用优化技巧

### 8.1 设计层面

| 技巧 | 说明 |
|-----|------|
| **简化 UI 设计** | 减少装饰性重叠 |
| **优化层级** | 合理规划元素顺序 |
| **避免全屏覆盖** | 局部覆盖替代全屏 |

### 8.2 技术层面

| 技巧 | 说明 | 效果 |
|-----|------|------|
| **Polygon Mode** | 紧密 Mesh 描述 | 减少 30-50% OverDraw |
| **Image Fill Center** | 九宫格中心镂空 | 消除中心 OverDraw |
| **RectMask2D** | 矩形裁剪 | 避免外部渲染 |
| **Layer 隐藏** | 被遮挡面板禁用 | 完全跳过渲染 |

```csharp
// ✅ 九宫格中心镂空
Image image = GetComponent<Image>();
image.type = Image.Type.Sliced;
image.fillCenter = false;  // 取消勾选 Fill Center
```

---

## 九、优化检查清单

### 9.1 检测清单

- [ ] 使用 Unity OverDraw 可视化检查
- [ ] 使用 Frame Debugger 分析渲染顺序
- [ ] 使用专业工具量化 OverDraw
- [ ] 检查总填充倍数 <2x
- [ ] 检查峰值填充倍数 <3x

### 9.2 优化清单

- [ ] 从前向后渲染不透明物体
- [ ] 天空盒置于不透明物体后
- [ ] 透明物体使用 Additive 模式
- [ ] Sprite 使用 Tight Mesh
- [ ] Image 取消不必要的 Fill Center
- [ ] 粒子系统使用 Additive
- [ ] UI 使用 Polygon Mode
- [ ] 禁用不可见面板
- [ ] 移除空 Image 组件

### 9.3 性能目标

| 平台 | 建议填充倍数 |
|-----|------------|
| **PC** | <3x |
| **手游高端** | <2x |
| **手游低端** | <1.5x |

---

## 十、参考资料

- [知乎 - OverDraw 详解](https://zhuanlan.zhihu.com/p/350778355)
- [UWA - UI 优化视频](https://blog.uwa4d.com/archives/video_UI.html)
- [Unity - OverdrawMonitor](https://github.com/Nordeus/Unite2017)
- [UWA - 填充率优化](https://blog.uwa4d.com/archives/fillrate.html)

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

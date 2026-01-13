---
title: "Unity Android 性能优化实战：Android Studio 工具完全指南"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, Android, 优化, Android Studio, Profiler, ADB, 性能分析]
image: /images/unity-android-studio-optimization-banner.jpg
---

# 📱 Unity Android 性能优化实战：Android Studio 工具完全指南

> 💡 **Android 优化的价值**：
> - Android 平台性能问题难定位？
> - Android Studio Profiler 怎么用？
> - GPU、内存、耗电量，如何全面分析？
> - ADB 命令行工具有哪些神技？
>
> **这篇文章！** 将深入讲解 Unity Android 优化，从 Android Studio Profiler 到 ADB 命令，让 Android 性能更优！

---

## 一、工具概览

### 1.1 性能分析工具对比

| 工具 | 用途 | 优势 |
|-----|------|------|
| **Android Profiler** | CPU/内存/网络/能耗分析 | 实时监控，图形化展示 |
| **Memory Profiler** | 内存泄漏分析 | 堆转储，对象引用追踪 |
| **GPU Profiler** | 渲染性能分析 | GPU 活动监控 |
| **Layout Inspector** | UI 布局分析 | 可视化层级结构 |
| **ADB Shell** | 命令行调试 | 灵活，可脚本化 |
| **Unity Profiler** | Unity 专用分析 | 深入 Unity 内部 |

### 1.2 工具链示意

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Unity Android 性能分析工具链                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  开发流程:                                                               │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌──────┐│
│  │ Unity   │───>│ 打包APK │───>│ 安装到  │───>│ 运行App │───>│ 分析 ││
│  │ Editor │    │         │    │ 设备   │    │         │    │ 优化 ││
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘    └──────┘│
│                                                  │                     │
│                                                  ▼                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      性能分析工具                                │   │
│  ├─────────────┬─────────────┬─────────────┬─────────────┬─────────┤   │
│  │Android     │Memory       │GPU          │Layout       │ADB      │   │
│  │Profiler    │Profiler     │Profiler     │Inspector    │Shell    │   │
│  └─────────────┴─────────────┴─────────────┴─────────────┴─────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 二、Android Profiler 使用

### 2.1 启动 Android Profiler

**方式一：从 Android Studio 启动**

```
1. 连接 Android 设备或启动模拟器
2. 打开 Android Studio
3. View → Tool Windows → Profiler
4. 选择目标设备和进程
```

**方式二：命令行启动**

```bash
# 查看连接的设备
adb devices

# 启动 Profiler (Android Studio 3.0+)
# 自动检测可分析的进程
```

### 2.2 CPU Profiler

**用途**：分析 CPU 使用情况和函数调用

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CPU Profiler 功能                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  采样模式 (Sample):                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  • 低开销                                                        │   │
│  │  • 采样间隔可调 (ms 级)                                           │   │
│  │  • 适合长时间监控                                                │   │
│  │  • 显示函数调用占比                                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  嵌入模式 (Instrumented):                                                │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  • 高开销                                                        │   │
│  │  • 精确记录每个函数调用                                          │   │
│  │  • 显示调用时序                                                  │   │
│  │  • 适合短期详细分析                                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**CPU 分析常见问题**：

| 现象 | 可能原因 | 解决方案 |
|-----|---------|---------|
| CPU 占用过高 | 过多 Update 调用 | 减少 FixedUpdate 频率 |
| 卡顿 | 主线程阻塞 | 异步处理，线程池 |
| 发热 | 持续高负载 | 降低帧率，减少计算 |

### 2.3 Memory Profiler

**用途**：分析内存分配和泄漏

```java
// 触发 GC 并捕获堆转储
// 在 Memory Profiler 中:
// 1. 点击 "Capture heap dump"
// 2. 分析对象引用链
// 3. 查找泄漏对象
```

**内存分析要点**：

| 指标 | 说明 | 警告阈值 |
|-----|------|---------|
| **Heap Size** | 堆内存总量 | > 80% 设备内存 |
| **Allocated** | 已分配内存 | 持续增长 |
| **Native Heap** | 原生内存 | 异常增长 |
| **Object Count** | 对象数量 | 短时间暴涨 |

### 2.4 Network Profiler

**用途**：分析网络请求性能

| 监控内容 | 说明 |
|---------|------|
| 请求时序 | 请求时间线 |
| 数据大小 | 请求/响应字节数 |
| 响应时间 | 端到端延迟 |
| 线程分析 | 网络请求所在线程 |

---

## 三、ADB 命令行工具

### 3.1 ADB 基础命令

```bash
# 设备管理
adb devices                          # 列出连接的设备
adb devices -l                        # 详细信息
adb connect <ip>:5555                 # 无线连接
adb disconnect <ip>                   # 断开连接

# 应用管理
adb install app.apk                   # 安装应用
adb install -r app.apk                # 覆盖安装
adb uninstall com.company.app         # 卸载应用
adb shell pm list packages            # 列出所有应用
adb shell pm list packages -3          # 列出第三方应用

# 文件操作
adb push local_file /sdcard/          # 上传文件到设备
adb pull /sdcard/file local_path      # 从设备下载文件
adb shell ls /sdcard/                 # 列出目录
adb shell rm /sdcard/file             # 删除文件

# 日志查看
adb logcat                            # 查看全部日志
adb logcat -s Unity                   # 过滤 Unity 标签
adb logcat -s Unity ActivityManager   # 多标签过滤
adb logcat -c                         # 清除日志
adb logcat -d > log.txt               # 保存日志到文件
```

### 3.2 性能监控命令

```bash
# CPU 使用率
adb shell top -n 1                    # 实时进程信息
adb shell dumpsys cpuinfo             # 详细 CPU 信息

# 内存使用
adb shell dumpsys meminfo com.company.app    # 应用内存详情
adb shell dumpsys meminfo com.company.app -d  # 持续监控

# GPU 使用
adb shell dumpsys gfxinfo com.company.app    # GPU 渲染信息
adb shell dumpsys gfxinfo com.company.app reset  # 重置统计

# 网络状态
adb shell netstat                      # 网络连接
adb shell cat /proc/net/tcp             # TCP 连接详情
```

### 3.3 Frame Stats 帧统计

```bash
# 获取帧率信息
adb shell dumpsys gfxinfo com.company.app

# 关键指标解读:
# ┌─────────────────────────────────────────────────────────────────┐
# │  Metrics                  说明                                 │
# ├─────────────────────────────────────────────────────────────────┤
# │  Frames rendered        渲染帧数                               │
# │  Janky frames           卡顿帧 (>16.6ms)                        │
# │  90th percentile        90%帧的耗时                             │
# │  95th percentile        95%帧的耗时                             │
# │  99th percentile        99%帧的耗时                             │
# │  Number of missed Vsync 错过的垂直同步次数                     │
# └─────────────────────────────────────────────────────────────────┘
```

**理想指标**：

| 指标 | 目标值 |
|-----|-------|
| 90th percentile | < 16.6ms (60fps) |
| 95th percentile | < 33ms (30fps) |
| Janky frames | < 5% |

### 3.4 帧时间详细分析

```bash
# 详细帧分析 (逐帧数据)
adb shell dumpsys gfxinfo com.company.app framestats

# 输出示例:
# Flags       : 0
# IntendedVsync: 1234567890123
# Vsync       : 1234567890125
# OldestInput : 1234567890124
# NewestInput : 1234567890124
# Issue      : 1234567890126
# SyncStart  : 1234567890127
# SyncEnd    : 1234567890130
# Present    : 1234567890131
# ...
```

---

## 四、Unity Android 优化技巧

### 4.1 图形优化

| 优化项 | 设置 | 效果 |
|-------|------|------|
| **目标帧率** | Application.targetFrameRate = 30 | 降低 CPU/GPU 负载 |
| **垂直同步** | QualitySettings.vSyncCount | 避免撕裂 |
| **MSAA** | 禁用或 2x | 平衡质量与性能 |
| **阴影** | 降低阴影距离/分辨率 | 减少 GPU 负载 |
| **像素光** | 限制数量 | 减少计算 |

```csharp
using UnityEngine;

/// <summary>
/// Android 性能设置
/// </summary>
public class AndroidPerformanceSettings : MonoBehaviour
{
    [System.Serializable]
    public class QualityPreset
    {
        public string presetName;
        public int targetFrameRate = 30;
        public int vSyncCount = 1;
        public int textureQuality = 0;
        public int shadowResolution = 1;
        public int shadowDistance = 50;
        public int pixelLightCount = 2;
    }

    public QualityPreset low;
    public QualityPreset medium;
    public QualityPreset high;

    void Start()
    {
        ApplyQualityPreset(medium);
    }

    public void ApplyQualityPreset(QualityPreset preset)
    {
        // 帧率设置
        Application.targetFrameRate = preset.targetFrameRate;

        // 垂直同步
        QualitySettings.vSyncCount = preset.vSyncCount;

        // 纹理质量
        QualitySettings.masterTextureLimit = preset.textureQuality;

        // 阴影设置
        QualitySettings.shadowResolution = (ShadowResolution)preset.shadowResolution;
        QualitySettings.shadowDistance = preset.shadowDistance;

        // 像素光
        QualitySettings.pixelLightCount = preset.pixelLightCount;
    }
}
```

### 4.2 内存优化

**纹理优化**：

```csharp
// 纹理压缩设置
// Edit → Project Settings → Player → Android → Texture Compression
// 推荐: ASTC (Adaptive Scalable Texture Compression)

// 运行时纹理加载优化
using UnityEngine;

public class TextureOptimization : MonoBehaviour
{
    [Header("纹理设置")]
    public int maxTextureSize = 1024;
    public TextureCompression compressionFormat = TextureCompression.ASTC;

    void Start()
    {
        OptimizeTextures();
    }

    void OptimizeTextures()
    {
        // 获取所有纹理
        Texture2D[] textures = Resources.FindObjectsOfTypeAll<Texture2D>();

        foreach (var tex in textures)
        {
            // 调整导入设置
            // (需要在 Editor 中设置，运行时无法修改压缩格式)
        }
    }
}
```

**对象池**：

```csharp
using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Android 对象池
/// </summary>
public class AndroidObjectPool : MonoBehaviour
{
    private Dictionary<string, Queue<GameObject>> pools = new Dictionary<string, Queue<GameObject>>();

    /// <summary>
    /// 获取对象
    /// </summary>
    public GameObject Get(GameObject prefab)
    {
        string key = prefab.name;

        if (pools.ContainsKey(key) && pools[key].Count > 0)
        {
            GameObject obj = pools[key].Dequeue();
            obj.SetActive(true);
            return obj;
        }

        return Instantiate(prefab);
    }

    /// <summary>
    /// 回收对象
    /// </summary>
    public void Return(GameObject obj, float delay = 0f)
    {
        if (delay > 0)
        {
            StartCoroutine(ReturnDelayed(obj, delay));
        }
        else
        {
            obj.SetActive(false);
            ReturnToPool(obj);
        }
    }

    private IEnumerator ReturnDelayed(GameObject obj, float delay)
    {
        yield return new WaitForSeconds(delay);
        obj.SetActive(false);
        ReturnToPool(obj);
    }

    private void ReturnToPool(GameObject obj)
    {
        string key = obj.name.Replace("(Clone)", "");

        if (!pools.ContainsKey(key))
            pools[key] = new Queue<GameObject>();

        pools[key].Enqueue(obj);
    }
}
```

### 4.3 代码优化

**协程 vs Update**：

```csharp
using UnityEngine;
using System.Collections;

/// <summary>
/// 使用协程替代 Update 以降低调用频率
/// </summary>
public class CoroutineOptimization : MonoBehaviour
{
    // 低频检查 (每秒一次)
    IEnumerator LowFrequencyCheck()
    {
        while (true)
        {
            // 检查逻辑
            CheckGameState();
            yield return new WaitForSeconds(1f);
        }
    }

    // 中频检查 (每 0.1 秒一次)
    IEnumerator MediumFrequencyCheck()
    {
        while (true)
        {
            // AI 决策等
            UpdateAI();
            yield return new WaitForSeconds(0.1f);
        }
    }

    void Start()
    {
        StartCoroutine(LowFrequencyCheck());
        StartCoroutine(MediumFrequencyCheck());
    }

    void CheckGameState() { }
    void UpdateAI() { }
}
```

**避免装箱**：

```csharp
// ❌ 错误：产生装箱
int value = 42;
string text = "Value: " + value;  // value 被装箱

// ✅ 正确：避免装箱
int value = 42;
string text = $"Value: {value}";  // 使用字符串插值

// ✅ 正确：使用 StringBuilder
System.Text.StringBuilder sb = new System.Text.StringBuilder();
sb.Append("Value: ");
sb.Append(value);
```

---

## 五、常见问题诊断

### 5.1 过热问题

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Android 设备过热诊断                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  可能原因:                                                               │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  1. CPU 持续高负载                                                │   │
│  │  2. GPU 高负载 (高分辨率/高帧率)                                   │   │
│  │  3. 网络频繁请求                                                  │   │
│  │  4. 后台服务运行                                                  │   │
│  │  5. 电池管理冲突                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  解决方案:                                                               │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  1. 降低目标帧率 (30fps)                                          │   │
│  │  2. 降低屏幕分辨率                                                │   │
│  │  3. 启用批处理 (Batching)                                         │   │
│  │  4. 减少实时阴影                                                  │   │
│  │  5. 优化物理计算频率                                              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 内存增长

```bash
# 监控内存增长
adb shell dumpsys meminfo com.company.app -d | grep "TOTAL"

# 输出示例:
# TOTAL: 123456 (TOTAL): 456789 (TOTAL): 567890
#            ^ 进程内存    ^ Native堆       ^ 总内存
#
# 如果持续增长，可能存在内存泄漏
```

**常见内存泄漏源**：

| 来源 | 说明 | 检测方法 |
|-----|------|---------|
| 事件监听 | 未取消订阅 | 检查 OnDestroy |
| 静态引用 | 持有对象引用 | Memory Profiler |
| 协程 | 未正确停止 | 检查 StopCoroutine |
| 纹理 | 未释放资源 | Resources.UnloadUnusedAssets |
| WebView | 未销毁 | 检查生命周期 |

### 5.3 闪退分析

```bash
# 获取闪退日志
adb logcat -b crash -b system -b main | grep -E "FATAL|AndroidRuntime"

# 查看闪退详情
adb logcat -c                          # 清除日志
adb logcat -s Unity:V AndroidRuntime:E  # 过滤关键日志
# 重现闪退
adb logcat -d > crash_log.txt           # 保存日志
```

---

## 六、高级技巧

### 6.1 自定义性能监控

```csharp
using UnityEngine;
using System.Diagnostics;

/// <summary>
/// 移动端性能监控器
/// </summary>
public class MobilePerformanceMonitor : MonoBehaviour
{
    [Header("显示设置")]
    public bool showOnScreen = true;
    public Vector2 position = new Vector2(10, 10);
    public int fontSize = 20;

    [Header("警告阈值")]
    public float warningFrameTime = 20f;  // ms
    public Color warningColor = Color.red;

    // 性能数据
    private float fps;
    private float frameTime;
    private float memoryUsage;
    private int drawCalls;
    private int triangles;

    private float deltaTime;
    private int frameCount;
    private float fpsUpdateInterval = 0.5f;
    private float fpsTimer;

    void Update()
    {
        deltaTime += Time.unscaledDeltaTime;
        frameCount++;

        if (deltaTime >= fpsUpdateInterval)
        {
            fps = frameCount / deltaTime;
            frameTime = (deltaTime / frameCount) * 1000f;  // ms
            frameCount = 0;
            deltaTime = 0f;

            // 获取内存使用
            memoryUsage = System.GC.GetTotalMemory(false) / (1024f * 1024f);  // MB

            // 获取渲染数据
            drawCalls = UnityEngine.Statistics.DrawCalls;
            triangles = UnityEngine.Statistics.Triangles;
        }
    }

    void OnGUI()
    {
        if (!showOnScreen) return;

        GUIStyle style = new GUIStyle(GUI.skin.label);
        style.fontSize = fontSize;
        style.normal.textColor = frameTime > warningFrameTime ? warningColor : Color.white;

        GUILayout.BeginArea(new Rect(position.x, position.y, 400, 300));
        GUILayout.Label($"FPS: {fps:F1}", style);
        GUILayout.Label($"Frame Time: {frameTime:F2} ms", style);
        GUILayout.Label($"Memory: {memoryUsage:F1} MB", style);
        GUILayout.Label($"Draw Calls: {drawCalls}", style);
        GUILayout.Label($"Triangles: {triangles}", style);
        GUILayout.EndArea();
    }
}
```

### 6.2 远程性能数据收集

```csharp
using UnityEngine;
using System;
using System.Collections.Generic;

/// <summary>
/// 性能数据收集与上报
/// </summary>
public class PerformanceDataCollector : MonoBehaviour
{
    [System.Serializable]
    public class PerformanceReport
    {
        public string deviceModel;
        public string osVersion;
        public float averageFps;
        public float maxFrameTime;
        public float averageMemory;
        public long timestamp;
    }

    private List<float> frameTimes = new List<float>();
    private List<float> memorySamples = new List<float>();
    private int maxSamples = 1000;

    void Update()
    {
        frameTimes.Add(Time.unscaledDeltaTime * 1000f);

        if (frameTimes.Count > maxSamples)
            frameTimes.RemoveAt(0);
    }

    void LateUpdate()
    {
        memorySamples.Add(System.GC.GetTotalMemory(false) / (1024f * 1024f));

        if (memorySamples.Count > maxSamples)
            memorySamples.RemoveAt(0);
    }

    /// <summary>
    /// 生成性能报告
    /// </summary>
    public PerformanceReport GenerateReport()
    {
        float avgFps = 0f;
        float maxFrameTime = 0f;
        float avgMemory = 0f;

        if (frameTimes.Count > 0)
        {
            float totalFrameTime = 0f;
            foreach (float ft in frameTimes)
            {
                totalFrameTime += ft;
                if (ft > maxFrameTime)
                    maxFrameTime = ft;
            }
            avgFps = 1000f / (totalFrameTime / frameTimes.Count);
        }

        if (memorySamples.Count > 0)
        {
            float totalMemory = 0f;
            foreach (float mem in memorySamples)
            {
                totalMemory += mem;
            }
            avgMemory = totalMemory / memorySamples.Count;
        }

        return new PerformanceReport
        {
            deviceModel = SystemInfo.deviceModel,
            osVersion = SystemInfo.operatingSystem,
            averageFps = avgFps,
            maxFrameTime = maxFrameTime,
            averageMemory = avgMemory,
            timestamp = DateTime.UtcNow.Ticks
        };
    }
}
```

---

## 七、优化检查清单

### 7.1 发布前检查

| 类别 | 检查项 | 状态 |
|-----|-------|------|
| **图形** | 目标帧率设置为 30 | ⬜ |
| **图形** | 启用纹理压缩 (ASTC) | ⬜ |
| **图形** | 降低阴影距离/质量 | ⬜ |
| **图形** | 限制像素光数量 | ⬜ |
| **内存** | 释放未使用资源 | ⬜ |
| **内存** | 使用对象池 | ⬜ |
| **内存** | 避免频繁 GC | ⬜ |
| **代码** | 优化 Update 调用 | ⬜ |
| **代码** | 使用对象池 | ⬜ |
| **代码** | 避免装箱拆箱 | ⬜ |
| **构建** | 使用 IL2CPP | ⬜ |
| **构建** | 启用 Strip Engine Code | ⬜ |
| **构建** | 设置 API Level | ⬜ |

### 7.2 Player 设置推荐

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Unity Android Player 设置                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Graphics API:                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  • Auto Graphics API (自动选择)                                  │   │
│  │  • 或者强制使用 Vulkan (高端设备) / GLES 3.0 (中低端)           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Scripting Backend:                                                     │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  • IL2CPP (性能更好，包体更小)                                   │   │
│  │  • Mono (开发阶段使用)                                           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Target Architecture:                                                   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  • ARM64 (推荐，主流设备)                                       │   │
│  │  • ARMv7 (兼容老设备)                                           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Optimization:                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  • Prebake Collision Meshes                                      │   │
│  │  • Keep Loaded Shaders                                          │   │
│  │  • Strip Engine Code                                            │   │
│  │  • Use Float Position For Temporal AA (如需要)                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 八、总结

| 主题 | 要点 |
|-----|------|
| **工具** | Android Profiler + ADB + Unity Profiler |
| **CPU** | 降低帧率，减少 Update 调用，使用协程 |
| **内存** | 对象池，纹理压缩，及时释放资源 |
| **GPU** | 降低分辨率，减少阴影/光效 |
| **网络** | 合并请求，减少连接数 |
| **诊断** | dumpsys + logcat 定位问题 |

> 💡 **核心建议**：
> - 首先使用 Android Profiler 定位瓶颈
> - 优先解决最严重的性能问题
> - 在真机上测试，不要依赖模拟器
> - 建立性能基准，持续监控
> - 针对不同设备档次设置不同质量档位

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

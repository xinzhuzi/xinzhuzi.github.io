---
title: "Unity AssetBundle 打包策略精要：打造完美热更新系统的艺术"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, AssetBundle, 打包策略, 热更新, 资源管理, 依赖管理, 最佳实践]
image: /images/unity-assetbundle-packaging-strategy-banner.jpg
---

# 🎯 Unity AssetBundle 打包策略精要：打造完美热更新系统的艺术

> 💡 **打包策略的重要性**：
> - 为什么有些项目的 AB 包只有几十 MB，有些却有几百 MB？
> - 如何平衡热更新的灵活性和包体大小？
> - 依赖关系太复杂导致打包失败怎么办？
> - 如何设计一个可扩展、易维护的打包系统？
>
> **深度解析**！从简单打包到企业级解决方案，手把手教你构建完美的资源打包策略！

---

## 一、打包策略概述

### 1.1 打包目标

| 目标 | 说明 | 重要性 |
|-----|------|-------|
| **最小化冗余** | 避免相同资源被打包多次 | ⭐⭐⭐⭐⭐ |
| **按需加载** | 细粒度打包，支持动态加载 | ⭐⭐⭐⭐ |
| **依赖清晰** | 包间依赖关系可追踪 | ⭐⭐⭐⭐⭐ |
| **热更新友好** | 支持增量更新 | ⭐⭐⭐⭐ |
| **加载高效** | 减少包数量和加载次数 | ⭐⭐⭐ |

### 1.2 打包粒度对比

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        打包粒度对比                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    │
│  │   粗粒度打包    │    │   中等粒度      │    │   细粒度打包    │    │
│  │  (整体打包)     │    │   (分类打包)    │    │  (单独打包)     │    │
│  ├─────────────────┤    ├─────────────────┤    ├─────────────────┤    │
│  │ • 所有资源一包  │    │ • 按类型/场景   │    │ • 每资源一包    │    │
│  │ • 无法热更新    │    │ • 灵活性适中    │    │ • 最大灵活性    │    │
│  │ • 加载简单      │    │ • 热更新较方便  │    │ • 热更新最方便  │    │
│  │ ❌ 不推荐       │    │ • 平衡方案      │    │ • 管理复杂      │    │
│  │                 │    │ ✅ 常用方案     │    │ • 依赖需精细    │    │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 二、简单打包：StreamingAssets

### 2.1 基础打包

最简单的打包方式：直接将资源打包到 `StreamingAssets` 文件夹。

```csharp
using UnityEditor;
using UnityEngine;

public static class SimpleAssetBundleBuilder
{
    [MenuItem("Tools/Build Simple AssetBundles")]
    public static void BuildSimpleAssetBundles()
    {
        // 打包到 StreamingAssets，资源会随应用安装
        string outputPath = Application.streamingAssetsPath;

        // 构建 AssetBundle
        BuildPipeline.BuildAssetBundles(
            outputPath,
            BuildAssetBundleOptions.ChunkBasedCompression, // LZ4 压缩
            EditorUserBuildSettings.activeBuildTarget
        );

        // 刷新资源
        AssetDatabase.Refresh();

        Debug.Log($"AssetBundle 打包完成: {outputPath}");
    }
}
```

### 2.2 特点分析

| 特点 | 说明 |
|-----|------|
| **优点** | 简单易用，资源随包安装，无需下载 |
| **缺点** | 无法热更新，增加包体大小 |
| **适用** | 基础资源、首屏必需资源 |

---

## 三、自定义打包策略

### 3.1 策略配置 (ScriptableObject)

使用 `ScriptableObject` 配置不同类型资源的打包规则。

```csharp
using UnityEngine;
using System.Collections.Generic;

[CreateAssetMenu(fileName = "AssetBundleConfig", menuName = "Game/AssetBundle Config")]
public class AssetBundleConfig : ScriptableObject
{
    [System.Serializable]
    public class BundleRule
    {
        public AssetType assetType;
        public string bundleName;      // AB 包名称前缀
        public string[] extensions;    // 文件扩展名
        public string[] searchPaths;   // 搜索路径
        public bool singleBundle;      // 是否打成一个包
    }

    public enum AssetType
    {
        Prefab,
        Scene,
        Model,
        Shader,
        Audio,
        Texture,
        SpriteAtlas,
        Material,
        Config,    // ScriptableObject
        Data       // bytes, xml, json
    }

    public List<BundleRule> rules = new List<BundleRule>();

    // 全局配置
    [Header("Global Settings")]
    public string bundleNamePrefix = "game_";     // 包名前缀
    public bool useLowercase = true;              // 使用小写
    public bool includeVersionNumber = false;     // 包含版本号
    public string versionFile = "version.json";   // 版本文件名
}
```

### 3.2 打包命名规则

```csharp
using System.Text;

public static class AssetBundleNaming
{
    /// <summary>
    /// 生成 AB 包名称
    /// 规则：前缀 + 类型 + 资源名（纯小写，无特殊字符）
    /// </summary>
    public static string GetBundleName(string assetPath, AssetBundleConfig.AssetType type, string prefix)
    {
        // 获取不含扩展名的资源名
        string fileName = System.IO.Path.GetFileNameWithoutExtension(assetPath);

        // 转换为小写，移除特殊字符
        fileName = NormalizeName(fileName);

        // 组合包名
        StringBuilder sb = new StringBuilder();
        sb.Append(prefix);
        sb.Append(GetTypePrefix(type));
        sb.Append("_");
        sb.Append(fileName);

        return sb.ToString();
    }

    /// <summary>
    /// 标准化名称：小写、无空格、无特殊字符
    /// </summary>
    private static string NormalizeName(string name)
    {
        name = name.ToLower();
        name = System.Text.RegularExpressions.Regex.Replace(name, @"[^a-z0-9_]", "_");
        return name;
    }

    /// <summary>
    /// 获取类型前缀
    /// </summary>
    private static string GetTypePrefix(AssetBundleConfig.AssetType type)
    {
        return type switch
        {
            AssetBundleConfig.AssetType.Prefab => "prefab",
            AssetBundleConfig.AssetType.Scene => "scene",
            AssetBundleConfig.AssetType.Model => "model",
            AssetBundleConfig.AssetType.Shader => "shader",
            AssetBundleConfig.AssetType.Audio => "audio",
            AssetBundleConfig.AssetType.Texture => "tex",
            AssetBundleConfig.AssetType.SpriteAtlas => "atlas",
            AssetBundleConfig.AssetType.Material => "mat",
            AssetBundleConfig.AssetType.Config => "config",
            AssetBundleConfig.AssetType.Data => "data",
            _ => "common"
        };
    }
}
```

---

## 四、依赖关系管理

### 4.1 依赖关系查找

```csharp
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public static class DependencyAnalyzer
{
    /// <summary>
    /// 获取资源的所有依赖
    /// </summary>
    public static string[] GetDependencies(string assetPath, bool recursive = false)
    {
        if (!recursive)
        {
            return AssetDatabase.GetDependencies(assetPath, false);
        }

        // 递归获取所有依赖
        HashSet<string> allDeps = new HashSet<string>();
        Queue<string> queue = new Queue<string>();

        queue.Enqueue(assetPath);
        allDeps.Add(assetPath);

        while (queue.Count > 0)
        {
            string current = queue.Dequeue();
            string[] deps = AssetDatabase.GetDependencies(current, false);

            foreach (string dep in deps)
            {
                // 排除自身和脚本文件
                if (dep != current && !dep.EndsWith(".cs"))
                {
                    if (allDeps.Add(dep))
                    {
                        queue.Enqueue(dep);
                    }
                }
            }
        }

        allDeps.Remove(assetPath);
        return allDeps.ToArray();
    }

    /// <summary>
    /// 分析并移除冗余依赖
    /// </summary>
    public static Dictionary<string, string[]> RemoveRedundantDependencies(
        Dictionary<string, string[]> bundleDependencies)
    {
        // 找出被多个包共享的依赖
        Dictionary<string, List<string>> sharedDeps = new Dictionary<string, List<string>>();

        foreach (var kvp in bundleDependencies)
        {
            string bundleName = kvp.Key;
            foreach (string dep in kvp.Value)
            {
                if (!sharedDeps.ContainsKey(dep))
                {
                    sharedDeps[dep] = new List<string>();
                }
                sharedDeps[dep].Add(bundleName);
            }
        }

        // 被超过 N 个包依赖的资源应独立打包
        int threshold = 3;
        Dictionary<string, string[]> result = new Dictionary<string, string[]>();

        foreach (var kvp in bundleDependencies)
        {
            List<string> filtered = kvp.Value
                .Where(dep => !sharedDeps.ContainsKey(dep) || sharedDeps[dep].Count <= threshold)
                .ToList();

            result[kvp.Key] = filtered.ToArray();
        }

        return result;
    }
}
```

### 4.2 依赖关系表

```csharp
using System;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class AssetBundleManifestData
{
    [Serializable]
    public class BundleInfo
    {
        public string bundleName;
        public string hash;
        public long size;
        public string[] dependencies;
        public string[] assets;
    }

    public List<BundleInfo> bundles = new List<BundleInfo>();
    public int version;

    public void Save(string path)
    {
        string json = JsonUtility.ToJson(this, true);
        System.IO.File.WriteAllText(path, json);
    }

    public static AssetBundleManifestData Load(string path)
    {
        if (System.IO.File.Exists(path))
        {
            string json = System.IO.File.ReadAllText(path);
            return JsonUtility.FromJson<AssetBundleManifestData>(json);
        }
        return new AssetBundleManifestData();
    }
}
```

---

## 五、完整打包系统

### 5.1 打包器实现

```csharp
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class AssetBundlePackager
{
    private AssetBundleConfig config;
    private AssetBundleManifestData manifestData;
    private string outputPath;

    public AssetBundlePackager(AssetBundleConfig config)
    {
        this.config = config;
        this.outputPath = Path.Combine("AssetBundles", GetPlatformName());
        this.manifestData = new AssetBundleManifestData();
    }

    public void Build()
    {
        Debug.Log("开始打包 AssetBundle...");

        // 1. 清理输出目录
        EnsureOutputDirectory();

        // 2. 收集打包资源
        List<AssetBundleBuild> builds = CollectBuilds();

        if (builds.Count == 0)
        {
            Debug.LogWarning("没有找到需要打包的资源");
            return;
        }

        // 3. 执行打包
        var manifest = BuildPipeline.BuildAssetBundles(
            outputPath,
            builds.ToArray(),
            BuildAssetBundleOptions.ChunkBasedCompression | BuildAssetBundleOptions.DisableWriteTypeTree,
            EditorUserBuildSettings.activeBuildTarget
        );

        if (manifest == null)
        {
            Debug.LogError("AssetBundle 打包失败");
            return;
        }

        // 4. 分析并生成依赖关系表
        GenerateManifestData(manifest);

        // 5. 保存依赖关系表
        string manifestPath = Path.Combine(outputPath, config.versionFile);
        manifestData.version = GetNextVersion();
        manifestData.Save(manifestPath);

        // 6. 复制到 StreamingAssets（可选）
        CopyToStreamingAssets();

        Debug.Log($"AssetBundle 打包完成! 共 {builds.Count} 个包");
    }

    private void EnsureOutputDirectory()
    {
        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }

        // 清理旧文件
        foreach (var file in Directory.GetFiles(outputPath))
        {
            if (!file.EndsWith(".meta"))
            {
                File.Delete(file);
            }
        }
    }

    private List<AssetBundleBuild> CollectBuilds()
    {
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();

        foreach (var rule in config.rules)
        {
            foreach (var assetPath in CollectAssetsByRule(rule))
            {
                string bundleName = AssetBundleNaming.GetBundleName(
                    assetPath,
                    rule.assetType,
                    config.bundleNamePrefix
                );

                builds.Add(new AssetBundleBuild
                {
                    assetBundleName = bundleName,
                    assetNames = new[] { assetPath }
                });
            }
        }

        return builds;
    }

    private IEnumerable<string> CollectAssetsByRule(AssetBundleConfig.BundleRule rule)
    {
        foreach (var searchPath in rule.searchPaths)
        {
            string fullPath = Path.Combine("Assets", searchPath);
            if (!Directory.Exists(fullPath)) continue;

            foreach (var ext in rule.extensions)
            {
                foreach (var file in Directory.GetFiles(fullPath, "*" + ext, SearchOption.AllDirectories))
                {
                    string assetPath = "Assets" + file.Substring(Application.dataPath.Length);
                    yield return assetPath;
                }
            }
        }
    }

    private void GenerateManifestData(AssetBundleManifest unityManifest)
    {
        manifestData.bundles.Clear();

        string[] allBundles = unityManifest.GetAllAssetBundles();

        foreach (string bundle in allBundles)
        {
            var bundleInfo = new AssetBundleManifestData.BundleInfo
            {
                bundleName = bundle,
                hash = GetBundleHash(bundle, unityManifest),
                dependencies = unityManifest.GetAllDependencies(bundle),
                assets = unityManifest.GetAllAssetBundles()
            };

            manifestData.bundles.Add(bundleInfo);
        }
    }

    private string GetBundleHash(string bundleName, AssetBundleManifest manifest)
    {
        // Unity 2017+ 使用 Hash128
        return manifest.GetAssetBundleHash(bundleName).ToString();
    }

    private int GetNextVersion()
    {
        return DateTime.Now.ToString("yyyyMMddHHmmss").ToInt();
    }

    private void CopyToStreamingAssets()
    {
        string streamingPath = Path.Combine(Application.streamingAssetsPath, "AssetBundles");

        if (Directory.Exists(streamingPath))
        {
            Directory.Delete(streamingPath, true);
        }

        DirectoryCopy(outputPath, streamingPath, true);
        AssetDatabase.Refresh();
    }

    private static void DirectoryCopy(string sourceDir, string targetDir, bool recursive)
    {
        DirectoryInfo dir = new DirectoryInfo(sourceDir);
        DirectoryInfo[] dirs = dir.GetDirectories();

        if (!Directory.Exists(targetDir))
        {
            Directory.CreateDirectory(targetDir);
        }

        FileInfo[] files = dir.GetFiles();
        foreach (FileInfo file in files)
        {
            string tempPath = Path.Combine(targetDir, file.Name);
            file.CopyTo(tempPath, false);
        }

        if (recursive)
        {
            foreach (DirectoryInfo subdir in dirs)
            {
                string tempPath = Path.Combine(targetDir, subdir.Name);
                DirectoryCopy(subdir.FullName, tempPath, recursive);
            }
        }
    }

    private static string GetPlatformName()
    {
        return EditorUserBuildSettings.activeBuildTarget switch
        {
            BuildTarget.StandaloneWindows => "Windows",
            BuildTarget.StandaloneOSX => "macOS",
            BuildTarget.StandaloneLinux64 => "Linux",
            BuildTarget.iOS => "iOS",
            BuildTarget.Android => "Android",
            BuildTarget.WebGL => "WebGL",
            _ => "Unknown"
        };
    }
}
```

### 5.2 打包编辑器窗口

```csharp
using UnityEditor;
using UnityEngine;

public class AssetBundleBuilderWindow : EditorWindow
{
    private AssetBundleConfig config;
    private Vector2 scrollPosition;

    [MenuItem("Tools/AssetBundle Builder")]
    public static void ShowWindow()
    {
        var window = GetWindow<AssetBundleBuilderWindow>("AB Builder");
        window.minSize = new Vector2(400, 600);
    }

    private void OnEnable()
    {
        // 加载配置
        LoadConfig();
    }

    private void OnGUI()
    {
        EditorGUILayout.Title("AssetBundle 打包工具", TextStyle.Bold);

        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

        // 配置区域
        DrawConfigSection();

        // 规则列表
        DrawRulesSection();

        EditorGUILayout.EndScrollView();

        // 底部按钮
        DrawBottomButtons();
    }

    private void DrawConfigSection()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("打包配置", EditorStyles.boldLabel);

        config = (AssetBundleConfig)EditorGUILayout.ObjectField(
            "配置文件",
            config,
            typeof(AssetBundleConfig),
            false
        );

        if (config != null)
        {
            SerializedObject so = new SerializedObject(config);
            so.Update();

            SerializedProperty prop = so.GetIterator();
            prop.NextVisible(true); // skip script
            while (prop.NextVisible(false))
            {
                EditorGUILayout.PropertyField(prop, true);
            }

            so.ApplyModifiedProperties();
        }
    }

    private void DrawRulesSection()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("打包规则", EditorStyles.boldLabel);

        if (config == null)
        {
            EditorGUILayout.HelpBox("请先选择配置文件", MessageType.Warning);
            return;
        }

        for (int i = 0; i < config.rules.Count; i++)
        {
            DrawRuleItem(i);
        }

        if (GUILayout.Button("添加规则", GUILayout.Height(30)))
        {
            config.rules.Add(new AssetBundleConfig.BundleRule());
            EditorUtility.SetDirty(config);
        }
    }

    private void DrawRuleItem(int index)
    {
        var rule = config.rules[index];

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField($"规则 {index + 1}: {rule.assetType}", EditorStyles.boldLabel);
        if (GUILayout.Button("×", GUILayout.Width(30)))
        {
            config.rules.RemoveAt(index);
            EditorUtility.SetDirty(config);
            return;
        }
        EditorGUILayout.EndHorizontal();

        rule.assetType = (AssetBundleConfig.AssetType)EditorGUILayout.EnumPopup("类型", rule.assetType);
        rule.bundleName = EditorGUILayout.TextField("包名", rule.bundleName);
        rule.singleBundle = EditorGUILayout.Toggle("单独打包", rule.singleBundle);

        // 扩展名编辑
        EditorGUILayout.LabelField("文件扩展名:");
        for (int i = 0; i < rule.extensions.Length; i++)
        {
            EditorGUILayout.BeginHorizontal();
            rule.extensions[i] = EditorGUILayout.TextField(rule.extensions[i]);
            if (GUILayout.Button("×", GUILayout.Width(30)))
            {
                var list = new System.Collections.Generic.List<string>(rule.extensions);
                list.RemoveAt(i);
                rule.extensions = list.ToArray();
                EditorUtility.SetDirty(config);
                return;
            }
            EditorGUILayout.EndHorizontal();
        }
        if (GUILayout.Button("添加扩展名"))
        {
            var list = new System.Collections.Generic.List<string>(rule.extensions);
            list.Add("");
            rule.extensions = list.ToArray();
            EditorUtility.SetDirty(config);
        }

        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();
    }

    private void DrawBottomButtons()
    {
        EditorGUILayout.Space();
        EditorGUILayout.BeginHorizontal();

        if (GUILayout.Button("创建配置", GUILayout.Height(40)))
        {
            CreateNewConfig();
        }

        if (GUILayout.Button("开始打包", GUILayout.Height(40)))
        {
            BuildAssetBundles();
        }

        EditorGUILayout.EndHorizontal();
    }

    private void CreateNewConfig()
    {
        string path = "Assets/AssetBundleConfig.asset";
        AssetBundleConfig newConfig = CreateInstance<AssetBundleConfig>();
        AssetDatabase.CreateAsset(newConfig, path);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        config = newConfig;
        LoadConfig();
    }

    private void LoadConfig()
    {
        string[] guids = AssetDatabase.FindAssets("t:AssetBundleConfig");
        if (guids.Length > 0)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[0]);
            config = AssetDatabase.LoadAssetAtPath<AssetBundleConfig>(path);
        }
    }

    private void BuildAssetBundles()
    {
        if (config == null)
        {
            EditorUtility.DisplayDialog("错误", "请先创建配置文件", "确定");
            return;
        }

        AssetBundlePackager packager = new AssetBundlePackager(config);
        packager.Build();
    }
}
```

---

## 六、打包最佳实践

### 6.1 打包规则建议

| 资源类型 | 打包粒度 | 包名格式 | 说明 |
|---------|---------|---------|------|
| **Prefab** | 单个 | `prefab_[name]` | 每个预制体独立打包 |
| **Scene** | 单个 | `scene_[name]` | 每个场景独立打包 |
| **Shader** | 全部 | `shader_all` | 所有 Shader 打成一个包 |
| **Material** | 单个 | `mat_[name]` | 每个材质独立打包 |
| **Texture** | 单个或分组 | `tex_[name]` | 根据大小和使用频率决定 |
| **AudioClip** | 分组 | `audio_[type]` | 按类型分组（BGM、SFX） |
| **Font** | 单个 | `font_[name]` | 每个字体独立打包 |
| **SpriteAtlas** | 单个 | `atlas_[name]` | 每个图集独立打包 |
| **AnimationClip** | 跟随 Prefab | - | 一般不单独打包 |

### 6.2 命名规范

```csharp
// 推荐的包命名格式
{prefix}_{type}_{name}_{variant}

// 示例
game_prefab_player           // 玩家预制体
game_prefab_enemy_slime      // 史莱姆敌人
game_scene_main              // 主场景
game_mat_character          // 角色材质
game_tex_ui_common          // UI 通用贴图
game_audio_bgm_battle       // 战斗BGM
game_font_main               // 主字体
```

### 6.3 压缩选项

```csharp
// LZ4 压缩（推荐）
BuildAssetBundleOptions.ChunkBasedCompression

// 特点：
// - 单个块可独立加载
// - 支持从 CDN 流式加载
// - 压缩比适中，速度快
// - 推荐：大多数项目

// LZMA 压缩
BuildAssetBundleOptions.CompressWithLzma

// 特点：
// - 压缩比最高
// - 需要完全解压后才能使用
// - 不推荐：热更新场景

// 无压缩
BuildAssetBundleOptions.UncompressedAssetBundle

// 特点：
// - 包体最大
// - 加载最快
// - 适用：已压缩的格式（如音频、视频）
```

---

## 七、总结

| 要点 | 说明 |
|-----|------|
| **命名规范** | 统一前缀、类型标识、小写、无特殊字符 |
| **依赖管理** | 提取共享依赖，避免冗余 |
| **打包粒度** | 根据资源特性和更新频率决定 |
| **压缩方式** | 优先使用 LZ4（ChunkBasedCompression） |
| **版本管理** | 生成版本文件，支持增量更新 |
| **工具化** | 使用 ScriptableObject 配置 + Editor Window |

> 💡 **核心原则**：
> - Prefab/Scene 单独打包，支持灵活更新
> - Shader 集中打包，初始化时预加载
> - Texture/Material 按需打包，减少冗余
> - 始终使用 `AssetDatabase.GetDependencies()` 分析依赖
> - 打包后验证 `AssetBundleManifest` 的依赖关系

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

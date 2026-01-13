---
title: "Unity AssetBundle 完全手册：从入门到精通的资源管理圣经"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, AssetBundle, 热更新, 资源管理, 打包策略, 内存管理, 依赖分析, 加载优化]
image: /images/unity-assetbundle-complete-guide-banner.jpg
---

# 📦 Unity AssetBundle 完全手册：从入门到精通的资源管理圣经

> 💡 **AssetBundle 的价值**：
> - 如何实现游戏的热更新，避免每次更新都要重新审核？
> - 资源加载太慢、内存占用过高，怎么优化？
> - 依赖关系混乱、循环依赖、包体过大怎么办？
> - 如何构建一个稳定高效的资源管理系统？
>
> **完全指南**！从概念到实践，从打包到加载，从热更新到内存管理，一文搞懂 Unity AssetBundle！

---

## 一、AssetBundle 概念

### 1.1 什么是 AssetBundle

| 特性 | 说明 |
|-----|------|
| **定义** | 一个存档文件，包含可在运行时加载的特定于平台的资源 |
| **包含内容** | 模型、纹理、预制件、音频剪辑甚至整个场景 |
| **依赖关系** | 可以表达彼此之间的依赖关系 |
| **压缩方式** | 目前一般采用 LZ4 压缩（ChunkBasedCompression） |

### 1.2 AssetBundle 内部结构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AssetBundle 文件结构                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    AssetBundle 文件                              │   │
│  ├─────────────────────────────────────────────────────────────────┤   │
│  │                                                                 │   │
│  │  ┌─────────────────────┐    ┌─────────────────────────────────┐ │   │
│  │  │   序列化文件         │    │      资源文件                  │ │   │
│  │  ├─────────────────────┤    ├─────────────────────────────────┤ │   │
│  │  │ • 对象数据          │    │ • 二进制数据块                 │ │   │
│  │  │ • 依赖关系          │    │ • 纹理数据                     │ │   │
│  │  │ • 映射信息          │    │ • 音频数据                     │ │   │
│  │  │ • 引用关系          │    │ • 可异步加载                   │ │   │
│  │  └─────────────────────┘    └─────────────────────────────────┘ │   │
│  │                                                                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.3 打包分类

| 类型 | 说明 | 用途 |
|-----|------|------|
| **随包资源** | 跟随 APK/IPA 进行安装 | 基础资源，首次运行必需 |
| **增量包** | 上传到 CDN 服务器 | 热更新资源，按需下载 |

---

## 二、资源类型与依赖关系

### 2.1 各类资源打包策略

| 资源类型 | 打包策略 | 说明 |
|---------|---------|------|
| **AnimationClip** | 跟随 Prefab 或多个打包一个 AB | 动画片段，可单独或组合打包 |
| **AudioClip** | 跟随 Prefab 或多个打包一个 AB | 音频文件 |
| **VideoClip** | 建议随包安装或单独下载 | 文件较大，不建议 AB 方式 |
| **Font** | 一个 Font 单独打成一个 AB | UI 引用字体 |
| **Mesh** | 跟随 Prefab，作为子资源 | 网格数据 |
| **Prefab** | 一个 Prefab 一个 AB 包 | 最常见的打包单元 |
| **Scene** | 一个场景一个 AB 包 | 场景加载 |
| **Shader** | 所有 Shader 打成一个 AB | 初始化时加载预热 |
| **Texture** | 跟随 Prefab 或单独打包 | 图片资源 |
| **SpriteAtlas** | 一个图集一个 AB 包 | UI 图集打包 |
| **Material** | 一个 Material 一个 AB | 包含 Shader 与 Texture |
| **FBX** | 生成 Prefab 后打包 | 包含骨骼、蒙皮、图片等 |
| **txt/json** | 单独下载，不打进 AB | 文本配置文件 |
| **zip** | 单独下载 | 压缩文件 |

### 2.2 依赖关系查找

#### 正向依赖查找（查找此对象依赖的资源）

```csharp
using UnityEditor;

// 查找指定资源的所有依赖
string[] dependencies = AssetDatabase.GetDependencies("Assets/Prefabs/Player.prefab");
foreach (var dep in dependencies)
{
    Debug.Log($"依赖: {dep}");
}
```

#### 反向依赖查找（查找哪些资源依赖了此对象）

```csharp
using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public static class ReverseDependencyFinder
{
    private static readonly string[] SearchObjects =
    {
        ".prefab", ".unity", ".mat", ".asset",
        ".controller", ".anim", ".ttf",
        ".shadervariants", ".shader",
        ".spriteatlas", ".spriteatlasv2",
    };

    public static void FindReverseDependencies()
    {
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        string guid = AssetDatabase.AssetPathToGUID(path);

        string[] files = Directory.GetFiles(Application.dataPath, "*.*", SearchOption.AllDirectories)
            .Where(s => SearchObjects.Contains(Path.GetExtension(s).ToLower())).ToArray();

        int length = files.Length;
        for (int i = 0; i < length; i++)
        {
            string filePath = files[i];
            bool isCancel = EditorUtility.DisplayCancelableProgressBar(
                "匹配资源中", filePath, (float)i / length);

            if (Regex.IsMatch(File.ReadAllText(filePath), guid))
            {
                Debug.Log($"{filePath} 引用到 {path}");
            }

            if (isCancel) break;
        }

        EditorUtility.ClearProgressBar();
    }
}
```

> 💡 **重要提示**：资源之间的依赖关系 ≠ AB 包之间的依赖关系。需要打出 AB 包后，根据 `AssetBundleManifest` 来判断 AB 包之间的关系。

---

## 三、打包策略

### 3.1 推荐打包规则

在 `Assets` 文件夹下创建 `BuildAssets` 文件夹，按照以下规则进行打包：

```
Assets/
├── BuildAssets/          # 待打包资源（按后缀分类）
│   ├── Animates/         # .anim, .controller
│   ├── Configs/          # .asset
│   ├── Fonts/            # .ttf, .asset
│   ├── Materials/        # .mat
│   ├── Prefabs/          # .prefab
│   ├── Scenes/           # .unity
│   ├── Shaders/          # .shader, .shadervariants
│   ├── SpriteAtlas/      # .spriteatlas, .spriteatlasv2
│   └── Textures/         # .png, .jpg, .jpeg, .hdr
└── 其他资源/              # 被 BuildAssets 依赖的资源
```

### 3.2 文件类型映射

```csharp
public static readonly Dictionary<string, string[]> AllFileExtension =
    new Dictionary<string, string[]>()
{
    { "Animates",     new[] { ".anim", ".controller" } },
    { "Binarys",      new[] { ".zip" } },
    { "Configs",      new[] { ".asset" } },
    { "Fonts",        new[] { ".ttf", ".asset" } },
    { "Materials",    new[] { ".mat" } },
    { "Prefabs",      new[] { ".prefab" } },
    { "Scenes",       new[] { ".unity" } },
    { "Shaders",      new[] { ".shader", ".shadervariants" } },
    { "SpriteAtlas",  new[] { ".spriteatlas", ".spriteatlasv2" } },
    { "Textures",     new[] { ".png", ".jpg", ".jpeg", ".hdr" } },
};
```

### 3.3 核心打包原则

| 原则 | 说明 |
|-----|------|
| **最小颗粒度** | 每个资源一个 AB 包，不按文件夹打包 |
| **依赖单向** | BuildAssets 内资源依赖外部资源，而非互相依赖 |
| **重复检查** | 被依赖超过 5 次且大小超过 100KB 的资源应独立打包 |
| **依赖检查** | 每次打包后检查 AB 包依赖关系，避免循环依赖 |

### 3.4 打包代码

```csharp
using UnityEditor;
using UnityEngine;

public static class AssetBundleBuilder
{
    [MenuItem("Tools/Build AssetBundles")]
    public static void BuildAssetBundles()
    {
        // 收集资源并构建 AssetBundleBuild 数组
        AssetBundleBuild[] builds = CollectAssetBundles();

        // 打包路径
        string outputPath = "AssetBundles/[Platform]";

        // 打包
        var assetBundleManifest = BuildPipeline.BuildAssetBundles(
            outputPath,
            builds,
            BuildAssetBundleOptions.ChunkBasedCompression, // LZ4 压缩
            EditorUserBuildSettings.activeBuildTarget
        );

        // 检查依赖关系
        CheckDependencies(assetBundleManifest);

        // 生成版本文件
        GenerateVersionFile();
    }

    private static AssetBundleBuild[] CollectAssetBundles()
    {
        // 根据 AllFileExtension 收集资源
        // 实现...
        return null;
    }

    private static void CheckDependencies(AssetBundleManifest manifest)
    {
        // 检查是否存在循环依赖
        // 检查是否存在互相依赖的包体
        // 实现...
    }

    private static void GenerateVersionFile()
    {
        // 生成 version.json 用于版本对比
        // 实现...
    }
}
```

---

## 四、热更新流程

### 4.1 版本对比流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         热更新流程                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│  │ 游戏启动 │───>│请求版本 │───>│版本对比 │───>│下载差异 │            │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘            │
│                      │              │              │                    │
│                      v              v              v                    │
│                 ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│                 │version.json│   │ MD5校验 │    │ 覆盖/下载│           │
│                 │服务器版本 │   │ 完整性  │    │ AB包    │           │
│                 └─────────┘    └─────────┘    └─────────┘            │
│                                                                         │
│  可选：边玩边下载（需用户同意，开启新线程下载）                            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 热更新代码示例

```csharp
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetBundleUpdater : MonoBehaviour
{
    private string versionUrl = "https://cdn.example.com/version.json";
    private string assetBundleUrl = "https://cdn.example.com/assetbundles/";

    private string localVersionPath;
    private string localAssetBundlePath;

    private void Start()
    {
        localVersionPath = Path.Combine(Application.persistentDataPath, "version.json");
        localAssetBundlePath = Path.Combine(Application.persistentDataPath, "AssetBundles");

        StartCoroutine(UpdateAssetBundles());
    }

    private IEnumerator UpdateAssetBundles()
    {
        // 1. 请求服务器版本文件
        yield StartCoroutine(DownloadVersionFile());

        // 2. 对比本地与服务器版本
        List<string> filesToDownload = CompareVersions();

        // 3. 下载差异文件
        foreach (string file in filesToDownload)
        {
            yield StartCoroutine(DownloadAssetBundle(file));
        }

        // 4. MD5 校验
        foreach (string file in filesToDownload)
        {
            if (!VerifyMD5(file))
            {
                // 重新下载
                yield StartCoroutine(DownloadAssetBundle(file));
            }
        }

        Debug.Log("AssetBundle 更新完成");
    }

    private IEnumerator DownloadVersionFile() { /* 实现 */ }
    private List<string> CompareVersions() { /* 实现 */ }
    private IEnumerator DownloadAssetBundle(string file) { /* 实现 */ }
    private bool VerifyMD5(string file) { /* 实现 */ }
}
```

### 4.3 Lua 文件热更新

| 方案 | 适用场景 | 说明 |
|-----|---------|------|
| **整体打包** | Lua 文件不多 | 将所有 Lua 打成 zip，整体更新 |
| **增量更新** | 重度依赖 Lua | 与 AB 包更新逻辑一致 |
| **AB 包方式** | 需要版本管理 | 将热更 Lua 文件打包成 AB |

---

## 五、AssetBundle 加载流程

### 5.1 内存层次结构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AB 加载内存层次结构                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    │
│  │    磁盘文件     │───>│   镜像内存      │───>│  实例化对象     │    │
│  │  (压缩AB包)     │    │  (AB对象)       │    │  (Hierarchy)    │    │
│  ├─────────────────┤    ├─────────────────┤    ├─────────────────┤    │
│  │ • LZ4 压缩      │    │ • 压缩数据镜像  │    │ • GameObject    │    │
│  │ • 持久存储      │    │ • 可异步加载    │    │ • Component    │    │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘    │
│         │                       │                       │            │
│         │ LoadFromFile          │ LoadAsset              │ Instantiate │
│         └───────────────────────┴───────────────────────┘            │
│                                                                         │
│  可能存在两份或三份内存：                                                 │
│  • 磁盘 → 镜像内存（必定）                                               │
│  • 镜像内存 → 解压资源（必定）                                           │
│  • 解压资源 → 实例化对象（Prefab 需要）                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 5.2 加载 AB 包

```csharp
using UnityEngine;
using System.Collections;

public class AssetBundleLoader : MonoBehaviour
{
    private string assetBundlePath = "AssetBundles/prefab";

    // 同步加载
    private AssetBundle LoadFromFile()
    {
        return AssetBundle.LoadFromFile(assetBundlePath);
    }

    // 异步加载
    private IEnumerator LoadFromFileAsync()
    {
        AssetBundleCreateRequest request = AssetBundle.LoadFromFileAsync(assetBundlePath);
        yield return request;

        AssetBundle assetBundle = request.assetBundle;
        // 使用 assetBundle 加载资源...
    }
}
```

> ⚠️ **重要规范**：AB 加载方案应从磁盘加载，**严禁从网络直接加载**。

### 5.3 加载 AB 包内的资源

```csharp
using UnityEngine;

public class AssetBundleAssetLoader
{
    private AssetBundle assetBundle;

    // 加载单个资源
    public T LoadAsset<T>(string name) where T : Object
    {
        return assetBundle.LoadAsset<T>(name);
    }

    // 异步加载
    public AssetBundleRequest LoadAssetAsync<T>(string name) where T : Object
    {
        return assetBundle.LoadAssetAsync<T>(name);
    }

    // 加载所有资源
    public Object[] LoadAllAssets()
    {
        return assetBundle.LoadAllAssets();
    }

    // 加载带子资源的资源（如 SpriteAtlas）
    public T LoadAssetWithSubAssets<T>(string name) where T : Object
    {
        return assetBundle.LoadAssetWithSubAssets<T>(name);
    }
}
```

---

## 六、内存管理

### 6.1 卸载 API 详解

| API | 作用范围 | 说明 |
|-----|---------|------|
| `AssetBundle.Unload(false)` | 仅卸载镜像内存 | 保留已加载的资源 |
| `AssetBundle.Unload(true)` | 卸载镜像+解压内存 | 同时卸载已加载的资源 |
| `Resources.UnloadAsset()` | 卸载单个解压资源 | 卸载指定的资源对象 |
| `Resources.UnloadUnusedAssets()` | 卸载未使用的解压资源 | 卸载所有未引用的资源 |
| `AssetBundle.UnloadAllAssetBundles(false)` | 卸载所有镜像内存 | 保留已加载资源 |
| `AssetBundle.UnloadAllAssetBundles(true)` | 卸载所有镜像+解压内存 | 完全清理 |

### 6.2 内存管理流程

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       内存管理生命周期                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  加载阶段                       卸载阶段                                 │
│  ┌─────────┐                  ┌─────────────────────────────────┐      │
│  │ 磁盘文件 │                  │  1. Destroy(gameObject)        │      │
│  │   ↓     │                  │     清理 Hierarchy 中的实例    │      │
│  │ 镜像内存 │                  └──────────────┬──────────────────┘      │
│  │   ↓     │                                 │                        │
│  │ 解压资源 │                  ┌──────────────▼──────────────────┐      │
│  │   ↓     │                  │  2. Resources.UnloadAsset()     │      │
│  │ 实例化   │                  │     清理单个解压资源           │      │
│  └─────────┘                  └──────────────┬──────────────────┘      │
│                                             │                        │
│                                ┌────────────▼──────────────────┐      │
│                                │  3. AssetBundle.Unload(true)  │      │
│                                │     清理镜像+解压内存         │      │
│                                └───────────────────────────────┘      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 6.3 内存管理最佳实践

```csharp
using UnityEngine;

public class AssetBundleManager : MonoBehaviour
{
    private Dictionary<string, AssetBundle> loadedBundles = new Dictionary<string, AssetBundle>();
    private Dictionary<string, Object> loadedAssets = new Dictionary<string, Object>();

    // 加载 AB 和资源
    public T LoadAssetWithBundle<T>(string bundlePath, string assetName) where T : Object
    {
        // 1. 检查缓存
        if (loadedAssets.TryGetValue(assetName, out Object cached))
        {
            return cached as T;
        }

        // 2. 加载 AB 包
        if (!loadedBundles.TryGetValue(bundlePath, out AssetBundle bundle))
        {
            bundle = AssetBundle.LoadFromFile(bundlePath);
            loadedBundles[bundlePath] = bundle;
        }

        // 3. 加载资源
        T asset = bundle.LoadAsset<T>(assetName);
        loadedAssets[assetName] = asset;

        return asset;
    }

    // 卸载单个资源
    public void UnloadAsset(string assetName)
    {
        if (loadedAssets.TryGetValue(assetName, out Object asset))
        {
            Resources.UnloadAsset(asset);
            loadedAssets.Remove(assetName);
        }
    }

    // 卸载 AB 包
    public void UnloadBundle(string bundlePath, bool unloadAllLoadedObjects)
    {
        if (loadedBundles.TryGetValue(bundlePath, out AssetBundle bundle))
        {
            bundle.Unload(unloadAllLoadedObjects);
            loadedBundles.Remove(bundlePath);
        }
    }

    // 清理所有未使用的资源
    public void UnloadUnusedAssets()
    {
        Resources.UnloadUnusedAssets();
        System.GC.Collect();
    }

    private void OnDestroy()
    {
        // 清理所有 AB 包
        foreach (var kvp in loadedBundles)
        {
            kvp.Value.Unload(true);
        }
        loadedBundles.Clear();
        loadedAssets.Clear();
    }
}
```

---

## 七、Prefab 实例化

### 7.1 Prefab 特性

| 特性 | 说明 |
|-----|------|
| **文件类型** | Prefab 本质是文本文件，包含引用关系 |
| **类比** | Prefab 像类模板，实例化是创建对象 |
| **内存拷贝** | 实例化时会复制一份资源到 Hierarchy |

### 7.2 引用与复制

```csharp
using UnityEngine;

public class PrefabInstantiator : MonoBehaviour
{
    private GameObject prefabTemplate;

    void Start()
    {
        // 从 AB 加载 Prefab
        AssetBundle bundle = AssetBundle.LoadFromFile("path/to/bundle");
        prefabTemplate = bundle.LoadAsset<GameObject>("PrefabName");

        // 实例化
        GameObject instance = Instantiate(prefabTemplate);

        // 材质和网格的处理
        Renderer renderer = instance.GetComponent<Renderer>();

        // 引用（共享）
        Mesh sharedMesh = renderer.GetComponent<MeshFilter>().sharedMesh;
        Material sharedMaterial = renderer.sharedMaterial;

        // 复制（独立）
        Mesh mesh = renderer.GetComponent<MeshFilter>().mesh;
        Material material = renderer.material;
    }

    void OnDestroy()
    {
        // 销毁实例
        if (prefabTemplate != null)
        {
            Destroy(prefabTemplate);
        }
    }
}
```

### 7.3 内存存在形式

| 资源类型 | 内存份数 | 说明 |
|---------|---------|------|
| **Prefab + 实例化** | 三份 | 磁盘压缩 → 镜像内存 → 实例化对象 |
| **Shader/Texture** | 两份 | 磁盘压缩 → 解压资源（实例化时引用） |
| **Mesh/Material** | 两份或三份 | 取决于使用 sharedMesh/Mesh 还是 sharedMaterial/Material |

---

## 八、工具推荐

| 工具 | 用途 | 链接 |
|-----|------|------|
| **AssetStudio** | AB 包查看和分析 | https://github.com/Perfare/AssetStudio |
| **AssetBundles-Browser** | Unity 官方推荐工具 | Unity Package Manager |

---

## 九、总结

| 阶段 | 核心要点 |
|-----|---------|
| **概念** | AB 包含序列化文件和资源文件，支持依赖关系 |
| **依赖** | 正向依赖使用 `AssetDatabase.GetDependencies()` |
| **打包** | 按后缀分类，最小颗粒度，避免循环依赖 |
| **热更新** | 版本对比 → 下载差异 → MD5 校验 |
| **加载** | 从磁盘加载，严禁网络加载 |
| **内存** | 三层内存：磁盘 → 镜像 → 解压/实例化 |
| **卸载** | 先 Destroy 实例，再 UnloadAsset，最后 Unload AB |

> 💡 **最佳实践**：
> - 建立统一的 AB 管理器，统一加载和卸载
> - 定期检查 AB 包依赖关系，避免循环依赖
> - 使用对象池减少频繁的加载卸载
> - 大场景采用场景流加载策略
> - 关键资源随包，非关键资源热更新

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

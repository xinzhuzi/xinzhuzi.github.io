---
title: "Unity EditorWindow 完全指南：从零打造专业编辑器窗口"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UnityEditor, EditorWindow, 编辑器扩展, 窗口开发, 工具开发]
image: /images/unity-editor-window-banner.jpg
---

# 🪟 Unity EditorWindow 完全指南：从零打造专业编辑器窗口

> 💡 **窗口工具的价值**：
> - 想开发自己的编辑器工具，却不知道从何入手？
> - 窗口应该设计成独立的、停靠的、还是弹出的？
> - 如何实现类似 Unity 官方窗口的专业效果？
> - 窗口状态如何保存和恢复？
>
> **这篇文章！** 将带你从零开始，系统掌握 EditorWindow 的开发技巧，打造专业级编辑器窗口！

## 一、EditorWindow 概述

Unity 编辑器中的所有窗口都是 `EditorWindow` 的子类：

| 窗口 | 说明 |
|------|------|
| **Scene** | 场景窗口 |
| **Game** | 游戏窗口 |
| **Inspector** | 检视面板 |
| **Hierarchy** | 层级面板 |
| **Project** | 项目窗口 |
| **Console** | 控制台 |

> 💡 Unity 编辑器本质上是由各种功能化的 EditorWindow 组成的集合。

---

## 二、创建基础窗口

### 2.1 使用 GetWindow（推荐）

`GetWindow` 是最常用的创建方式，会自动缓存窗口实例。

```csharp
using UnityEngine;
using UnityEditor;

public class ExampleWindow : EditorWindow
{
    [MenuItem("Tools/Example Window")]
    static void ShowWindow()
    {
        // 获取或创建窗口，自动缓存
        var window = GetWindow<ExampleWindow>("示例窗口");
        window.minSize = new Vector2(300, 200);
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("Hello, EditorWindow!", EditorStyles.boldLabel);
    }
}
```

### 2.2 使用 CreateInstance

手动创建实例，需要自己管理缓存。

```csharp
public class ExampleWindow : EditorWindow
{
    private static ExampleWindow instance;

    [MenuItem("Tools/Example Window")]
    static void ShowWindow()
    {
        if (instance == null)
        {
            instance = CreateInstance<ExampleWindow>();
        }
        instance.Show();
    }
}
```

---

## 三、窗口显示模式

EditorWindow 提供了多种显示模式：

| 方法 | 特点 | 使用场景 |
|------|------|---------|
| `Show()` | 标准窗口，可停靠 | 常规工具窗口 |
| `ShowUtility()` | 浮动窗口，总是在前 | 独立工具面板 |
| `ShowPopup()` | 无关闭按钮，ESC关闭 | 临时弹出窗口 |
| `ShowAsDropDown()` | 点击外部关闭 | 下拉菜单 |

### 3.1 Show 标准窗口

```csharp
[MenuItem("Tools/Standard Window")]
static void ShowStandard()
{
    var window = GetWindow<ExampleWindow>();
    window.Show();  // 可停靠到编辑器
}
```

### 3.2 ShowUtility 工具窗口

工具窗口始终在标准窗口前方，切换应用时自动隐藏。

```csharp
public class UtilityWindowExample : EditorWindow
{
    private static UtilityWindowExample instance;

    [MenuItem("Tools/Utility Window")]
    static void ShowUtility()
    {
        if (instance == null)
        {
            instance = CreateInstance<UtilityWindowExample>();
        }
        instance.ShowUtility();
        instance.titleContent = new GUIContent("工具窗口");
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("这是一个工具窗口", EditorStyles.boldLabel);
        EditorGUILayout.LabelField("始终在其他窗口前方");
    }
}
```

### 3.3 ShowPopup 弹出窗口

没有关闭按钮，按 ESC 键关闭。

```csharp
public class PopupWindowExample : EditorWindow
{
    [MenuItem("Tools/Popup Window")]
    static void ShowPopup()
    {
        var window = CreateInstance<PopupWindowExample>();
        window.position = new Rect(100, 100, 300, 150);
        window.ShowPopup();
        window.titleContent = new GUIContent("弹出窗口");
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("按 ESC 键关闭此窗口", EditorStyles.centeredGreyMiniLabel);

        if (Event.current.type == EventType.KeyDown &&
            Event.current.keyCode == KeyCode.Escape)
        {
            Close();
        }
    }
}
```

### 3.4 ShowAsDropDown 下拉窗口

点击窗口外部区域会自动关闭。

```csharp
public class DropDownWindowExample : EditorWindow
{
    [MenuItem("Tools/Drop Down Window")]
    static void ShowDropDown()
    {
        // 从指定按钮位置弹出
        var buttonRect = new Rect(100, 100, 150, 30);
        var windowSize = new Vector2(200, 150);

        var window = CreateInstance<DropDownWindowExample>();
        window.ShowAsDropDown(buttonRect, windowSize);
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("点击外部区域关闭");
        if (GUILayout.Button("选项1"))
            Debug.Log("选择了选项1");
        if (GUILayout.Button("选项2"))
            Debug.Log("选择了选项2");
    }
}
```

---

## 四、PopupWindowContent 弹出内容

在编辑器中嵌入小型弹出窗口。

```csharp
using UnityEngine;
using UnityEditor;

public class PopupWindowHost : EditorWindow
{
    private ExamplePopupContent popupContent = new ExamplePopupContent();

    [MenuItem("Tools/Popup Content Demo")]
    static void ShowWindow()
    {
        GetWindow<PopupWindowHost>("弹出内容示例");
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("点击按钮显示弹出内容", EditorStyles.boldLabel);

        if (GUILayout.Button("显示选项", GUILayout.Width(150)))
        {
            // 获取按钮矩形区域
            Rect buttonRect = GUILayoutUtility.GetLastRect();
            // 在按钮下方显示弹出窗口
            PopupWindow.Show(buttonRect, popupContent);
        }
    }
}

// 弹出窗口内容类
public class ExamplePopupContent : PopupWindowContent
{
    private string selectedOption = "选项1";
    private bool enableFeature = true;

    public override Vector2 GetWindowSize()
    {
        return new Vector2(200, 120);
    }

    public override void OnGUI(Rect rect)
    {
        EditorGUILayout.LabelField("弹出选项", EditorStyles.boldLabel);

        selectedOption = EditorGUILayout.Popup("选择", GetSelectedIndex(), new[] { "选项1", "选项2", "选项3" });
        enableFeature = EditorGUILayout.Toggle("启用功能", enableFeature);

        if (GUILayout.Button("确定"))
        {
            // 关闭弹出窗口
            this.editorWindow.Close();
        }
    }

    private int GetSelectedIndex()
    {
        switch (selectedOption)
        {
            case "选项1": return 0;
            case "选项2": return 1;
            case "选项3": return 2;
            default: return 0;
        }
    }

    public override void OnOpen()
    {
        Debug.Log("弹出窗口已打开");
    }

    public override void OnClose()
    {
        Debug.Log($"弹出窗口已关闭，选择: {selectedOption}");
    }
}
```

---

## 五、ScriptableWizard 向导窗口

快速创建带确认/取消按钮的向导式窗口。

```csharp
using UnityEngine;
using UnityEditor;

public class GameObjectWizard : ScriptableWizard
{
    [SerializeField]
    private string objectName = "NewGameObject";

    [SerializeField]
    private PrimitiveType objectType = PrimitiveType.Cube;

    [MenuItem("Tools/Create GameObject Wizard")]
    static void CreateWizard()
    {
        // 显示向导窗口
        DisplayWizard<GameObjectWizard>("创建物体向导", "创建", "应用选中");
    }

    private void OnWizardCreate()
    {
        // 点击"创建"按钮时调用
        GameObject obj = GameObject.CreatePrimitive(objectType);
        obj.name = objectName;

        // 放置在场景视图中心
        obj.transform.position = SceneView.lastActiveSceneView.camera.transform.position +
                                SceneView.lastActiveSceneView.camera.transform.forward * 5f;

        Debug.Log($"已创建: {obj.name}");
    }

    private void OnWizardOtherButton()
    {
        // 点击其他按钮时调用（这里是"应用选中"按钮）
        if (Selection.activeGameObject != null)
        {
            Selection.activeGameObject.name = objectName;
            Debug.Log($"已重命名选中物体: {objectName}");
        }
        else
        {
            Debug.LogWarning("请先选中一个 GameObject");
        }
    }

    private void OnWizardUpdate()
    {
        // 窗口内容变化时调用，可用于验证输入
        isValid = !string.IsNullOrEmpty(objectName);

        if (string.IsNullOrEmpty(objectName))
        {
            errorString = "请输入物体名称";
        }
        else
        {
            errorString = "";
        }
    }

    // 自定义向导 GUI
    protected override bool DrawWizardGUI()
    {
        EditorGUILayout.LabelField("创建配置", EditorStyles.boldLabel);

        // 绘制自定义内容
        objectName = EditorGUILayout.TextField("物体名称", objectName);
        objectType = (PrimitiveType)EditorGUILayout.EnumPopup("物体类型", objectType);

        // 绘制默认按钮（返回 false 表示不绘制默认按钮）
        return true;
    }
}
```

### ScriptableWizard 关键方法

| 方法 | 调用时机 |
|------|---------|
| `OnWizardCreate()` | 点击"创建"按钮时 |
| `OnWizardOtherButton()` | 点击其他按钮时 |
| `OnWizardUpdate()` | 窗口内容变化时 |
| `DrawWizardGUI()` | 绘制自定义 GUI |

---

## 六、PreferenceItem 首选项设置

在 Unity 编辑器的 Preferences（首选项）中添加自定义选项。

```csharp
using UnityEngine;
using UnityEditor;

public class PreferenceSettingsExample
{
    private const string AUTO_SAVE_KEY = "Example_AutoSave";
    private const string BACKUP_PATH_KEY = "Example_BackupPath";

    [PreferenceItem("示例/自动设置")]
    static void PreferenceGUI()
    {
        EditorGUILayout.LabelField("自动保存设置", EditorStyles.boldLabel);

        // 读取和保存偏好设置
        bool autoSave = EditorPrefs.GetBool(AUTO_SAVE_KEY, true);
        autoSave = EditorGUILayout.Toggle("自动保存", autoSave);
        EditorPrefs.SetBool(AUTO_SAVE_KEY, autoSave);

        string backupPath = EditorPrefs.GetString(BACKUP_PATH_KEY, "Assets/Backups/");
        backupPath = EditorGUILayout.TextField("备份路径", backupPath);
        EditorPrefs.SetString(BACKUP_PATH_KEY, backupPath);

        if (GUILayout.Button("恢复默认设置"))
        {
            EditorPrefs.DeleteKey(AUTO_SAVE_KEY);
            EditorPrefs.DeleteKey(BACKUP_PATH_KEY);
        }
    }
}
```

> 使用路径：Unity 编辑器 → Edit → Preferences → 示例 → 自动设置

---

## 七、IHasCustomMenu 自定义菜单

为 EditorWindow 添加自定义窗口菜单。

```csharp
using UnityEngine;
using UnityEditor;

public class CustomMenuWindow : EditorWindow, IHasCustomMenu
{
    private int zoomLevel = 100;
    private bool showGrid = true;

    [MenuItem("Tools/Custom Menu Window")]
    static void ShowWindow()
    {
        var window = GetWindow<CustomMenuWindow>();
        window.titleContent = new GUIContent("自定义菜单窗口");
    }

    // 实现 IHasCustomMenu 接口
    public void AddItemsToMenu(GenericMenu menu)
    {
        // 添加菜单项
        menu.AddItem(new GUIContent("放大"), false, () => zoomLevel = 150);
        menu.AddItem(new GUIContent("缩小"), false, () => zoomLevel = 75);
        menu.AddItem(new GUIContent("重置缩放"), true, () => zoomLevel = 100);

        // 添加分隔线
        menu.AddSeparator("");

        // 添加勾选项
        menu.AddItem(new GUIContent("显示网格"), showGrid, () => showGrid = !showGrid);

        // 添加子菜单
        menu.AddItem(new GUIContent("缩放/50%"), false, () => zoomLevel = 50);
        menu.AddItem(new GUIContent("缩放/100%"), false, () => zoomLevel = 100);
        menu.AddItem(new GUIContent("缩放/200%"), false, () => zoomLevel = 200);
    }

    private void OnGUI()
    {
        // 顶部菜单区域
        Rect menuRect = new Rect(0, 0, position.width, 20);
        if (Event.current.type == EventType.ContextClick && menuRect.Contains(Event.current.mousePosition))
        {
            // 右键显示自定义菜单
            GenericMenu menu = new GenericMenu();
            AddItemsToMenu(menu);
            menu.DropDown(new Rect(Event.current.mousePosition.x, Event.current.mousePosition.y, 0, 0));
        }

        // 内容区域
        EditorGUILayout.LabelField($"缩放: {zoomLevel}%", EditorStyles.largeLabel);
        EditorGUILayout.LabelField($"网格: {(showGrid ? "显示" : "隐藏")}");
    }
}
```

---

## 八、窗口图标和标题

### 8.1 设置标题和图标

```csharp
using UnityEngine;
using UnityEditor;

public class StyledWindow : EditorWindow
{
    [MenuItem("Tools/Styled Window")]
    static void ShowWindow()
    {
        var window = GetWindow<StyledWindow>();

        // 加载自定义图标
        Texture icon = AssetDatabase.LoadAssetAtPath<Texture>(
            "Assets/Editor/WindowIcon.png"
        );

        // 设置标题和图标
        window.titleContent = new GUIContent("自定义标题", icon);
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("带有自定义图标的窗口");
    }
}
```

### 8.2 使用内置图标

```csharp
// 使用 Unity 内置图标
window.titleContent = new GUIContent("窗口名",
    EditorGUIUtility.IconContent("d_Tab Inspect").image  // "d_" 前缀表示暗色主题图标
);
```

---

## 九、窗口数据持久化

将 EditorWindow 中的数据保存为 ScriptableObject。

```csharp
using UnityEngine;
using UnityEditor;

public class WindowWithPersistence : EditorWindow
{
    private const string ASSET_PATH = "Assets/Editor/WindowData.asset";

    [SerializeField]
    private string savedText = "默认文本";

    [SerializeField]
    private int savedValue = 10;

    [MenuItem("Tools/Window with Persistence")]
    static void ShowWindow()
    {
        GetWindow<WindowWithPersistence>("数据持久化窗口");
    }

    private void OnEnable()
    {
        // 窗口打开时加载保存的数据
        var data = AssetDatabase.LoadAssetAtPath<WindowWithPersistence>(ASSET_PATH);
        if (data != null)
        {
            savedText = data.savedText;
            savedValue = data.savedValue;
        }
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("窗口数据（可保存）", EditorStyles.boldLabel);

        savedText = EditorGUILayout.TextField("文本", savedText);
        savedValue = EditorGUILayout.IntSlider("数值", savedValue, 0, 100);

        EditorGUILayout.Space(10);

        using (new EditorGUILayout.HorizontalScope())
        {
            if (GUILayout.Button("保存到资产"))
            {
                SaveToAsset();
            }

            if (GUILayout.Button("加载资产"))
            {
                LoadFromAsset();
            }
        }
    }

    private void SaveToAsset()
    {
        // 创建资产并保存当前数据
        var data = CreateInstance<WindowWithPersistence>();
        data.savedText = this.savedText;
        data.savedValue = this.savedValue;

        AssetDatabase.CreateAsset(data, ASSET_PATH);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log($"数据已保存到: {ASSET_PATH}");
    }

    private void LoadFromAsset()
    {
        var data = AssetDatabase.LoadAssetAtPath<WindowWithPersistence>(ASSET_PATH);
        if (data != null)
        {
            this.savedText = data.savedText;
            this.savedValue = data.savedValue;
            Repaint();
            Debug.Log("数据已从资产加载");
        }
        else
        {
            Debug.LogWarning("未找到保存的资产文件");
        }
    }
}
```

---

## 十、窗口生命周期

```csharp
public class WindowLifecycle : EditorWindow
{
    [MenuItem("Tools/Window Lifecycle")]
    static void ShowWindow()
    {
        GetWindow<WindowLifecycle>("生命周期示例");
    }

    // 构造函数
    public WindowLifecycle()
    {
        Debug.Log("构造函数 - Window 创建");
    }

    // 窗口获得焦点时
    private void OnFocus()
    {
        Debug.Log("OnFocus - 窗口获得焦点");
    }

    // 窗口失去焦点时
    private void OnLostFocus()
    {
        Debug.Log("OnLostFocus - 窗口失去焦点");
    }

    // 窗口启用时（包括首次打开和从不可见变为可见）
    private void OnEnable()
    {
        Debug.Log("OnEnable - 窗口启用");
    }

    // 窗口禁用时（关闭或隐藏）
    private void OnDisable()
    {
        Debug.Log("OnDisable - 窗口禁用");
    }

    // 窗口销毁时
    private void OnDestroy()
    {
        Debug.Log("OnDestroy - 窗口销毁");
    }

    // 层次变更时（窗口在停靠区的位置变化）
    private void OnHierarchyChange()
    {
        Debug.Log("OnHierarchyChange - 层次结构变更");
    }

    // 项目变更时（Project 窗口内容变化）
    private void OnProjectChange()
    {
        Debug.Log("OnProjectChange - 项目内容变更");
    }

    // 检查器选择变更时
    private void OnSelectionChange()
    {
        Debug.Log($"OnSelectionChange - 当前选中: {Selection.activeObjectName}");
    }

    // 更新窗口内容（连续调用）
    private void Update()
    {
        // 可用于定时刷新
    }

    // 绘制 GUI
    private void OnGUI()
    {
        EditorGUILayout.LabelField("查看 Console 了解生命周期");
        EditorGUILayout.LabelField($"选中: {Selection.activeObjectName ?? "无"}");
    }
}
```

### 生命周期调用顺序

```
创建窗口时:
    构造函数 → OnEnable → OnGUI

关闭窗口时:
    OnDisable → OnDestroy

获得焦点时:
    OnFocus

失去焦点时:
    OnLostFocus
```

---

## 十一、完整示例：多标签编辑器窗口

```csharp
using UnityEngine;
using UnityEditor;

public class MultiTabWindow : EditorWindow
{
    private int selectedTab = 0;
    private string[] tabNames = { "设置", "预览", "关于" };

    // 设置标签页数据
    private string configName = "MyConfig";
    private int configValue = 50;

    // 预览标签页数据
    private Color previewColor = Color.blue;
    private float previewSize = 1f;

    [MenuItem("Tools/Multi Tab Window")]
    static void ShowWindow()
    {
        var window = GetWindow<MultiTabWindow>();
        window.titleContent = new GUIContent("多标签窗口");
        window.minSize = new Vector2(400, 300);
    }

    private void OnGUI()
    {
        // 绘制工具栏
        selectedTab = GUILayout.Toolbar(selectedTab, tabNames);

        EditorGUILayout.Space(10);

        // 根据选中标签页绘制内容
        switch (selectedTab)
        {
            case 0:
                DrawSettingsTab();
                break;
            case 1:
                DrawPreviewTab();
                break;
            case 2:
                DrawAboutTab();
                break;
        }
    }

    private void DrawSettingsTab()
    {
        EditorGUILayout.LabelField("配置设置", EditorStyles.boldLabel);

        configName = EditorGUILayout.TextField("配置名称", configName);
        configValue = EditorGUILayout.IntSlider("配置值", configValue, 0, 100);

        EditorGUILayout.Space(10);

        if (GUILayout.Button("保存配置", GUILayout.Height(30)))
        {
            Debug.Log($"保存配置: {configName} = {configValue}");
        }
    }

    private void DrawPreviewTab()
    {
        EditorGUILayout.LabelField("预览", EditorStyles.boldLabel);

        previewColor = EditorGUILayout.ColorField("颜色", previewColor);
        previewSize = EditorGUILayout.Slider("大小", previewSize, 0.5f, 2f);

        EditorGUILayout.Space(10);

        // 绘制预览区域
        Rect previewRect = EditorGUILayout.GetControlRect(false, 150);
        EditorGUI.DrawRect(previewRect, new Color(0.2f, 0.2f, 0.2f));

        Vector2 center = previewRect.center;
        float size = 50 * previewSize;
        Rect colorRect = new Rect(center.x - size / 2, center.y - size / 2, size, size);
        EditorGUI.DrawRect(colorRect, previewColor);
    }

    private void DrawAboutTab()
    {
        EditorGUILayout.LabelField("关于", EditorStyles.boldLabel);

        EditorGUILayout.LabelField("多标签编辑器窗口示例");
        EditorGUILayout.LabelField("版本: 1.0.0");
        EditorGUILayout.LabelField("作者: Your Name");

        EditorGUILayout.Space(10);

        if (GUILayout.Button("访问文档"))
        {
            Application.OpenURL("https://docs.unity3d.com/ScriptReference.EditorWindow.html");
        }
    }
}
```

---

## 十二、EditorWindow 速查表

| 功能 | 方法/属性 | 说明 |
|------|-----------|------|
| **创建窗口** | `GetWindow<T>()` | 获取或创建窗口 |
| **显示模式** | `Show()`, `ShowUtility()` | 标准窗口/工具窗口 |
| **弹出窗口** | `ShowPopup()`, `ShowAsDropDown()` | 弹出窗口/下拉窗口 |
| **窗口标题** | `titleContent` | 窗口标题和图标 |
| **窗口大小** | `minSize`, `maxSize` | 最小/最大尺寸 |
| **重绘窗口** | `Repaint()` | 手动重绘 |
| **关闭窗口** | `Close()` | 关闭窗口 |
| **显示通知** | `ShowNotification()` | 顶部通知 |
| **聚焦窗口** | `Focus()` | 获取焦点 |

---

## 十三、总结

本文介绍了 Unity EditorWindow 的开发要点：

| 主题 | 要点 |
|------|------|
| **创建方式** | `GetWindow<T>()` 优先使用 |
| **显示模式** | Show、ShowUtility、ShowPopup、ShowAsDropDown |
| **向导窗口** | ScriptableWizard 快速创建 |
| **首选项** | PreferenceItem 添加到 Preferences |
| **自定义菜单** | IHasCustomMenu 接口 |
| **数据持久化** | ScriptableObject + AssetDatabase |
| **生命周期** | OnEnable、OnGUI、OnDisable、OnDestroy |

> 💡 **开发建议**：
> - 窗口数据使用 `[SerializeField]` 标记，支持序列化
> - 使用 `EditorPrefs` 保存用户偏好设置
> - 合理使用 `Repaint()` 控制重绘频率
> - 复杂窗口使用多标签页组织内容

下一篇将详细介绍 **MenuItem 的使用技巧**。

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

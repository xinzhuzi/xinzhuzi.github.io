---
title: "Unity EditorWindow 实战案例：从零构建 Bug 报告工具"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UnityEditor, EditorWindow, 编辑器扩展, 实战案例, 工具开发]
image: /images/unity-editor-bug-tool-banner.jpg
---

# 🛠️ Unity EditorWindow 实战案例：从零构建 Bug 报告工具

> 💡 **实战学习的价值**：
> - 学了很多理论，不知道如何综合运用？
> - 想看一个完整的编辑器工具是怎么开发的？
> - 从需求分析到代码实现，完整流程是怎样的？
> - 如何让工具既实用又美观？
>
> **这篇文章！** 将通过一个完整的 Bug 报告工具案例，带你实战开发编辑器工具，掌握综合运用技能！

## 一、案例概述

本案例将创建一个功能完整的 Bug 报告工具窗口，包含以下功能：

| 功能模块 | 说明 |
|---------|------|
| **Bug 信息录入** | Bug 名称、关联物体、详细描述 |
| **场景信息记录** | 自动记录当前场景名称、时间 |
| **保存功能** | 保存到本地 / 保存并截图 |
| **拖放支持** | 支持拖拽文件到路径输入框 |
| **UI 控件演示** | 滑动条、下拉框、工具栏等 |

---

## 二、BugReportWindow 窗口类

### 2.1 基本结构

```csharp
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;

public class BugReportWindow : EditorWindow
{
    // 窗口数据
    private string bugName = "";
    private GameObject bugGameObject;
    private string bugDescription = "";

    // 菜单项打开窗口
    [MenuItem("Tools/Bug Reporter")]
    static void ShowWindow()
    {
        // 获取或创建窗口
        var window = GetWindow<BugReportWindow>("Bug Reporter");
        window.Show();
    }

    private void OnGUI()
    {
        // GUI 绘制代码...
    }
}
```

### 2.2 窗口创建选项

| 方法 | 说明 |
|------|------|
| `GetWindow<T>()` | 获取或创建窗口（单例） |
| `GetWindow<T>(string title)` | 指定窗口标题 |
| `GetWindow<T>(string title, bool utility)` | utility=true 显示为浮动窗口 |
| `CreateInstance<T>()` | 创建独立窗口实例 |

---

## 三、EditorWindow 生命周期

EditorWindow 提供了丰富的生命周期回调函数。

### 3.1 生命周期方法

| 方法 | 调用时机 |
|------|---------|
| `OnEnable()` | 窗口创建或启用时 |
| `OnDisable()` | 窗口禁用时 |
| `OnFocus()` | 窗口获得焦点 |
| `OnLostFocus()` | 窗口失去焦点 |
| `OnGUI()` | 每帧绘制窗口内容 |
| `Update()` | 每帧更新（窗口开启时） |
| `OnInspectorUpdate()` | Inspector 更新时 |
| `OnHierarchyChange()` | Hierarchy 变化时 |
| `OnProjectChange()` | Project 变化时 |
| `OnSelectionChange()` | 选择对象变化时 |
| `OnDestroy()` | 窗口销毁时 |

### 3.2 生命周期示例

```csharp
public class BugReportWindow : EditorWindow
{
    private void OnEnable()
    {
        Debug.Log("窗口开启");
        // 初始化数据
    }

    private void OnDisable()
    {
        Debug.Log("窗口禁用");
    }

    private void OnFocus()
    {
        Debug.Log("窗口获得焦点");
    }

    private void OnLostFocus()
    {
        Debug.Log("窗口失去焦点");
    }

    private void OnHierarchyChange()
    {
        Debug.Log("Hierarchy 变化");
        // 可以响应场景变化
    }

    private void OnProjectChange()
    {
        Debug.Log("Project 变化");
    }

    private void OnSelectionChange()
    {
        // 响应选择变化
        foreach (Transform t in Selection.transforms)
        {
            Debug.Log($"选中: {t.name}");
        }
    }

    private void OnInspectorUpdate()
    {
        // 开启实时重绘
        Repaint();
    }

    private void OnDestroy()
    {
        Debug.Log("窗口销毁");
    }

    private void Update()
    {
        // 每帧调用（谨慎使用，影响性能）
    }
}
```

---

## 四、完整的 Bug 报告工具实现

### 4.1 完整代码

```csharp
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;

public class BugReportWindow : EditorWindow
{
    // === Bug 信息 ===
    private string bugName = "";
    private GameObject bugGameObject;
    private string bugDescription = "";

    // === UI 状态 ===
    private Vector2 scrollPosition;
    private int selectedSeverity = 0;
    private string[] severityOptions = { "低", "中", "高", "紧急" };
    private bool showAdvanced = false;
    private string savePath = "Assets/BugReports/";

    // === 附加选项 ===
    private float minRange = 0f;
    private float maxRange = 100f;
    private int selectedTab = 0;
    private string[] tabOptions = { "基本信息", "详细信息", "附件" };

    [MenuItem("Tools/Bug Reporter %_b")]  // 快捷键 Ctrl+B
    static void ShowWindow()
    {
        var window = GetWindow<BugReportWindow>("Bug Reporter");
        window.minSize = new Vector2(400, 500);  // 最小尺寸
        window.Show();
    }

    private void OnGUI()
    {
        DrawHeader();
        DrawBasicInfo();
        DrawAdvancedOptions();
        DrawButtons();
    }

    // === 绘制标题 ===
    private void DrawHeader()
    {
        EditorGUILayout.Space(10);

        // 标题样式
        var titleStyle = new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 24,
            alignment = TextAnchor.MiddleCenter,
            fontStyle = FontStyle.Bold
        };

        EditorGUILayout.LabelField("🐛 Bug 报告工具", titleStyle);

        EditorGUILayout.Space(10);
    }

    // === 绘制基本信息 ===
    private void DrawBasicInfo()
    {
        // Bug 名称
        bugName = EditorGUILayout.TextField(new GUIContent("Bug 名称", "简短描述问题"), bugName);

        // 严重程度
        selectedSeverity = EditorGUILayout.Popup("严重程度", selectedSeverity, severityOptions);

        // 关联 GameObject
        bugGameObject = EditorGUILayout.ObjectField(
            new GUIContent("关联物体", "相关的游戏对象"),
            bugGameObject,
            typeof(GameObject),
            true
        ) as GameObject;

        // 场景和时间信息
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.LabelField("当前场景:", EditorStyles.miniLabel);
            EditorGUILayout.LabelField(EditorSceneManager.GetActiveScene().name, EditorStyles.miniLabel);
            GUILayout.FlexibleSpace();
            EditorGUILayout.LabelField(System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), EditorStyles.miniLabel);
        }
        EditorGUILayout.EndHorizontal();

        // Bug 描述
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Bug 详细描述:");
        bugDescription = EditorGUILayout.TextArea(
            bugDescription,
            GUILayout.MinHeight(100),
            GUILayout.MaxHeight(200)
        );

        // 字符统计
        EditorGUILayout.HelpBox(
            $"字符数: {bugDescription.Length}",
            bugDescription.Length > 0 ? MessageType.Info : MessageType.Warning
        );
    }

    // === 绘制高级选项 ===
    private void DrawAdvancedOptions()
    {
        EditorGUILayout.Space();

        // 折叠区域
        showAdvanced = EditorGUILayout.Foldout(showAdvanced, "高级选项", true);

        if (showAdvanced)
        {
            EditorGUI.indentLevel++;

            // 范围滑动条
            EditorGUILayout.MinMaxSlider(
                new GUIContent("范围选择"),
                ref minRange,
                ref maxRange,
                0f,
                100f
            );
            EditorGUILayout.LabelField($"最小值: {minRange:F1}", $"最大值: {maxRange:F1}");

            EditorGUILayout.Space();

            // 工具栏选择
            selectedTab = GUILayout.Toolbar(selectedTab, tabOptions);

            switch (selectedTab)
            {
                case 0:
                    DrawBasicTab();
                    break;
                case 1:
                    DrawDetailTab();
                    break;
                case 2:
                    DrawAttachmentTab();
                    break;
            }

            EditorGUI.indentLevel--;
        }
    }

    // === 基本选项卡 ===
    private void DrawBasicTab()
    {
        EditorGUILayout.LabelField("基本选项内容");
        EditorGUILayout.Toggle("发送邮件通知", false);
        EditorGUILayout.Toggle("标记为已修复", false);
    }

    // === 详细选项卡 ===
    private void DrawDetailTab()
    {
        EditorGUILayout.LabelField("详细选项内容");
        EditorGUILayout.EnumPopup("Bug 类型", BugType.Graphical);
        EditorGUILayout.IntField("重现步骤数量", 3);
    }

    // === 附件选项卡 ===
    private void DrawAttachmentTab()
    {
        EditorGUILayout.LabelField("附件内容");

        // 保存路径选择
        DrawPathSelector();
    }

    // === 路径选择器 ===
    private void DrawPathSelector()
    {
        EditorGUILayout.LabelField("保存路径", EditorStyles.boldLabel);

        EditorGUILayout.BeginHorizontal();
        {
            // 路径输入框（支持拖放）
            Rect pathRect = EditorGUILayout.GetControlRect(true, 20);
            savePath = EditorGUI.TextField(pathRect, savePath);

            // 浏览按钮
            if (GUILayout.Button("浏览...", GUILayout.Width(80)))
            {
                savePath = EditorUtility.SaveFolderPanel(
                    "选择保存路径",
                    savePath,
                    "BugReports"
                );

                if (string.IsNullOrEmpty(savePath))
                {
                    savePath = "Assets/BugReports/";
                }
            }
        }
        EditorGUILayout.EndHorizontal();

        // 处理拖放
        HandleDragAndDrop(pathRect);
    }

    // === 处理拖放 ===
    private void HandleDragAndDrop(Rect rect)
    {
        Event currentEvent = Event.current;

        // 检测拖拽
        if ((currentEvent.type == EventType.DragUpdated ||
             currentEvent.type == EventType.DragExited) &&
             rect.Contains(currentEvent.mousePosition))
        {
            // 改变鼠标外观
            DragAndDrop.visualMode = DragAndDropVisualMode.Generic;

            if (DragAndDrop.paths != null && DragAndDrop.paths.Length > 0)
            {
                if (currentEvent.type == EventType.DragUpdated)
                {
                    // 接受拖拽
                    DragAndDrop.AcceptDrag();
                }
                else
                {
                    // 应用拖拽的路径
                    savePath = DragAndDrop.paths[0];
                }
            }
        }
    }

    // === 绘制按钮 ===
    private void DrawButtons()
    {
        EditorGUILayout.Space(20);

        // 按钮区域
        EditorGUILayout.BeginHorizontal();
        {
            // 保存按钮
            if (GUILayout.Button("保存 Bug", GUILayout.Height(30)))
            {
                SaveBugReport();
            }

            // 保存并截图按钮
            if (GUILayout.Button("保存并截图", GUILayout.Height(30)))
            {
                SaveBugReportWithScreenshot();
            }
        }
        EditorGUILayout.EndHorizontal();

        // 验证提示
        if (string.IsNullOrEmpty(bugName))
        {
            EditorGUILayout.HelpBox("请填写 Bug 名称", MessageType.Warning);
        }
    }

    // === 保存 Bug 报告 ===
    private void SaveBugReport()
    {
        if (!ValidateInput())
            return;

        // 创建目录
        Directory.CreateDirectory(savePath);

        // 生成文件名（包含时间戳）
        string timestamp = System.DateTime.Now.ToString("yyyyMMdd_HHmmss");
        string fileName = $"{timestamp}_{bugName}";
        string filePath = Path.Combine(savePath, fileName + ".txt");

        // 写入文件
        using (StreamWriter writer = new StreamWriter(filePath))
        {
            writer.WriteLine($"=== Bug 报告 ===");
            writer.WriteLine($"Bug 名称: {bugName}");
            writer.WriteLine($"严重程度: {severityOptions[selectedSeverity]}");
            writer.WriteLine($"关联物体: {(bugGameObject ? bugGameObject.name : "无")}");
            writer.WriteLine($"场景名称: {EditorSceneManager.GetActiveScene().name}");
            writer.WriteLine($"创建时间: {System.DateTime.Now}");
            writer.WriteLine($"\n=== 详细描述 ===");
            writer.WriteLine(bugDescription);
        }

        AssetDatabase.Refresh();

        Debug.Log($"Bug 报告已保存: {filePath}");
        EditorUtility.DisplayDialog("成功", "Bug 报告已保存！", "确定");
    }

    // === 保存并截图 ===
    private void SaveBugReportWithScreenshot()
    {
        if (!ValidateInput())
            return;

        // 创建目录
        Directory.CreateDirectory(savePath);

        // 生成文件名
        string timestamp = System.DateTime.Now.ToString("yyyyMMdd_HHmmss");
        string fileName = $"{timestamp}_{bugName}";

        // 保存文本报告
        string textPath = Path.Combine(savePath, fileName + ".txt");
        using (StreamWriter writer = new StreamWriter(textPath))
        {
            writer.WriteLine($"=== Bug 报告 ===");
            writer.WriteLine($"Bug 名称: {bugName}");
            writer.WriteLine($"关联物体: {(bugGameObject ? bugGameObject.name : "无")}");
            writer.WriteLine($"场景名称: {EditorSceneManager.GetActiveScene().name}");
            writer.WriteLine($"创建时间: {System.DateTime.Now}");
            writer.WriteLine($"\n=== 详细描述 ===");
            writer.WriteLine(bugDescription);
        }

        // 截图
        string screenshotPath = Path.Combine(savePath, fileName + ".png");
        ScreenCapture.CaptureScreenshot(screenshotPath);

        AssetDatabase.Refresh();

        Debug.Log($"Bug 报告和截图已保存");
        EditorUtility.DisplayDialog("成功", "Bug 报告和截图已保存！", "确定");
    }

    // === 输入验证 ===
    private bool ValidateInput()
    {
        if (string.IsNullOrEmpty(bugName))
        {
            EditorUtility.DisplayDialog("错误", "请填写 Bug 名称！", "确定");
            return false;
        }
        return true;
    }

    // === 枚举定义 ===
    private enum BugType
    {
        Graphical,
        Audio,
        Gameplay,
        Network,
        Performance
    }
}
```

### 4.2 窗口效果预览

```
┌─────────────────────────────────────────────────┐
│              🐛 Bug 报告工具                      │
├─────────────────────────────────────────────────┤
│                                                 │
│  Bug 名称        [Bug 描述_______________]       │
│  严重程度      [中 ▼]                           │
│  关联物体      [None (GameObject)_____]         │
│  当前场景: SampleScene    2024-01-13 10:30:00  │
│                                                 │
│  Bug 详细描述:                                   │
│  ┌─────────────────────────────────────────┐    │
│  │ 请在此描述 Bug 的详细信息...             │    │
│  │                                         │    │
│  │                                         │    │
│  └─────────────────────────────────────────┘    │
│  ℹ 字符数: 15                                  │
│                                                 │
│  ▼ 高级选项                                     │
│    范围选择                                     │
│    ━━━━━●─────────────────●━━━  0 - 100       │
│    最小值: 25          最大值: 75              │
│                                                 │
│    [基本信息][详细信息][附件]                   │
│                                                 │
│  ┌───────────────────┐  ┌───────────────────┐  │
│  │   保存 Bug       │  │  保存并截图       │  │
│  └───────────────────┘  └───────────────────┘  │
│                                                 │
│  ⚠ 请填写 Bug 名称                              │
└─────────────────────────────────────────────────┘
```

---

## 五、常用 EditorWindow API

### 5.1 窗口控制

| API | 说明 |
|-----|------|
| `titleContent` | 窗口标题（ GUIContent 类型） |
| `minSize` | 窗口最小尺寸 |
| `maxSize` | 窗口最大尺寸 |
| `position` | 窗口位置和大小 |
| `Repaint()` | 强制重绘窗口 |
| `Close()` | 关闭窗口 |
| `Focus()` | 聚焦窗口 |

### 5.2 对话框

| API | 说明 |
|-----|------|
| `EditorUtility.DisplayDialog()` | 显示简单对话框 |
| `EditorUtility.DisplayDialogComplex()` | 显示带多个按钮的对话框 |
| `EditorUtility.SaveFilePanel()` | 保存文件对话框 |
| `EditorUtility.SaveFolderPanel()` | 保存文件夹对话框 |
| `EditorUtility.OpenFilePanel()` | 打开文件对话框 |
| `EditorUtility.OpenFolderPanel()` | 打开文件夹对话框 |

### 5.3 对话框示例

```csharp
// 简单对话框
bool result = EditorUtility.DisplayDialog(
    "标题",
    "对话框内容",
    "确定",
    "取消"
);

// 复杂对话框（3个按钮）
int option = EditorUtility.DisplayDialogComplex(
    "标题",
    "内容",
    "是",
    "否",
    "取消"
);
// 返回值: 0=是, 1=否, 2=取消
```

---

## 六、编辑器样式使用

EditorGUILayout 提供了多种内置样式。

### 6.1 内置样式

| 样式 | 用途 |
|------|------|
| `EditorStyles.boldLabel` | 粗体标签 |
| `EditorStyles.label` | 普通标签 |
| `EditorStyles.miniLabel` | 小号标签 |
| `EditorStyles.textField` | 文本框 |
| `EditorStyles.helpBox` | 帮助框 |
| `EditorStyles.numberField` | 数字框 |
| `EditorStyles.toggle` | 开关 |

### 6.2 自定义样式

```csharp
private void OnGUI()
{
    // 创建自定义样式
    var customStyle = new GUIStyle(EditorStyles.boldLabel)
    {
        fontSize = 18,
        fontStyle = FontStyle.Bold,
        alignment = TextAnchor.MiddleCenter,
        normal = { textColor = Color.cyan }
    };

    EditorGUILayout.LabelField("自定义样式文本", customStyle);

    // 背景色样式
    var backgroundStyle = new GUIStyle(GUI.skin.box)
    {
        normal = { background = MakeTexture(2, 2, Color.gray) }
    };

    GUILayout.Box("带背景的文本", backgroundStyle, GUILayout.Height(50));
}

// 创建纯色纹理辅助方法
private Texture2D MakeTexture(int width, int height, Color col)
{
    Color[] pix = new Color[width * height];
    for (int i = 0; i < pix.Length; i++)
        pix[i] = col;

    Texture2D result = new Texture2D(width, height);
    result.SetPixels(pix);
    result.Apply();
    return result;
}
```

---

## 七、最佳实践

### 7.1 数据持久化

```csharp
public class BugReportWindow : EditorWindow
{
    private string savePath = "Assets/BugReports/";

    private void OnEnable()
    {
        // 加载保存的路径
        savePath = EditorPrefs.GetString("BugReportWindow_SavePath", "Assets/BugReports/");
    }

    private void OnDisable()
    {
        // 保存路径设置
        EditorPrefs.SetString("BugReportWindow_SavePath", savePath);
    }
}
```

### 7.2 性能优化

```csharp
public class BugReportWindow : EditorWindow
{
    private void OnInspectorUpdate()
    {
        // 只在需要时重绘
        if (needsRepaint)
        {
            Repaint();
            needsRepaint = false;
        }
    }

    // 避免在 OnGUI 中执行重操作
    private void OnGUI()
    {
        // ❌ 不好：每次 OnGUI 都计算
        // string result = HeavyCalculation();

        // ✅ 好：缓存结果
        // if (cachedResult == null)
        //     cachedResult = HeavyCalculation();
    }
}
```

### 7.3 快捷键设置

```csharp
// 基本快捷键
[MenuItem("Tools/MyWindow %g")]  // Ctrl+G
static void ShowWindow() { }

// 组合快捷键
[MenuItem("Tools/MyWindow %#g")] // Ctrl+Shift+G
static void ShowWindow() { }

// 快捷键符号说明
// % = Ctrl / Cmd
// # = Shift
// & = Alt
// _ = 无修饰键
```

---

## 八、总结

本文通过 Bug 报告工具案例介绍了 EditorWindow 的完整开发流程：

| 主题 | 核心要点 |
|------|---------|
| **窗口创建** | GetWindow<T>()、MenuItem |
| **生命周期** | OnEnable/OnDisable/OnGUI/OnDestroy |
| **布局控件** | EditorGUILayout 各种控件 |
| **拖放支持** | DragAndDrop 处理 |
| **对话框** | EditorUtility.DisplayDialog |
| **数据持久化** | EditorPrefs |
| **性能优化** | 缓存数据、按需 Repaint |

> 💡 **开发建议**：
> - 使用 EditorPrefs 保存用户偏好
> - 缓存计算结果避免 OnGUI 中重操作
> - 设置合理的 minSize 确保窗口可用
> - 使用 EditorGUI.indentLevel 管理缩进
> - 为常用功能设置快捷键

下一篇将详细介绍 **Handles 和 Gizmos 可视化调试工具**。

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

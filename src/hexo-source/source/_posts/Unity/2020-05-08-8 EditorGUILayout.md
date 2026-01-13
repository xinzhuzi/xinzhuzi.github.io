---
title: "Unity EditorGUILayout 完全手册：自动布局系统的使用艺术"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UnityEditor, EditorGUILayout, 编辑器扩展, 布局控件, 界面设计]
image: /images/unity-editor-layout-banner.jpg
---

# 📐 Unity EditorGUILayout 完全手册：自动布局系统的使用艺术

> 💡 **布局系统的价值**：
> - 手动计算 Rect 太麻烦，有没有自动布局方案？
> - EditorGUILayout 和 GUILayout 有什么区别？
> - 如何创建既美观又易用的编辑器界面？
> - 想要更高级的布局效果，该怎么实现？
>
> **这篇文章！** 将系统讲解 Unity 自动布局系统，帮你创建专业级编辑器界面！

## 一、EditorGUILayout 概述

`EditorGUILayout` 是 Unity 提供的自动布局系统，用于在编辑器中创建可自适应的 GUI 界面。

### 1.1 与 EditorGUI 的区别

| 特性 | EditorGUILayout | EditorGUI |
|------|----------------|-----------|
| **布局方式** | 自动布局 | 手动指定 Rect |
| **使用场景** | Inspector、EditorWindow | 复杂自定义绘制 |
| **代码复杂度** | 简单 | 较高 |
| **布局灵活性** | 受限 | 完全控制 |

### 1.2 核心概念

```csharp
// 自动布局会自动计算控件位置和大小
EditorGUILayout.LabelField("自动标签");

// 手动布局需要指定 Rect
EditorGUI.LabelField(new Rect(0, 0, 100, 20), "手动标签");
```

> 💡 推荐使用 EditorGUILayout 进行常规的编辑器界面开发。

---

## 二、布局容器

`EditorGUILayout` 提供了两种基础布局容器。

### 2.1 垂直布局 - BeginVertical/EndVertical

```csharp
EditorGUILayout.BeginVertical();
{
    // 内容垂直排列
    EditorGUILayout.LabelField("第一行");
    EditorGUILayout.LabelField("第二行");
    EditorGUILayout.LabelField("第三行");
}
EditorGUILayout.EndVertical();
```

**显示效果：**
```
┌────────────────────┐
│ 第一行             │
├────────────────────┤
│ 第二行             │
├────────────────────┤
│ 第三行             │
└────────────────────┘
```

### 2.2 水平布局 - BeginHorizontal/EndHorizontal

```csharp
EditorGUILayout.BeginHorizontal();
{
    // 内容水平排列
    EditorGUILayout.LabelField("左");
    EditorGUILayout.LabelField("中");
    EditorGUILayout.LabelField("右");
}
EditorGUILayout.EndHorizontal();
```

**显示效果：**
```
┌───────────────────────────┐
│ 左    │ 中    │ 右    │   │
└───────────────────────────┘
```

### 2.3 嵌套布局示例

```csharp
EditorGUILayout.BeginVertical();  // 外层垂直
{
    EditorGUILayout.LabelField("标题");

    EditorGUILayout.BeginHorizontal();  // 内层水平
    {
        EditorGUILayout.LabelField("姓名:", GUILayout.MaxWidth(50));
        EditorGUILayout.TextField("");
    }
    EditorGUILayout.EndHorizontal();

    EditorGUILayout.BeginHorizontal();
    {
        EditorGUILayout.LabelField("年龄:", GUILayout.MaxWidth(50));
        EditorGUILayout.IntField(18);
    }
    EditorGUILayout.EndHorizontal();
}
EditorGUILayout.EndVertical();
```

---

## 三、基础字段控件

所有 `EditorGUILayout` 的字段控件都以 `Field` 结尾。

### 3.1 控件速查表

| 控件 | 方法 | 用途 |
|------|------|------|
| **标签** | `LabelField()` | 显示只读文本 |
| **整数** | `IntField()` | 输入整数值 |
| **浮点** | `FloatField()` | 输入浮点数值 |
| **文本** | `TextField()` | 输入单行文本 |
| **文本域** | `TextArea()` | 输入多行文本 |
| **枚举** | `EnumPopup()` | 选择枚举值 |
| **布尔** | `Toggle()` | 开关切换 |
| **对象** | `ObjectField()` | 拖拽引用对象 |

### 3.2 基础控件示例

```csharp
using UnityEngine;
using UnityEditor;

public class BasicFieldsExample : EditorWindow
{
    private string playerName = "玩家";
    private int level = 1;
    private float health = 100f;
    private bool isActive = true;

    [MenuItem("Tools/基础字段示例")]
    static void ShowWindow()
    {
        GetWindow<BasicFieldsExample>("基础字段");
    }

    void OnGUI()
    {
        // 标签字段（只读）
        EditorGUILayout.LabelField("=== 角色属性 ===");

        // 整数字段
        level = EditorGUILayout.IntField("等级", level);

        // 浮点数字段
        health = EditorGUILayout.FloatField("生命值", health);

        // 文本字段
        playerName = EditorGUILayout.TextField("玩家名称", playerName);

        // 布尔开关
        isActive = EditorGUILayout.Toggle("是否激活", isActive);

        // 分隔线
        EditorGUILayout.Space();
        EditorGUILayout.HelpBox($"等级: {level}\n生命值: {health}\n激活: {isActive}", MessageType.Info);
    }
}
```

---

## 四、向量与颜色控件

### 4.1 向量控件

| 控件 | 方法 | 说明 |
|------|------|------|
| **Vector2** | `Vector2Field()` | 二维向量 (X, Y) |
| **Vector3** | `Vector3Field()` | 三维向量 (X, Y, Z) |
| **Vector4** | `Vector4Field()` | 四维向量 (X, Y, Z, W) |
| **Rect** | `RectField()` | 矩形 (X, Y, Width, Height) |
| **Bounds** | `BoundsField()` | 包围盒 (Center, Size) |

### 4.2 颜色控件

| 控件 | 方法 | 说明 |
|------|------|------|
| **Color** | `ColorField()` | 颜色选择器 |
| **Gradient** | `GradientField()` | 渐变编辑器 |

### 4.3 向量与颜色示例

```csharp
using UnityEngine;
using UnityEditor;

public class VectorColorExample : EditorWindow
{
    private Vector2 position2D = Vector2.zero;
    private Vector3 position3D = Vector3.zero;
    private Color color = Color.white;

    [MenuItem("Tools/向量颜色示例")]
    static void ShowWindow()
    {
        GetWindow<VectorColorExample>("向量与颜色");
    }

    void OnGUI()
    {
        EditorGUILayout.LabelField("位置设置", EditorStyles.boldLabel);

        // 二维向量
        position2D = EditorGUILayout.Vector2Field("2D 位置", position2D);

        // 三维向量
        position3D = EditorGUILayout.Vector3Field("3D 位置", position3D);

        EditorGUILayout.Space();

        // 颜色字段
        color = EditorGUILayout.ColorField("物体颜色", color);

        // 预览颜色
        EditorGUI.DrawRect(GUILayoutUtility.GetRect(10, 50), color);
    }
}
```

---

## 五、滑动条控件

### 5.1 Slider 与 IntSlider

| 控件 | 方法 | 返回类型 | 说明 |
|------|------|---------|------|
| **浮点滑动条** | `Slider()` | float | 0-1 或自定义范围 |
| **整数滑动条** | `IntSlider()` | int | 整数范围 |
| **最小最大滑动条** | `MinMaxSlider()` | void | 双端滑动条 |

### 5.2 滑动条示例

```csharp
using UnityEngine;
using UnityEditor;

public class SliderExample : EditorWindow
{
    [Range(0, 100)]
    private float health = 50f;

    [Range(0, 100)]
    private int level = 1;

    private float minValue = 0f;
    private float maxValue = 100f;

    [MenuItem("Tools/滑动条示例")]
    static void ShowWindow()
    {
        GetWindow<SliderExample>("滑动条控件");
    }

    void OnGUI()
    {
        // 浮点滑动条
        health = EditorGUILayout.Slider("生命值", health, 0, 100);

        // 整数滑动条
        level = EditorGUILayout.IntSlider("等级", level, 1, 99);

        EditorGUILayout.Space();

        // 最小最大滑动条（双端）
        EditorGUILayout.LabelField("范围选择:");
        EditorGUILayout.MinMaxSlider(ref minValue, ref maxValue, 0, 200);
        EditorGUILayout.LabelField($"最小值: {minValue:F1}", $"最大值: {maxValue:F1}");
    }
}
```

---

## 六、进度条 - ProgressBar

`EditorGUI.ProgressBar()` 用于绘制可视化的进度条。

### 6.1 基本语法

```csharp
EditorGUI.ProgressBar(
    position,      // Rect - 进度条位置和大小
    value,         // float - 进度值 (0-1)
    text           // string - 显示文本
);
```

### 6.2 动态颜色进度条示例

```csharp
using UnityEngine;
using UnityEditor;

public class ProgressBarExample : EditorWindow
{
    private float health = 75f;

    [MenuItem("Tools/进度条示例")]
    static void ShowWindow()
    {
        GetWindow<ProgressBarExample>("进度条控件");
    }

    void OnGUI()
    {
        EditorGUILayout.LabelField("生命值设置", EditorStyles.boldLabel);
        health = EditorGUILayout.Slider("生命值", health, 0, 100);

        EditorGUILayout.Space(20);

        // 根据生命值设置颜色
        Color barColor = Color.gray;
        if (health < 20)
            barColor = Color.red;      // 危险
        else if (health < 50)
            barColor = Color.yellow;   // 警告
        else if (health > 80)
            barColor = Color.green;    // 健康

        // 保存当前颜色
        Color originalColor = GUI.color;
        GUI.color = barColor;

        // 获取进度条区域
        Rect progressRect = GUILayoutUtility.GetRect(200, 20);

        // 绘制进度条
        EditorGUI.ProgressBar(progressRect, health / 100f, $"生命值: {(int)health}%");

        // 恢复颜色
        GUI.color = originalColor;

        // 显示状态提示
        EditorGUILayout.Space();
        if (health < 20)
            EditorGUILayout.HelpBox("生命值过低，请及时治疗！", MessageType.Error);
        else if (health > 80)
            EditorGUILayout.HelpBox("生命值充沛！", MessageType.Info);
    }
}
```

---

## 七、帮助框 - HelpBox

`EditorGUILayout.HelpBox()` 用于显示提示信息。

### 7.1 消息类型

| MessageType | 说明 | 图标 |
|-------------|------|------|
| `None` | 无图标 | 无 |
| `Info` | 信息提示 | ℹ️ |
| `Warning` | 警告提示 | ⚠️ |
| `Error` | 错误提示 | ❌ |

### 7.2 使用示例

```csharp
using UnityEngine;
using UnityEditor;

public class HelpBoxExample : EditorWindow
{
    private int damage = 10;

    [MenuItem("Tools/帮助框示例")]
    static void ShowWindow()
    {
        GetWindow<HelpBoxExample>("帮助框控件");
    }

    void OnGUI()
    {
        damage = EditorGUILayout.IntSlider("伤害值", damage, 0, 20);

        EditorGUILayout.Space();

        // 根据伤害值显示不同提示
        if (damage < 5)
        {
            EditorGUILayout.HelpBox(
                "伤害过低，无法击败敌人！建议提升攻击力。",
                MessageType.Error
            );
        }
        else if (damage > 15)
        {
            EditorGUILayout.HelpBox(
                "伤害过高，可能导致游戏平衡性问题。",
                MessageType.Warning
            );
        }
        else
        {
            EditorGUILayout.HelpBox(
                "伤害值在合理范围内。",
                MessageType.Info
            );
        }
    }
}
```

---

## 八、折叠区域 - Foldout

`EditorGUILayout.Foldout()` 用于创建可折叠的内容区域。

### 8.1 基本语法

```csharp
bool foldout = false;

// 绘制折叠头
foldout = EditorGUILayout.Foldout(foldout, "折叠标题");

// 展开时显示内容
if (foldout)
{
    // 折叠内容...
    ++EditorGUI.indentLevel;  // 缩进内容
    // 绘制子项...
    --EditorGUI.indentLevel;  // 恢复缩进
}
```

### 8.2 折叠区域示例

```csharp
using UnityEngine;
using UnityEditor;

public class FoldoutExample : EditorWindow
{
    private bool showBasic = true;
    private bool showCombat = false;
    private bool showInventory = false;

    private string playerName = "玩家";
    private int level = 1;
    private float attack = 10f;
    private float defense = 5f;
    private string[] items = new string[] { "剑", "盾牌", "药水" };

    [MenuItem("Tools/折叠区域示例")]
    static void ShowWindow()
    {
        GetWindow<FoldoutExample>("折叠区域");
    }

    void OnGUI()
    {
        // 基本信息折叠区
        showBasic = EditorGUILayout.Foldout(showBasic, "基本信息", true);
        if (showBasic)
        {
            EditorGUI.indentLevel++;
            playerName = EditorGUILayout.TextField("名称", playerName);
            level = EditorGUILayout.IntField("等级", level);
            EditorGUI.indentLevel--;
        }

        // 战斗属性折叠区
        showCombat = EditorGUILayout.Foldout(showCombat, "战斗属性", true);
        if (showCombat)
        {
            EditorGUI.indentLevel++;
            attack = EditorGUILayout.Slider("攻击力", attack, 0, 100);
            defense = EditorGUILayout.Slider("防御力", defense, 0, 100);
            EditorGUI.indentLevel--;
        }

        // 背包物品折叠区
        showInventory = EditorGUILayout.Foldout(showInventory, "背包物品", true);
        if (showInventory)
        {
            EditorGUI.indentLevel++;
            foreach (var item in items)
            {
                EditorGUILayout.LabelField("• " + item);
            }
            EditorGUI.indentLevel--;
        }
    }
}
```

---

## 九、完整示例：角色属性编辑器

综合运用各种控件创建完整的角色编辑器。

### 9.1 目标组件

```csharp
using UnityEngine;

public class PlayerCharacter : MonoBehaviour
{
    [Header("基本信息")]
    public int playerId;
    public string playerName;
    [TextArea]
    public string backStory;

    [Header("战斗属性")]
    [Range(0, 100)]
    public float health = 50f;
    [Range(0, 20)]
    public float damage = 10f;

    [Header("武器")]
    public float weaponDamage1;
    public float weaponDamage2;

    [Header("装备")]
    public string shoeName;
    public int shoeSize;
    public string shoeType;
}
```

### 9.2 自定义编辑器

```csharp
using UnityEngine;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(PlayerCharacter))]
public class PlayerCharacterEditor : Editor
{
    private SerializedProperty playerIdProp;
    private SerializedProperty playerNameProp;
    private SerializedProperty backStoryProp;
    private SerializedProperty healthProp;
    private SerializedProperty damageProp;
    private SerializedProperty weaponDamage1Prop;
    private SerializedProperty weaponDamage2Prop;
    private SerializedProperty shoeNameProp;
    private SerializedProperty shoeSizeProp;
    private SerializedProperty shoeTypeProp;

    private bool showWeapons = false;
    private bool showEquipment = true;

    private void OnEnable()
    {
        // 缓存所有属性
        playerIdProp = serializedObject.FindProperty("playerId");
        playerNameProp = serializedObject.FindProperty("playerName");
        backStoryProp = serializedObject.FindProperty("backStory");
        healthProp = serializedObject.FindProperty("health");
        damageProp = serializedObject.FindProperty("damage");
        weaponDamage1Prop = serializedObject.FindProperty("weaponDamage1");
        weaponDamage2Prop = serializedObject.FindProperty("weaponDamage2");
        shoeNameProp = serializedObject.FindProperty("shoeName");
        shoeSizeProp = serializedObject.FindProperty("shoeSize");
        shoeTypeProp = serializedObject.FindProperty("shoeType");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        // 标题
        EditorGUILayout.LabelField("角色属性编辑器", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        // === 基本信息区域 ===
        EditorGUILayout.LabelField("=== 基本信息 ===", EditorStyles.boldLabel);
        EditorGUILayout.PropertyField(playerIdProp, new GUIContent("角色 ID"));
        EditorGUILayout.PropertyField(playerNameProp, new GUIContent("角色名称"));

        EditorGUILayout.Space();

        // 背景故事
        EditorGUILayout.LabelField("背景故事");
        EditorGUILayout.PropertyField(backStoryProp, GUIContent.none, GUILayout.MinHeight(60));

        EditorGUILayout.Space();

        // === 战斗属性区域 ===
        EditorGUILayout.LabelField("=== 战斗属性 ===", EditorStyles.boldLabel);

        // 生命值滑动条 + 进度条
        EditorGUILayout.Slider(healthProp, 0, 100, new GUIContent("生命值"));

        // 根据生命值显示颜色进度条
        float healthValue = healthProp.floatValue;
        Color healthColor = GetHealthColor(healthValue);

        Color originalColor = GUI.color;
        GUI.color = healthColor;

        Rect healthRect = GUILayoutUtility.GetRect(200, 20);
        EditorGUI.ProgressBar(healthRect, healthValue / 100f, $"生命值: {(int)healthValue}%");

        GUI.color = originalColor;
        EditorGUILayout.Space();

        // 伤害值滑动条 + 帮助提示
        EditorGUILayout.Slider(damageProp, 0, 20, new GUIContent("伤害值"));

        float damageValue = damageProp.floatValue;
        if (damageValue < 5)
        {
            EditorGUILayout.HelpBox("伤害过低，可能无法击败敌人！", MessageType.Error);
        }
        else if (damageValue > 15)
        {
            EditorGUILayout.HelpBox("伤害过高，可能影响游戏平衡！", MessageType.Warning);
        }

        EditorGUILayout.Space();

        // === 武器折叠区域 ===
        showWeapons = EditorGUILayout.Foldout(showWeapons, "武器", true);
        if (showWeapons)
        {
            EditorGUI.indentLevel++;
            EditorGUILayout.PropertyField(weaponDamage1Prop, new GUIContent("主武器伤害"));
            EditorGUILayout.PropertyField(weaponDamage2Prop, new GUIContent("副武器伤害"));
            EditorGUI.indentLevel--;
        }

        EditorGUILayout.Space();

        // === 装备折叠区域 ===
        showEquipment = EditorGUILayout.Foldout(showEquipment, "装备", true);
        if (showEquipment)
        {
            EditorGUI.indentLevel++;

            // 鞋子信息 - 水平布局
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("鞋子名称", GUILayout.MaxWidth(70));
                EditorGUILayout.PropertyField(shoeNameProp, GUIContent.none);
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("鞋子尺寸", GUILayout.MaxWidth(70));
                EditorGUILayout.PropertyField(shoeSizeProp, GUIContent.none, GUILayout.MaxWidth(100));
                EditorGUILayout.LabelField("类型", GUILayout.MaxWidth(50));
                EditorGUILayout.PropertyField(shoeTypeProp, GUIContent.none);
            }
            EditorGUILayout.EndHorizontal();

            EditorGUI.indentLevel--;
        }

        // 应用修改
        serializedObject.ApplyModifiedProperties();
    }

    private Color GetHealthColor(float health)
    {
        if (health < 20)
            return new Color(1f, 0.3f, 0.3f);  // 红色
        else if (health < 50)
            return new Color(1f, 0.8f, 0.3f);  // 橙色
        else if (health < 80)
            return new Color(1f, 1f, 0.3f);    // 黄色
        else
            return new Color(0.3f, 0.8f, 0.3f); // 绿色
    }
}
```

### 9.3 显示效果预览

```
┌────────────────────────────────────────────┐
│ 角色属性编辑器                               │
├────────────────────────────────────────────┤
│ === 基本信息 ===                            │
│ 角色 ID        1001                         │
│ 角色名称        勇者                         │
│                                            │
│ 背景故事                                   │
│ ┌──────────────────────────────────────┐  │
│ │ 来自远方村庄的年轻冒险家...            │  │
│ │                                      │  │
│ └──────────────────────────────────────┘  │
│                                            │
│ === 战斗属性 ===                            │
│ 生命值   ████████████░░░░░░░░░  50        │
│ ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░  生命值: 50%     │
│                                            │
│ 伤害值   █████░░░░░░░░░░░░░░░░  10        │
│ ℹ 伤害适中                                │
│                                            │
│ ▼ 武器                                    │
│   主武器伤害    50                          │
│   副武器伤害    30                          │
│                                            │
│ ▼ 装备                                    │
│   鞋子名称      [龙鳞战靴_______________]   │
│   鞋子尺寸  [42]  类型  [传说________]     │
└────────────────────────────────────────────┘
```

---

## 十、GUILayoutOptions 布局选项

使用 `GUILayoutOptions` 可以精确控制控件的布局。

### 10.1 常用选项

| 选项 | 说明 |
|------|------|
| `GUILayout.Width(float)` | 固定宽度 |
| `GUILayout.Height(float)` | 固定高度 |
| `GUILayout.MinWidth(float)` | 最小宽度 |
| `GUILayout.MaxWidth(float)` | 最大宽度 |
| `GUILayout.MinHeight(float)` | 最小高度 |
| `GUILayout.MaxHeight(float)` | 最大高度 |
| `GUILayout.ExpandWidth(bool)` | 是否填充可用宽度 |
| `GUILayout.ExpandHeight(bool)` | 是否填充可用高度 |

### 10.2 使用示例

```csharp
void OnGUI()
{
    EditorGUILayout.BeginHorizontal();
    {
        // 固定宽度标签
        EditorGUILayout.LabelField("姓名:", GUILayout.Width(50));

        // 填充剩余空间
        EditorGUILayout.TextField("", GUILayout.ExpandWidth(true));

        // 固定宽度按钮
        if (GUILayout.Button("选择", GUILayout.Width(60)))
        {
            Debug.Log("点击选择");
        }
    }
    EditorGUILayout.EndHorizontal();

    // 固定高度的文本域
    EditorGUILayout.TextArea("", GUILayout.Height(100));

    // 限制最大宽度的输入框
    EditorGUILayout.TextField("", GUILayout.MaxWidth(200));
}
```

---

## 十一、总结

本文介绍了 Unity EditorGUILayout 布局控件系统：

| 分类 | 核心控件 |
|------|---------|
| **布局容器** | BeginVertical/EndVertical, BeginHorizontal/EndHorizontal |
| **基础字段** | LabelField, IntField, FloatField, TextField, TextArea |
| **向量颜色** | Vector2Field, Vector3Field, ColorField |
| **滑动条** | Slider, IntSlider, MinMaxSlider |
| **进度条** | EditorGUI.ProgressBar |
| **帮助框** | HelpBox |
| **折叠区** | Foldout |
| **布局选项** | Width, Height, ExpandWidth, etc. |

> 💡 **开发建议**：
> - 优先使用 EditorGUILayout 而非 EditorGUI（更简洁）
> - 使用 BeginVertical/BeginHorizontal 组织布局层次
> - 缓存 SerializedProperty 以提高性能
> - 使用 GUILayoutOptions 精确控制控件大小
> - 结合 HelpBox 和 ProgressBar 提升用户体验

下一篇将详细介绍 **EditorWindow 实战案例**。

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

---
title: "Unity CustomEditor 与 PropertyDrawer：自定义 Inspector 的艺术"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UnityEditor, CustomEditor, PropertyDrawer, 编辑器扩展, Inspector]
image: /images/unity-custom-inspector-banner.jpg
---

# 🎨 Unity CustomEditor 与 PropertyDrawer：自定义 Inspector 的艺术

> 💡 **Inspector 定制的价值**：
> - 默认的 Inspector 面板不够直观，策划看不懂？
> - 想为自定义组件打造专业的编辑界面？
> - 如何让复杂的配置变得简单易用？
> - PropertyDrawer 和 CustomEditor 该怎么选？
>
> **这篇文章！** 将深入剖析 Unity 自定义 Inspector 的两大核心技术，让你的组件界面焕然一新！

## 一、自定义 Inspector 概述

Unity 提供了两种主要方式来自定义 Inspector 面板：

| 方式 | 作用范围 | 适用场景 |
|------|---------|---------|
| **CustomEditor** | 整个组件 | 完全自定义组件的 Inspector 界面 |
| **PropertyDrawer** | 单个属性/类 | 自定义可复用类型的显示方式 |

> 💡 核心区别：CustomEditor 控制整个组件的显示，PropertyDrawer 控制特定类型在所有 Inspector 中的显示。

```
┌─────────────────────────────────────────────────────────┐
│                    Inspector 面板                        │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────┐  │
│  │          CustomEditor (控制整个组件)              │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  属性 A (普通显示)                           │  │  │
│  │  ├─────────────────────────────────────────────┤  │  │
│  │  │  自定义类型 (PropertyDrawer 自定义显示)     │  │  │
│  │  │  ┌─────────┐ ┌─────────┐                    │  │  │
│  │  │  │ 子字段1 │ │ 子字段2 │  自定义布局        │  │  │
│  │  │  └─────────┘ └─────────┘                    │  │  │
│  │  ├─────────────────────────────────────────────┤  │  │
│  │  │  属性 B (普通显示)                           │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 二、CustomEditor 自定义组件编辑器

`CustomEditor` 特性用于为特定组件创建自定义 Inspector 界面。

### 2.1 基本语法

```csharp
using UnityEngine;
using UnityEditor;

// CustomEditor 特性指定要自定义的目标类型
[CustomEditor(typeof(目标组件类型))]
public class 自定义Inspector名称 : Editor
{
    // 序列化属性
    SerializedProperty 属性名;

    void OnEnable()
    {
        // 获取序列化属性
        属性名 = serializedObject.FindProperty("属性名称");
    }

    public override void OnInspectorGUI()
    {
        // 更新序列化对象
        serializedObject.Update();

        // 自定义绘制代码...

        // 应用修改的属性
        serializedObject.ApplyModifiedProperties();
    }
}
```

### 2.2 常用特性

| 特性 | 说明 |
|------|------|
| `[CanEditMultipleObjects]` | 支持同时编辑多个对象 |
| `[CustomEditor(typeof(T))]` | 指定自定义的组件类型 |

### 2.3 简单示例：角色属性编辑器

```csharp
using UnityEngine;

// 目标组件
public class Character : MonoBehaviour
{
    [Header("基础属性")]
    [Range(0, 100)]
    public int attack = 10;

    [Range(0, 100)]
    public int defense = 5;

    public float health = 100f;
}
```

```csharp
using UnityEngine;
using UnityEditor;

// 自定义 Inspector
[CanEditMultipleObjects]
[CustomEditor(typeof(Character))]
public class CharacterInspector : Editor
{
    // 序列化属性
    SerializedProperty attackProp;
    SerializedProperty defenseProp;
    SerializedProperty healthProp;

    void OnEnable()
    {
        // 通过属性名获取 SerializedProperty
        attackProp = serializedObject.FindProperty("attack");
        defenseProp = serializedObject.FindProperty("defense");
        healthProp = serializedObject.FindProperty("health");
    }

    public override void OnInspectorGUI()
    {
        // 更新序列化对象状态
        serializedObject.Update();

        // 自定义标题
        EditorGUILayout.LabelField("角色属性", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        // 绘制攻击力滑动条
        EditorGUILayout.IntSlider(attackProp, 0, 100, new GUIContent("攻击力"));

        // 绘制防御力滑动条
        EditorGUILayout.IntSlider(defenseProp, 0, 100, new GUIContent("防御力"));

        // 绘制生命值
        EditorGUILayout.PropertyField(healthProp, new GUIContent("生命值"));

        // 计算战斗力
        if (attackProp.intValue > 0 || defenseProp.intValue > 0)
        {
            int combatPower = attackProp.intValue * 2 + defenseProp.intValue;
            EditorGUILayout.HelpBox($"战斗力: {combatPower}", MessageType.Info);
        }

        // 应用修改
        serializedObject.ApplyModifiedProperties();
    }
}
```

### 2.4 运行效果

```
┌────────────────────────────────────┐
│  Character (Script)                │
├────────────────────────────────────┤
│  角色属性                           │
│                                    │
│  攻击力   50 ████████░░░░░░░       │
│  防御力   30 █████░░░░░░░░░░       │
│  生命值   100                      │
│                                    │
│  ℹ 战斗力: 130                     │
└────────────────────────────────────┘
```

---

## 三、PropertyDrawer 属性抽屉

`PropertyDrawer` 用于自定义可序列化类或枚举在 Inspector 中的显示方式，**可全局复用**。

### 3.1 基本语法

```csharp
using UnityEditor;

// 为指定类型创建 PropertyDrawer
[CustomPropertyDrawer(typeof(目标类型))]
public class 自定义PropertyDrawer名称 : PropertyDrawer
{
    // 绘制 GUI
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // 自定义绘制逻辑
    }

    // 返回属性高度
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        // 返回自定义高度
    }
}
```

### 3.2 参数说明

| 参数 | 类型 | 说明 |
|------|------|------|
| `position` | Rect | 在 Inspector 中的绘制区域 |
| `property` | SerializedProperty | 当前绘制的序列化属性 |
| `label` | GUIContent | 属性的标签（类名） |

### 3.3 常用 API

| API | 说明 |
|-----|------|
| `property.FindPropertyRelative("name")` | 获取子属性 |
| `EditorGUI.PropertyField()` | 绘制属性字段 |
| `EditorGUI.BeginChangeCheck()` | 开始检测修改 |
| `EditorGUI.EndChangeCheck()` | 结束检测，返回是否修改 |

---

## 四、PropertyDrawer 示例：MinMaxSlider

创建一个最小值-最大值滑动条属性。

### 4.1 定义数据类型

```csharp
using System;

/// <summary>
/// 最小-最大值范围
/// </summary>
[Serializable]
public class MinMaxRange
{
    public float min = 0f;
    public float max = 100f;

    public MinMaxRange(float min, float max)
    {
        this.min = min;
        this.max = max;
    }
}
```

### 4.2 创建 PropertyDrawer

```csharp
using UnityEngine;
using UnityEditor;

/// <summary>
/// MinMaxRange 的自定义 PropertyDrawer
/// </summary>
[CustomPropertyDrawer(typeof(MinMaxRange))]
public class MinMaxRangeDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // 使用 PropertyScope 确保正确处理缩进和标签
        using (new EditorGUI.PropertyScope(position, label, property))
        {
            // 获取子属性
            SerializedProperty minProp = property.FindPropertyRelative("min");
            SerializedProperty maxProp = property.FindPropertyRelative("max");

            // 计算布局
            float sliderHeight = position.height * 0.5f;
            float labelHeight = position.height * 0.3f;

            // 滑动条区域
            Rect sliderRect = new Rect(position)
            {
                height = sliderHeight
            };

            // 数值显示区域
            Rect labelRect = new Rect(position)
            {
                y = position.y + sliderHeight,
                height = labelHeight
            };

            // 获取当前值
            float minValue = minProp.floatValue;
            float maxValue = maxProp.floatValue;

            // 检测修改
            EditorGUI.BeginChangeCheck();

            // 绘制双端滑动条
            EditorGUI.MinMaxSlider(
                sliderRect,
                ref minValue,
                ref maxValue,
                0f,
                100f
            );

            // 绘制数值标签
            EditorGUI.LabelField(labelRect, $"Min: {minValue:F1}", $"Max: {maxValue:F1}");

            // 如果有修改，更新属性值
            if (EditorGUI.EndChangeCheck())
            {
                minProp.floatValue = minValue;
                maxProp.floatValue = maxValue;
            }
        }
    }

    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        // 返回两倍默认高度
        return base.GetPropertyHeight(property, label) * 2f;
    }
}
```

### 4.3 使用示例

```csharp
using UnityEngine;

public class EnemySpawner : MonoBehaviour
{
    public MinMaxRange spawnInterval = new MinMaxRange(1f, 5f);
    public MinMaxRange enemyCount = new MinMaxRange(10, 50);
}
```

### 4.4 显示效果

```
┌────────────────────────────────────┐
│  Spawn Interval                    │
│  1 ─────●─────────────●──── 100   │
│     Min: 1.0      Max: 5.0        │
├────────────────────────────────────┤
│  Enemy Count                       │
│  10 ──●──────────────●──── 100     │
│     Min: 10.0     Max: 50.0       │
└────────────────────────────────────┘
```

---

## 五、完整示例：人员信息 PropertyDrawer

创建一个复杂的人员信息自定义显示。

### 5.1 定义数据结构

```csharp
using System;

/// <summary>
/// 性别枚举
/// </summary>
public enum Gender
{
    Male,
    Female
}

/// <summary>
/// 人员信息
/// </summary>
[Serializable]
public class PersonInfo
{
    public string name = "张三";
    public Gender gender = Gender.Male;
    public int age = 25;
    [TextArea(2, 4)]
    public string description = "这是描述信息";
}
```

### 5.2 创建自定义 PropertyDrawer

```csharp
using UnityEngine;
using UnityEditor;

/// <summary>
/// PersonInfo 的自定义 PropertyDrawer
/// </summary>
[CustomPropertyDrawer(typeof(PersonInfo))]
public class PersonInfoDrawer : PropertyDrawer
{
    // 定义各区域
    private Rect nameRect;
    private Rect genderRect;
    private Rect ageRect;
    private Rect descRect;

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // 使用 PropertyScope
        using (new EditorGUI.PropertyScope(position, label, property))
        {
            // 获取子属性
            SerializedProperty nameProp = property.FindPropertyRelative("name");
            SerializedProperty genderProp = property.FindPropertyRelative("gender");
            SerializedProperty ageProp = property.FindPropertyRelative("age");
            SerializedProperty descProp = property.FindPropertyRelative("description");

            // 计算布局
            float lineHeight = EditorGUIUtility.singleLineHeight;
            float spacing = EditorGUIUtility.standardVerticalSpacing;

            // 姓名区域（第一行）
            nameRect = new Rect(position.x, position.y, position.width, lineHeight);

            // 性别和年龄区域（第二行，左右分布）
            float halfWidth = position.width / 2f - spacing / 2f;
            genderRect = new Rect(position.x, position.y + lineHeight + spacing, halfWidth, lineHeight);
            ageRect = new Rect(position.x + halfWidth + spacing, position.y + lineHeight + spacing, halfWidth, lineHeight);

            // 描述区域（剩余部分）
            float descY = position.y + (lineHeight + spacing) * 2;
            float descHeight = position.height - (lineHeight + spacing) * 2;
            descRect = new Rect(position.x, descY, position.width, descHeight);

            // 绘制各属性
            EditorGUI.PropertyField(nameRect, nameProp, new GUIContent("姓名"));

            EditorGUI.PropertyField(genderRect, genderProp, new GUIContent("性别"));
            EditorGUI.PropertyField(ageRect, ageProp, new GUIContent("年龄"));

            EditorGUI.PropertyField(descRect, descProp, new GUIContent("描述"));
        }
    }

    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        // 返回高度：姓名行 + 性别年龄行 + 描述行
        int lines = 4;
        return EditorGUIUtility.singleLineHeight * lines +
               EditorGUIUtility.standardVerticalSpacing * (lines - 1);
    }
}
```

### 5.3 使用示例

```csharp
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public PersonInfo playerInfo = new PersonInfo();

    public PersonInfo[] npcList = new PersonInfo[0];
}
```

---

## 六、Editor 预览功能

`Editor` 类支持预览功能，可以在 Inspector 底部显示实时预览。

### 6.1 预览相关方法

| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `HasPreviewGUI()` | bool | 是否显示预览 |
| `GetPreviewTitle()` | GUIContent | 预览窗口标题 |
| `OnPreviewGUI()` | void | 绘制预览内容 |
| `OnPreviewSettings()` | void | 绘制预览工具栏 |

### 6.2 基本预览示例

```csharp
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Character))]
public class CharacterPreviewEditor : Editor
{
    // 是否显示预览
    public override bool HasPreviewGUI()
    {
        return true;
    }

    // 预览窗口标题
    public override GUIContent GetPreviewTitle()
    {
        return new GUIContent("角色预览");
    }

    // 绘制预览内容
    public override void OnPreviewGUI(Rect r, GUIStyle background)
    {
        // 绘制背景
        GUI.Box(r, "", background);

        // 绘制预览内容
        Character character = (Character)target;
        GUIStyle style = new GUIStyle(EditorStyles.boldLabel)
        {
            alignment = TextAnchor.MiddleCenter,
            fontSize = 20
        };

        EditorGUI.LabelField(r, $"攻击力: {character.attack}\n防御力: {character.defense}", style);
    }

    // 预览工具栏（可选）
    public override void OnPreviewSettings()
    {
        // 添加工具栏按钮
        GUILayout.Label("预览设置", EditorStyles.miniLabel);
    }
}
```

### 6.3 3D 预览示例（使用 PreviewRenderUtility）

```csharp
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MeshFilter))]
public class MeshPreviewEditor : Editor
{
    private PreviewRenderUtility previewUtility;
    private Mesh mesh;

    void OnEnable()
    {
        previewUtility = new PreviewRenderUtility(true);
        mesh = (target as MeshFilter).sharedMesh;
    }

    void OnDisable()
    {
        previewUtility.Cleanup();
    }

    public override bool HasPreviewGUI()
    {
        return mesh != null;
    }

    public override GUIContent GetPreviewTitle()
    {
        return new GUIContent("模型预览");
    }

    public override void OnPreviewGUI(Rect r, GUIStyle background)
    {
        previewUtility.BeginPreview(r, background);

        // 设置相机
        previewUtility.camera.transform.position = new Vector3(0, 0, -5);
        previewUtility.camera.transform.rotation = Quaternion.identity;
        previewUtility.camera.backgroundColor = new Color(0.5f, 0.5f, 0.5f);

        // 绘制网格
        if (mesh != null)
        {
            Graphics.DrawMesh(mesh, Vector3.zero, Quaternion.identity, previewUtility.material, 0);
        }

        // 渲染并显示
        previewUtility.EndPreview();
    }
}
```

---

## 七、CustomEditor 与 PropertyDrawer 对比

| 特性 | CustomEditor | PropertyDrawer |
|------|-------------|---------------|
| **作用范围** | 整个组件 | 单个类型 |
| **复用性** | 仅限目标组件 | 所有使用该类型的地方 |
| **使用场景** | 复杂组件的完整自定义 | 可复用类型的统一显示 |
| **继承基类** | `Editor` | `PropertyDrawer` |
| **必需方法** | `OnInspectorGUI()` | `OnGUI()`, `GetPropertyHeight()` |
| **预览支持** | ✅ 支持 | ❌ 不支持 |

> 💡 选择建议：
> - 需要完整自定义组件界面 → CustomEditor
> - 需要统一某个类型的显示方式 → PropertyDrawer
> - 两者可以结合使用

---

## 八、最佳实践

### 8.1 使用 SerializedObject

```csharp
// ✅ 推荐：使用 SerializedObject
serializedObject.Update();
EditorGUILayout.PropertyField(property);
serializedObject.ApplyModifiedProperties();

// ❌ 不推荐：直接修改目标对象
target.value = newValue;  // 无法撤销，无法处理多选
```

### 8.2 支持多对象编辑

```csharp
[CanEditMultipleObjects]  // 支持多选编辑
[CustomEditor(typeof(MyComponent))]
public class MyComponentEditor : Editor
{
    // 使用 serializedObject 自动处理多选
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        // 绘制代码...
        serializedObject.ApplyModifiedProperties();
    }
}
```

### 8.3 性能优化

```csharp
// 在 OnEnable 中缓存 SerializedProperty
private SerializedProperty cachedProperty;

void OnEnable()
{
    cachedProperty = serializedObject.FindProperty("propertyName");
}

// 避免在 OnInspectorGUI 中重复查找
```

---

## 九、总结

本文介绍了 Unity 编辑器自定义界面的两大核心技术：

| 主题 | 核心要点 |
|------|---------|
| **CustomEditor** | 控制整个组件的 Inspector 显示 |
| **PropertyDrawer** | 自定义类型的全局显示方式 |
| **SerializedObject** | 统一的序列化对象管理 |
| **预览功能** | HasPreviewGUI/OnPreviewGUI |
| **性能优化** | 缓存 SerializedProperty |

> 💡 **开发建议**：
> - 优先使用 SerializedObject 而非直接修改 target
> - PropertyDrawer 适合可复用的自定义类型
> - CustomEditor 适合复杂组件的完整自定义
> - 结合两者可实现更灵活的编辑器界面

下一篇将详细介绍 **EditorGUILayout 的布局控件**。

---

**转载请注明来源**，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

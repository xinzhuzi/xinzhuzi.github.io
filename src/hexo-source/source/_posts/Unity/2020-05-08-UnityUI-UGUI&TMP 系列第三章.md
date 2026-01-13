---
title: "Unity UI 系列第三章：RectTransform 与布局系统详解"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, UGUI, RectTransform, 锚点, 布局系统, UI适配]
image: /images/unity-ui-series-chapter3-banner.jpg
---

# 📐 Unity UI 系列第三章：RectTransform 与布局系统详解

> 💡 **布局系统的核心**：
> - RectTransform 和 Transform 有什么区别？
> - Anchors、Pivot 怎么设置才合理？
> - 如何实现多屏幕适配？
> - Layout Group 自动布局怎么用？
>
> **系列第三章**，深入讲解 RectTransform 和布局系统！

Sprite Atlas使用介绍初始化(环境)设置

- 图片需要切换成Sprite(2D and UI)，设置 Edit -> Project Settings -> Editor -> Sprite Packer-> Mode -> Sprite Atlas V2

- 设置 Edit -> Project Settings -> Editor -> Asset Serialization -> Mode -> Force Text.

新建SpriteAtlas文件,在 Project 视图中,右键Create/2D/Sprite Atlas(如果没有 2D 相关的,则需要从Package Manager里面下载)，
将Sprite或者Sprite所在文件夹拖入Objects for Packing，按下Pack Preview预览。

- 在预览里面如果有 #0 #1 #.. 表示有多张图生成,即使用时 DC 会多个,需要调节 Max Texture Size 大小,最好是将 Sprite Atlas 设置 1 张图片.

Sprite Atlas的目的是降低 Draw Call

Sprite Atlas 针对现有的图集打包系统Sprite Packer在性能和易用性上的不足，进行了全面改善。
除此之外，相比Sprite Packer，Sprite Atlas将对精灵更多的控制权交还给用户。
由用户来掌控图集的打包过程以及加载时机，更加利于对系统性能的控制。

当UI上使用的Sprite被打入图集中，*自动降低游戏的 Draw Call*，对于静态精灵来说，
只需要建立图集，把Sprite、Sliced Sprite、文件夹放入图集就达到效果。

- 请查看 HaveSpriteAtlas 与NoSpriteAtlas 的 Stats 性能窗口,里面的 Batches 属性可以简单的认为 Draw Call .

图集介绍

- SpriteAtlas 是一种图集资源,与 NGUI 中的 UIAtlas 是相似的,可以在检视窗口中设定要打包的精灵及其参数，例如图集的打包方式、输出贴图的压缩格式

- SpriteAtlas 添加时,支持单个Sprite、Sliced Sprite、文件夹，以及这些类型的任意组合。

- 在设置中,上面的属性尽量不要勾选,最好所有图集一种设置方式.在Preview 上面可以清晰的看到图集生成效果,可以根据效果判断打包方式是否合理,是否存在大量被浪费的空间.

添加图集Variant（变种）

所谓Variant，就是指原有图集的一个变种。它会复制原有图集的贴图，并根据一个比例系数来调整复制贴图的大小。这样的Variant通常用于为高分辨率和低分辨率的屏幕准备不同的图集。
因为如果只准备一套高分辨率的图集，在低分辨率的设备上占用内存过多。反之，如果只准备一套低分辨率图集，在高分辨率的设备上就会模糊。

运行时访问图集

Sprite Atlas作为一种资源开放给用户，支持在脚本中直接访问，还可以通过名字获取图集中的精灵。

using UnityEngine.U2D;
void Start()
{

     //第一种加载
     SpriteAtlas atlas = AssetDatabase.LoadAssetAtPath<SpriteAtlas>("Assets/SpriteAtlas/SpriteAtlas.spriteatlas");     
     Sprite sprite = atlas.GetSprite("111");
     if(sprite != null)
     {
        GetComponent<SpriteRenderer>().sprite = sprite;
     }

     //第二种加载
     SpriteAtlas sa =  Resources.Load<SpriteAtlas>("SpriteAtlas");
     Sprite sprite = atlas.GetSprite("111");

     //第三种加载
     SpriteAtlas sa = Object.Instantiate(AB.Load(tag.ToLower())) as SpriteAtlas;
     Sprite sprite = atlas.GetSprite("111");
}

```

图集属性作用

- Type: 主体和变体图集,变体是缩小的主体图集,所以我们设计 UI 的时候,尽量将最大的纹理设置成一个主体图集.

Include Build: 勾选时运行游戏时,如果 Prefab 对图集有引用关系,即 Image的 sprite 的赋值有图集中的图片,打包时会自动引用,
加载时,自动加载入内存中;如果想加载Prefab之前加载图集,就不能给 Image的 Spite 赋值,或者赋值了,但是不勾选此选项;
目前采用勾选此选项,并且将一个图集打成一个包的的模式进行加载.

- Allow Rotation 生成图集时,小图片可以旋转,这一项可以减小图集大小,减少图集空白面积,此方式不采用

- Tight Packing 紧密打包,选择这个的情况是不能获取图片中的小图的位置,此方式不采用

- Padding 小图与小图之间的距离

- Read/Write Enabled 不勾选,除非有特殊要求,例如动态图集

- Generate Mip Maps 不勾选

图集打包

图集在多个 UI Prefab 使用的情况下,需要单独打成一个包,目前我们只要制作图集,就将这个图集单纯制作一个 ab 包.
采取策略,每个图集都打成一个包.省事简单防错误.

Image 引用图集,打包时,会将这个图集的引用信息存入 AB 包里面,加载时只需要加载 UI Prefab 即可加载图集.
即不需要显示的加载 UI Prefab 的依赖,就可以展示图片,当然了,图集的 Include in Build 需要勾选.
当 Include in Build 不勾选的话,需要使用以下方法进行加载图集:

            SpriteAtlasManager.atlasRegistered += (SpriteAtlas spriteAtlas) =>
            {
                Debug.Log("Dosomething!" + spriteAtlas.name);
                Sprite sprite = spriteAtlas.GetSprite("1");
                testUI.transform.Find("Image").GetComponent<Image>().sprite = sprite;
            };
            SpriteAtlasManager.atlasRequested += (string tag, System.Action<SpriteAtlas> action) =>
            {
                SpriteAtlas sa = Object.Instantiate(AB.Load(tag.ToLower())) as SpriteAtlas;
                Debug.Log("tag:" + tag); //tag是SpriteAtlas资源的文件名称
                action(sa);
            };

```

选择方案勾选 Include in Build.即不用开发人员太过担心 AB 包的加载问题了.
使用 Image,引擎会自动加载图集.
使用扩展脚本 UISprite 加载策略(开发人员写的代码执行流程)是:先依赖加载图集,再加载 UI Prefab.最后加载成一个完整的 UI.

TexturePacker 的使用

- 图集打包,导入项目中,生成一个Texture 图片,导入项目中,这个图片的类型是 Sprite(2D and UI) mode 是Multiple.

- 即可使用这张图片分出的小图了.也是降低 Draw Call 的功用

- 目前不使用TexturePacker,原生的 UGUI 已经够用,并且使用 Image 自带的 Use Sprite Mesh 功效与TexturePacker功效一致

引用

- [https://docs.unity3d.com/cn/current/Manual/class-SpriteAtlas.html](https://docs.unity3d.com/cn/current/Manual/class-SpriteAtlas.html)

- [https://docs.unity3d.com/cn/current/ScriptReference/U2D.SpriteAtlas.html](https://docs.unity3d.com/cn/current/ScriptReference/U2D.SpriteAtlas.html)

图集属性选择模板![图集属性](/2021/08/12/UnityUI/UGUI&TMP%20%E7%B3%BB%E5%88%97%E7%AC%AC%E4%B8%89%E7%AB%A0/%E5%9B%BE%E9%9B%86%E5%B1%9E%E6%80%A7.png)

      
        转载请注明来源，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

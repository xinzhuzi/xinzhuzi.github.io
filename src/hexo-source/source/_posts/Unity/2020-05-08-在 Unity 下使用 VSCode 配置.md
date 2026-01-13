---
title: "Unity + VSCode 完美配置：Mac 开发环境搭建指南"
date: 2020/05/08
categories: [技术文章, Unity开发]
tags: [Unity, VSCode, Mac, 开发环境, 配置, Mono, .NET Core]
image: /images/unity-vscode-mac-setup-banner.jpg
---

# ⚡ Unity + VSCode 完美配置：Mac 开发环境搭建指南

> 💡 **想用 VSCode 高效开发 Unity 吗？**
> - Mac 上如何搭建 Unity 开发环境？
> - VSCode 需要安装哪些必备插件？
> - Mono 和 .NET Core 如何正确配置？
> - 如何提升 Unity 开发效率？
>
> **完整指南**！从零开始搭建 Mac 上的 Unity + VSCode 开发环境！

Mac 使用Visual Studio Code搭建unity开发环境##前置条件:

- 安装brew,[homebrew](https://brew.sh/)官网安装,然后安装openssl,.net core 需要1.0.1以上的版本,安装命令```
brew update
brew install openssl
```

- 下载 [Visual Studio Code](https://link.jianshu.com/?t=https%3A%2F%2Fcode.visualstudio.com)，解压后将其拖拽到launchpad中。

- 下载安装 [Mono](https://link.jianshu.com/?t=http%3A%2F%2Fwww.mono-project.com%2Fdownload%2F%23download-mac) 跨平台的 .NET 框架，也可以通过[Homebrew](https://link.jianshu.com/?t=https%3A%2F%2Fbrew.sh)的`brew install mono`下载安装。

- 安装[.Net core SDK](https://dotnet.microsoft.com/learn/dotnet/hello-world-tutorial/install).

VSCode插件安装,插件重复则最终检查安装即可

- unity3d-pack

- vscode-icons / Material Icon Theme.个人倾向于后一个

- vscode-solution-explorer

- Unity Tools

- Unity Code Snippets

- ShaderlabVSCode(Free)

- Shader languages support for VS Code

- luaide

- Debugger for Unity

- Chinese (Simplified) Language Pack for Visual Studio Code

- C# XML Documentation Comments

- C# Snippets

- C# FixFormat

- C#

- TypeLens 查看引用数量

- TODO Parser .Parse TODOs in your working files.

- Code Spell Checker

ILSpy .NET Decompiler,[使用方式](https://blog.csdn.net/s15100007883/article/details/91365007)
icsharpcode.ilspy-vscode.dll反编译工具

- Markdown Preview Enhanced

- vscode-proto3

- Open iTerm2

- vscode-pdf

- Draw.io

已经下载好的包,在/Users/用户名/.vscode/extensions 路径下将已经下载好的整套插件 [extensions](https://pan.baidu.com/s/1WM1Sjs3b8s4n8aXNm5OAkg)   密码:a6h4 文件夹替换,这个版本的omnisharp是1.34.3
如果你进行更新了,则会变的高.需要手动下载

手动下载omnisharp和debugger需要在路径/Users/用户名/.vscode/extensions/ms-vscode.csharp-1.21.4/package.json 这个文件里面找到omnisharp对应的版本以及debugger对应的版本,下载完毕之后解压到当前文件夹,最后需要生成空文件install.LOCK即可
最终效果:
![整个插件目录](https://upload-images.jianshu.io/upload_images/1480659-fcce1c2a1fd832cc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![debugger](https://upload-images.jianshu.io/upload_images/1480659-f2f73d182f35b020.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![omnisharp](https://upload-images.jianshu.io/upload_images/1480659-aaf2a0242585249e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![install.LOCK](https://upload-images.jianshu.io/upload_images/1480659-1a7f011d7c3e2635.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##在unity3d中集成VSCode

- 在AssetStore搜索VSCode并安装

- 自定义VSCode在unity中的配置

- 使用VSCode打开unity工程

出现的问题

omnisharp安装不上去,解决方案1:翻墙
解决方案2:手动安装,在github上面下载

- mono版本过多,[参考链接](https://github.com/OmniSharp/omnisharp-vscode/issues/1004)

- 启动不了omnisharp服务,去掉omnisharp设置里面的Omnisharp: Wait For Debugger选项.

#####小技巧:

- timeScale不影响Update和LateUpdate，会影响FixedUpdate。

- timeScale不影响Time.realtimeSinceStartup，会影响Time.timeSinceLevelLoad和Time.time。

- timeScale不影响Time.fixedDeltaTime和Time.unscaleDeltaTime，会影响Time.deltaTime。

- 当使用Time.deltaTime/Time.time/Time.timeSinceLevelLoad做的操作,可以使用 timeScale进行暂停和加速.

      
        转载请注明来源，欢迎对文章中的引用来源进行考证，欢迎指出任何有错误或不够清晰的表达。可以在下面评论区评论，也可以邮件至 1487842110@qq.com

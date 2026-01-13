---
title: "Protobuf 跨语言实战：Lua + Python + Unity 完整集成方案"
date: 2020/05/08
categories: [技术文章, 网络编程]
tags: [Protobuf, Lua, Python, Unity, ToLua, 网络通信, 数据序列化, 跨平台]
image: /images/protobuf-lua-python-integration-banner.jpg
---

# 🔧 Protobuf 跨语言实战：Lua + Python + Unity 完整集成方案

> 💡 **Protobuf 的价值**：
> - 客户端与服务器如何高效交换数据？
> - JSON 太慢、XML 太大，用什么序列化方案？
> - Lua、Python、Unity 如何统一数据格式？
> - Protobuf 如何在游戏项目中快速落地？
>
> **完整集成方案**！从环境搭建到代码生成，手把手实现 Protobuf 在多语言游戏项目中的应用！

---

protoc-gen-lua 最新版使用教程
- 老版的采用python2.7与protobuf2.5进行的数据创建 [https://blog.csdn.net/huutu/article/details/49672225](https://blog.csdn.net/huutu/article/details/49672225)
- 目前环境以及升级到了python3.8以及protobuf3.12进行生成.
- 1:下载protobuf3.12版本,到电脑任何地方,打开里面的python文件夹,安装python3.8的环境
- 2:下载 [https://github.com/sean-lin/protoc-gen-lua](https://github.com/sean-lin/protoc-gen-lua) 我们会修改里面的东西
- 2:三步走

```
    python setup.py install 查看是否正常
    python setup.py build 查看是否正常
    python setup.py test 查看是否正常

```
- 3:将 xxx\protobuf-3.12.0\python\google\protobuf
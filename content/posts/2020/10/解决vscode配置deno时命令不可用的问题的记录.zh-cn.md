---
title: "解决vscode配置deno时命令不可用的问题的记录"
date: 2020-10-18T17:43:16+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["deno", "deno._init_project"]
categories: ["deno"]
featuredImage: "https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
images: [""]
---

## 缘由

最近在用`vscode`写`deno`, 最佳拍档应该就是官方提供的插件了，但是使用插件需要对项目进行初始化(`deno:init`)，其实就是在项目根目录创建一个文件(.vscode/settings.json)， 然后在里面写入deno对该项目的配置。

在我刚开始写deno代码的时候，这个插件还是好的，但是参与到朋友的一个demo的时候就出问题了； 初始化：CMD+ Shift + P,`deno:init`, 然后右下角提示`deno._init_project`未找到，请重启vscode。然后不管怎么重启，即使把插件的源码下载下来编译运行都不行。最终只有重新安装大法了。然而，重装了还是不行。

## 解决方案

解决方案应该只能是将所有关于vscode的所有插件和配置都彻底删除重新安装才行。

### 删除插件

```shell
rm -rf ~/.vscode/extensions
```

### 删除系统缓存数据

```shell
rm -rf ~/Library/Application\ Support/Code
```

### 从应用程序中删除vscode

打开Mac 的应用程序管理文件夹，删除 `Visual Studio Code`

### 重新安装 vscode

直接下载安装包或者使用Homebrew

```shell
brew install visual-studio-code
```

### 安装 deno 插件

在vscode 的扩展中搜索并安装deno 插件。

## 测试

打开deno 相关的项目。CMD + Shift + P ， 输入 `deno：init`，应该不会再弹出命令找不到的错误提示了。

## Reference

* [博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [图床:https://sm.ms/](https://sm.ms/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)

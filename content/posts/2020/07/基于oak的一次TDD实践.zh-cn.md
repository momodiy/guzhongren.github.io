---
title: "基于oak的一次TDD实践"
date: 2020-07-24T22:21:11+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["deno", "oak", "tdd", "git", "mvc", "fetch"]
categories: ["deno"]
featuredImage: "https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
images: [""]
---

## 简介

Deno 是ry(Ryan Dahl)的新项目，近期发布了其 1.0.0 版，在开发圈子里掀起了不小的风浪，与之创建的 Node 运行时有异曲同工之妙，`真香定律`又一次出现了。

在软件开发中，为了开发出可维护，高质量的程序，使用`TDD`开发可以有效提升项目质量和开发效率。

## Deno & oak

下面都是来自官网的介绍，写的很通俗易懂，就不用我来解读了。

### Deno

> Deno 是一个简单、现代且安全的 JavaScript 和 TypeScript 运行时环境，其基于 V8 引擎并采用 Rust 编程语言构建。
> * 默认安全设置。除非 显式开启，否则没有文件、网络，也不能访问运行环境。
> * 天生支持 TypeScript。
> * 只有一个单一的可执行文件。
> * 自带实用工具，例如依赖检查器（deno info）和 代码格式化工具（deno fmt）。
> * 有一套经过审核（审计）的标准模块， 确保与 Deno 兼容： deno.land/std

### [oak](https://github.com/oakserver/oak)

> A middleware framework for Deno's net server 🦕

## 目标

基于对以上的基础知识的认识，我们计划开发一个用户管理的`API`平台；对于后端简单来说，就是提供关于用户的增删改查（`CURD`）操作。所以我们的目标就是提供4个对用户`CURD`的接口。

## 工具

> 工欲善其事，必先利其器。

### 开发工具

[`VS Code`](https://code.visualstudio.com/), [`Docker`](https://www.docker.com/)

### 环境工具

[`Deno`](https://deno.land/), [`Typescript`](https://www.typescriptlang.org/), [`Node`](https://nodejs.org/)

> 注： Node 是用来调试 Deno的

## 基础环境搭建

关于上面开发工具和环境工具的安装就不在这赘述了。

### 项目结构

```shell
❯ tree -L 1 web-api-based-deno
web-api-based-deno
├── .github         // github action
├── .vscode         // debug 及 vscode 配置文件
├── LICENSE         // 仓库许可
├── README.md       // 项目说明，包括数据库连接，简化后的运行命令等
├── _resources      // 基础资源
│   ├── IaaS        // 基础设施，docker-compose 启动postgresql
│   ├── httpClient  // http请求测试
│   └── migration   // 负责生成数据库表
├── deps.ts         // 项目依赖的库及项目中要用到的资源（import）
├── lock.json       // 完整性检查与锁定文件, 参考：https://nugine.github.io/deno-manual-cn/linking_to_external_code/integrity_checking.html
├── makefile        // 将开发需要的命令行简化后目录
├── src             // 源代码目录
└── tests           // 测试目录

5 directories, 5 files

```

## 实现过程

## 乱中取整


## Reference

* [web-api-based-deno: https://github.com/guzhongren/web-api-based-deno](https://github.com/guzhongren/web-api-based-deno)
* [博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [图床:https://sm.ms/](https://sm.ms/)
* [Denoland: https://deno.land/](https://deno.land/)
* [VS Code: https://code.visualstudio.com/](https://code.visualstudio.com/)
* [Docker: https://www.docker.com/](https://www.docker.com/)
* [Typescript: https://www.typescriptlang.org/](https://www.typescriptlang.org/)
* [Node: https://nodejs.org/](https://nodejs.org/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)

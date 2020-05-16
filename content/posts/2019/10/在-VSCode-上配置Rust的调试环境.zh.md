---
title: "在 VSCode 上配置Rust的调试环境"
date: 2019-10-17T20:50:05+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["Rust", "Debug", "VS", "Code"]
categories: ["tool"]
featuredImage: ""
---

![Photo by Jan Kopřiva from Pexels](https://images.pexels.com/photos/3858142/pexels-photo-3858142.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260)

## 插件

在 VS Code 上进行 Rust 的开发，需要使用一下两个库
* RLS(vscode搜索插件rls)
* lldb(vscode搜索插件codelldb)

安装很简单，不用说

## 配置

```json
{
  // 使用 IntelliSense 了解相关属性。 
  // 悬停以查看现有属性的描述。
  // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug executable 'show_posts'", // 配置名称，将会在调试配置下拉列表中显示
      "type": "lldb", // 调试器类型：Windows表示器使用cppvsdbg；GDB和LLDB使用cppdbg。该值自动生成
      "request": "launch", // 调试方式
      "cargo": { // 运行的参数
        "args": [
          "build",
          "--bin=show_posts",
          "--package=diesel_demo"
        ],
        "filter": {
          "name": "show_posts",
          "kind": "bin"
        }
      },
      "args": [], // 传递给程序的参数，没有参数留空即可
      "cwd": "${workspaceFolder}" // 调试程序时的工作目录
    },
}
```

![launch.json](https://yqfile.alicdn.com/418ec9989800421ab7ab8d03aa79b3ebde85e77d.png)

## 调试

![Debug](https://yqfile.alicdn.com/17e76c562003f3128f02282c4751f9d77584dd9f.png)




## Reference

[1.https://guzhongren.github.io/](https://guzhongren.github.io/)

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)
---
title: "调试bash"
date: 2020-04-06T23:09:54+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["shell", "sh","debug","调试","dry run", "coding", "sh"]
categories: ["Shell"]
featuredImage: "https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
---

最近在做 DevOps 的工作，主要是做一个蓝绿部署的方案，在这部分中涉及到了写 shell， Shell 作为一种程序语言，那么对于开发人员肯定是要在部署到正式或者生产环境前进行调试的，在 coding 过程中，发现 shell 的调试其实和平时写的 JS, Java, Rust 等的调试不同，Shell 只能看你每一步执行的语句，至于具体执行是否正确，得由 coding 的人来写正确；好吧，有点难理解，那么我来举个🌰；

## 举例

有如下代码

```shell
#!/bin/bash

set -eu

readonly FIRST_VALUE="first value"

echo "你会得到替换后的值：${FIRST_VALUE}

```

脚本很简单，简单一句话，定义了一个变量`FIRST_VALUE`， 然后用`echo`输出，在输出的时候应用了刚才定义的变量`FIRST_VALUE`，赋予执行权限后，如果执行`./run.sh`之后，只会在终端输出

```shell
你会得到替换后的值：first value
```
但是在简单的脚本中还可以直接运行，如果运行一个复杂的脚本，那么出问题了的几率击溃比较高了，那么调试脚本积极非常重要了。

## debug

shell 的调试说来也非常简单，直接运行`sh -x ...`就可以了，对于本脚本我们执行如下：

```shell
sh -x run.sh
```

会得到输出，如下：

```shell

+ set -eu
+ readonly 'FIRST_VALUE=first value'
+ FIRST_VALUE='first value'
+ echo '你会得到替换后的值：first value'
你会得到替换后的值：first value
```

在这里面，你会看到每条 shell 脚本运行的具体命令，以及参数等内容，这条命令也是一种执行，会对命令涉及的内容产生实际效果，不要以为知识`dry run`。

## 总结

> 好习惯都是踩坑踩出来的

## Reference

* [1.博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [2.图床:https://sm.ms/](https://sm.ms/)
* [3.编写可靠bash脚本的一些技巧:https://mp.weixin.qq.com/s/VmM_U4RefRBHwIw8NegC8Q](https://mp.weixin.qq.com/s/VmM_U4RefRBHwIw8NegC8Q)
*

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)

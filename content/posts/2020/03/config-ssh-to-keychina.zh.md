---
title: "Config ssh to Keychina"
date: 2020-01-22T15:07:49+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["ssh", "keychain", "linux", "ssh-add"]
categories: ["tool"]
hiddenFromHomePage: false

featuredImage: ""
featuredImagePreview: ""

toc: true
autoCollapseToc: true
math: true
comment: true
---

![Photo by Marco Trinidad from Pexels](https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260)

## 将生成的ssh 私钥添加到 Mac 的keychain 中

```shell
$ ssh-add -K .ssh/is_rsa
```
## 将登录信息配置到.ssh/config中

```shell
$ touch ~/.ssh/config
$ vim ~/.ssh/config
# edit text
Host myvm
  Hostname ip
  User user
```

## 保存之后就可以使用如下命令快捷登录服务器了

```
$ ssh myvm
```

## 参考地址

<https://blog.infox.ren/2019/10/24/ssh-guide/>




## Reference

[1.## 将生成的ssh 私钥添加到 Mac 的keychain 中

```shell
$ ssh-add -K .ssh/is_rsa
```
## 将登录信息配置到.ssh/config中

```shell
$ touch ~/.ssh/config
$ vim ~/.ssh/config
# edit text
Host myvm
  Hostname ip
  User user
```

## 保存之后就可以使用如下命令快捷登录服务器了

```
$ ssh myvm
```

## 参考地址

[1. https://blog.infox.ren/2019/10/24/ssh-guide/](https://blog.infox.ren/2019/10/24/ssh-guide/)

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)
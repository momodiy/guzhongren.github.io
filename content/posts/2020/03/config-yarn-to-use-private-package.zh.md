---
title: "Config Yarn to Use Private Package"
date: 2020-03-05T22:45:03+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["yarn", "npm", ".npmrc","private package"]
categories: ["tool"]
---

![Photo by Jeffrey Czum from Pexels](https://images.pexels.com/photos/3750893/pexels-photo-3750893.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260)

## 场景

在公网上我们获取 npm 包的时候直接就用下面的命令就可以了

```shell
$ npm install xxx
$ # 或者
# yarn add xxx
```
但是有时候，公司内部开发的工具库只想放在公司内部的服务器上，那么我们就需要对 npm 源进行配置了。因为 yarn 可以利用缓存，其速度比较快，且 npm 包是公司内部网络，鉴于效率，我们采用 yarn 来提速。

## 配置.npmrc

下面是 .npmrc 的通常配置， 这里的 `https://npm.xxx.com/npm` 就是私服的地址， 下面`//`开头的内容就是用来鉴权的token。
```shell
# .npmrc
registry=https://npm.xxx.com/npm
//npm.xxx.com/npm/:_authToken=dbef52be-1a83-46e1-a3ce-e0c8727e3fa4
```
上面的配置，在用 npm 安装私有库或者公有库的时候都没问题，但是我们要使用 yarn，如果再不配置任何内容，在执行 `yarn add xxx` 的时候，控制台会报如下错误

```shell
yarn global v1.22.0
[1/4] 🔍  Resolving packages...
error An unexpected error occurred: "https://npm.xxx.com/npm/yyy: authentication required".
info If you think this is a bug, please open a bug report with the information provided in "/Users/zhongren.gu/.config/yarn/global/yarn-error.log".
info Visit https://yarnpkg.com/en/docs/cli/global for documentation about this command.
```
这其实不是 `yarn` 的 bug, 我们需要在 .npmrc 中增加如下一行 `always-auth=true`, 最终结果如下

```shell
# .npmrc
registry=https://npm.xxx.com/npm
//npm.xxx.com/npm/:_authToken=dbef52be-1a83-46e1-a3ce-e0c8727e3fa4
always-auth=true
```

## 结果

再次执行 `yarn add xxx` 之后就会正常安装了，以后就可以愉快的安装私服或者公网上的 package 了。



## Reference

[1.https://yarnpkg.com/](https://yarnpkg.com/)

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)
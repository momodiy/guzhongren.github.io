---
title: "最近我是DevOps"
date: 2020-09-22T19:46:57+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["DevOps"]
categories: ["AWS", "Shell", "Python","Buildkite", "DevOps", "Cloudformation", "subprocess"]
featuredImage: "https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
images: [""]
---

最近，在做项目中的DevOps，主要工作是备份，恢复并且更新 `Parameter Store`， 即`Config as Code`; 由于使用`AWS的服务`，可靠性还是由很多个9来保证的，但是在后期就会由很多问题；

* Team 创建了多少资源
* 都有哪些资源
* 怎么确定某一资源是 Team 项目中要用的
* 如果 AWS 服务不稳定直接挂了，或者创建的资源被team 成员不小心删除了，怎么办
* 如果要更新，我不想登录AWS Console 或者使用 CLI 来一个个的更新，那怎么办
* ......

对于以上问题，除了`as code` 还有什么好的方法么？如果有请告诉我。

接下来，我来简单说说我们项目的实践。在这个过程中遇到各种坑，但还是很有收获的。

在这先列个目录，主要罗列涉及到的服务,语言或者功能

* `AWS Parameter Store`, `KMS`, `cfn(Cloudformation)`
* `Shell`
* `Python`
* 加解密
* MD5

由于项目敏感性，在这就简单说说功能；项目中使用到 `AWS Parameter Store` 作为存储敏感数据的服务，而且所有的数据都是`SecurityString`(这种类型很重要，后面有坑)，在每次项目部署或某些功能运行的时候需要使用其中的值，由于是经过 `KMS`加密的,要做备份和更新那么就需要调用`AWS`的服务或者`CLI`。

## 第一步 备份

第一步，在恢复数据之前，先要获取原有的数据，并将其存储为原始数据。 获取数据倒是不难，写个 shell 直接调用 `AWS CLI`，将获取到的数据存在文本文件里即可。可以参考官网[AWS CLI Get-Parameter by Path]()

## 第二步 恢复

恢复，简单想一下就是将备份的数据执行命令，一条一条的插入就可以，然而，你这么想你就是小孩子了。原因自己体会。在这说说我做的过程。

首先将所有的数据分类，分为`敏感数据`和`非敏感数据`，对于非敏感的数据我们直接将其存储为明文，对于非敏感的数据，我们需要在本地就行加密为密文，保存起来。然后通过读取敏感数据和非敏感数据，将其恢复即可。

在这就遇到了第一个坑。

如果使用 `cfn`, 创建两个 `cfn`, 一个用来存储敏感数据，一个用来存储非敏感数据，然后通过 `cfn` 来对所有的数据进行统一管控。想象是美好的。当我将所有的数据都分好类，建好 cfn 模版，将一个一个的数据填上去，准备修改数据类型为 `SecurityString`的时候发现，文档上大大的写着，`SecurityString` 不支持 cfn ！`SecurityString` 不支持 cfn ！`SecurityString` 不支持 cfn ！

想象是美好的，现实是骨感的。

既然不支持cfn，那么只能想其他办法了；要么用支持的语言包，要么用CLI, 貌似已经没有其他办法 as code了。

### 语言包

因为做数据备份的项目是一个 DevOps 项目，所有的基础设施都是在这个项目中声明的，所以要使用 AWS 的 Java, Python 扩展包有点重，不合适。那么就剩下 CLI 这条路了。

### CLI

在写代码之前，我先将数据重新整理成了 `yaml` 格式，毕竟比 `JSON` 好用(可以写注释)。格式大致如下

```yaml
parameter:
  appName:
    - customKey: customKey
      value: value
````

作为恢复更新脚本，肯定是在 pipeline 运行的时候执行的，所以第一想法就是使用 `shell`; 想到就直撸起袖子直接干呗。写啊写，虽然网上也有写好的 `shell` 来处理 `yaml`,将读取结果 `export` 到环境变量中,比如 `parameter_appName__customKey`，但是问题是，那么多 `parameter store`, 我怎么一个一个的找到对应的数据的键和值呢？

此路不通，那么立马换方案，使用 `grep`, `awk`,`Regex`进行匹配转换，终于所有的数据(key， value)对应上了，大致数据结构如下 `parameter_appName__customKey=123`; 然后就是对数据（key, value）进行循环处理了呗。

请注意，处理后的数据里有这么一种数据结构： `parameter_app__key=test 1231`; 当循环value 到 `test 1231` 的时候，`shell` `list` 是以空格为分隔符的； 那么，就会造成 key 和 value 的长度不一致的问题，那么你的数据最终也会是错的。这个问题基本无解。所以此路又不通了。

考虑再三， `Python` 解析 `YAML` 需要安装第三方库，很不方便，但解析 `JSON` 很方便。在同事的帮助下，测试了 `pipeline` 是支持 `python` 的, 又因为如果使用 `AWS` 的 Python 扩展包，需要额外安装依赖，所以直接考虑 `Python` 调用 `Shell`;

#### Py 玩 Shell

综合以上因素，将 `YAML`格式的数据转换为 `JSON`, 由 `Python` 解析 `JSON`, 然后循环数据，循环过程中使用 `subprocess` 调用 `shell`, 在 `shell`中调用 AWS CLI 命令即可将数据更新上去或者执行解密操作等。 调用示例代码如下；

```python
subprocess.
```

在这需要重点说明一下的是，如果 `subprocess`调用的 `shell`是执行 `docker`命令，那么一定要在你要执行 `subprocess.run(['docker-compose', 'run', '-T', '-rm', 'shush', value])`这类命令前确保你已经拉取了 `shush` 涉及的镜像， 否则你第一次运行的输出结果里会有拉取镜像的日志。解决办法是在脚本真正运行之前获取镜像，可以使用如下密令

```Shell
docker-compose pull shush
````

## 总结

* 对于外部调用的 `Shell` 一定要写 `Usage`，也就是用户调用你的脚本的时候，如果出错，因该显示 `help` 信息
* 不要给可执行的脚本加 `.sh` ，`.py ` 等后缀，只需要给其可执行权限即可
* `cfn` 不支持 `SecurityString`
* `shush` 是个好工具, 有 `Docker` 镜像，只要你的机器上有 `Docker`, 你就可以不用通过命令行安装它， 执行 `docker` 命令即可拿到结果；但需要注意的是：执行某个命令之前，需要先将镜像拉下来，不然第一次计算的结果中会有拉取镜像的日志。


## Reference

* [博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [图床:https://sm.ms/](https://sm.ms/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)

# Npm 安装git资源

## 引言

我们大多数情况下用到的包都是存放在 [npmjs.com](https://www.npmjs.com/) 这个网站上的，只要我们安装了Node，我们就可以使用Node自带的npm包来下载你需要的包; 但有时候我们想让我们自己的包或者库私有，哪怎么办呢？很多人就会想到自己搭一个私服，比如[Nexus Repository Manager ](https://oss.sonatype.org/#Documentation)和 [sinopia](https://github.com/rlidwka/sinopia);　虽然搭建起来不是很困难，尤其是sinopia就是一个npm包，安装灰常简单，但是都需要一台服务器，一台服务... 一台服... 一台... 一...

现在大多数公司肯定有自己的git仓库了，[没有到git？说明你们技术太XXX落后]那么我们何不利用git仓库来存放我们的各种lib呢？

## 传统方式
> 前事不忘，后事之师。先来复习一下怎么从npmjs.com获取包。[这句是我说的]

```shell
$ npm install XXX
...
```

## git仓库

假如你已经做了一个特别牛逼的库，但是因为只是公司内部使用，比如一些工具库，放出去比如放到npmjs.com上没任何意义的，你可以把这个库整理成一个git的repo,当然打个标签，发个各版本什么的那就更好了。当你把你牛逼的库放在你司的git上后，比如地址是 ***ssh:git.niubi.com/yourName/niubility.git***　或者　***https://git.niubi.com/yourName/niubility.git***, 接下来就是发大招。

## 大招

```shell
$ npm install git+ssh:git.niubi.com/yourName/niubility.git
...
**#或者**
$ npm install git+https://git.niubi.com/yourName/niubility.git
...

```

## 隐藏技能[不推荐]

### 用户名方式

如果你将 npm 注册到自己的git仓库，就可以直接省去域名等一切能定位到该lib的的通用信息。

#### 注册及登录

```shell
$ npm adduser --registry http://you.domain.com
...
$ npm login --registry http://you.domain.com
...
```

#### 安装

```shell
$ npm install yourName/niubility
...
```

## 恩，没什么可说的了我真是来测试打赏功能的。



## Reference

* [1.博客：https://guzhongren.github.io/](https://guzhongren.github.io/)
* [2.图床：https://sm.ms/](https://sm.ms/)
* [3.原文：https://yq.aliyun.com/articles/655108?spm=a2c4e.11155435.0.0.3c783312bi9tbU](https://yq.aliyun.com/articles/655108?spm=a2c4e.11155435.0.0.3c783312bi9tbU)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)


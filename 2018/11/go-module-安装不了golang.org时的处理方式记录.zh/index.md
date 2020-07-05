# Go Module 安装不了golang.org时的处理方式记录



```shell
go: golang.org/x/sys@v0.0.0-20180905080454-ebe1bf3edb33: unrecognized import path "golang.orgnrecognized import path "golang.org/x/sys" (https fetch: G1: dial tcp 216.239.37.1:443: conneet https://golang.org/x/sys?go-get=1: dial tcp 216.239.37.rty did not properly respond after1:443: connectex: A connection attempt failed because the  connected host has failed to respoconnected party did not properly respond after a period of time, or established connection failed because connected : unrecognized import path "golang.host has failed to respond.)
...
go: golang.org/x/crypto@v0.0.0-20180904163835-0709b304e793nected party did not properly respo: unrecognized import path "golang.org/x/crypto" (https fed because connected host has failedtch: Get https://golang.org/x/crypto?go-get=1: dial tcp 216.239.37.1:443: connectex: A connection attempt failed because the connected party did not properly respond after a
period of time, or established connection failed because connected host has failed to respond.)
go: error loading module requirements
```


## 如上，不能安装sys和crypto这两个库，用如下方式即可
1手动加入被墙的包（原始包），一定要记住版本号，实在不知道的话，就试试v0.0.0；

```shell
$ go mod edit -require=golang.org/x/net@v0.0.0

```

2 用github上的镜像地址替换

```shell
$ go mod edit -replace=golang.org/x/crypto@v0.0.0=github.com/golang/crypto@latest

$ go mod edit -replace=golang.org/x/sys@v0.0.0=github.com/golang/sys@latest
```




## Reference

* [1.博客：https://guzhongren.github.io/](https://guzhongren.github.io/)
* [2.图床：https://sm.ms/](https://sm.ms/)
* [3.原文：https://yq.aliyun.com/articles/663151?spm=a2c4e.11155435.0.0.3c783312bi9tbU](https://yq.aliyun.com/articles/663151?spm=a2c4e.11155435.0.0.3c783312bi9tbU)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)


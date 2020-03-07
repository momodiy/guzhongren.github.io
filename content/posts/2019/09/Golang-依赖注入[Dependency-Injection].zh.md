---
title: "Golang 依赖注入(Dependency Injection)"
date: 2019-09-10T10:52:24+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["golang", "Dependency Injection", "DI", "test", "TDD", "Fprintf", "io.Writer"]
categories: ["Golang"]
hiddenFromHomePage: false

featuredImage: "https://golang.google.cn/lib/godoc/images/footer-gopher.jpg"
featuredImagePreview: "https://golang.google.cn/lib/godoc/images/go-logo-blue.svg"

toc: true
autoCollapseToc: true
math: true
comment: true
---

# Dependency Injection 🧪

依赖注入是目前很多优秀框架都在使用的一个设计模式。
Dependency Injection 常常简称为：DI。它是实现控制反转（Inversion of Control – IoC）的一个模式。

在各种大工程中少不了各种测试，其中 TDD 就是非常流行的一种，在前端开发中用的比较多的 [Jest](https://github.com/facebook/jest) 就是一种，在 Golang 开发命令行工具的时候也是需要 DI 这种模式来实现命令行测试的。因为传统的测试室获取不到命令行的输入输出的。

## 工程意图

仓库：<https://github.com/guzhongren/TDD/tree/master/10.dependency-injection>
编写一个命令行工具库，打包并运行程序，根据工具名称后面的名称来显示 `'Hello, + 名称'`。

## 简化程序

我们知道 golang 打包后就是一个可执行程序，程序名称根据你指定的名称显示，那么要实现这个工具就是需要接收到程序名后面的参数并显示出来。但本次的重点是实现 DI, 所以我们将重点放在命令行的测试与实现上。
我们只实现 Greet 函数的 DI 就可以了。

## 初始化工程

```shell
go mod init dependency-injection
```

按照惯例，测试的函数需要以 Test 开头，参数为 *testing.T 类型

## Test

* 测试先行

```go
func TestGreet(t *testing.T) {
	// 申明 buffer，准备接受数据， 因为bytes.Buffer， 重点：bytes.Buffer实现了 io.Writer
	buffer := bytes.Buffer{}
	// 将buffer 传入，此时就是依赖注入的入口，
	Greet(&buffer, "chris")
	// 获取程序运行的结果
	got := buffer.String()
	// 期望值
	want := "Hello, chris"
	// 测试判断
	if got != want {
		t.Errorf(`got %s, want %s`, got, want)
	}
}
```
* 运行 **go test**, 程序会报错，因为没有实现 Greet 函数。

* 最小化的实现 Repeat

```go
// Greet 打印问候
func Greet(w io.Writer, name string) {
	fmt.Fprintf(w, "Hello, "+name)
}
```
重点说明，命令行的测试需要将结果打印在命令行窗口中，如果没有测试，我们可以用 fmt.Printf 等打印函数将结果打印出来，但是，
测试需要拿到打印的内容，就需要将内容用标准输出；当然可以变相的先用其他打印函数将结果打印出来，然后再将结果 return 出去，
在测试中，接受返回值，再比较；这样做不标准而已，学了今天内容其实就可以用 DI 来解决了。


## 运行测试

* 基本测试

```shell
$ go test
PASS
ok      dependency-injection    0.006s
```

## 总结

基本测试很简单，不用解读了。作为开发者，我们应该用最直接的工具来保证我们程序的健壮性，而不一定要绕个弯来解决问题，如上面的打印结果的测试。


## Reference

[1.https://golang.google.cn/](https://golang.google.cn/)

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)
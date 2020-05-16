---
title: "Rust Doc小记"
date: 2020-04-16T22:56:55+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["Rust", "doc", "comment", "rust docs --open", "lib", "tips"]
categories: ["Rust"]
featuredImage: "https://i.loli.net/2020/04/16/nBq8Zc2u3IV7Pmf.jpg"
---

## 前言

学习Rust肯定离不开查看其官方或者第三方开发者的文档，而在Rust 的crate中，对于开发者或者使用者，文档是非常友好的。在这就不举例了。本文主要是记录一下写rust doc的一些小步骤。方便日后查阅。

## 示例

### 生成项目

```shell
$ cargo new mylib --lib

````

### 编写lib.rs中的实现

```rust

pub fn add_one(x: i32) -> i32 {
		x + 1
}

```

### 为 add_one 添加注释

最终效果如下：

```rust
//! My Crate name
//!
//! `my_crate_name` is test for studying
/// Add one for the number given
///
/// #Example
///
/// ```rust
///let five = 5
///assert_eq!(6, rust_study::add_one(five));
/// ```
///
pub fn add_one(x: i32) -> i32 {
    x + 1
}

```

### 生成rust 标准文档并查看

```shell
$ cargo doc --open
```

执行如上命令，cargo会根据注释生成web网页文档，并且自动打开，如下是上面文档生成的结果。

![rust-doc.jpg](https://i.loli.net/2020/04/16/nBq8Zc2u3IV7Pmf.jpg)

![rust-doc-fn.jpg](https://i.loli.net/2020/04/16/mQ2W6hcNwv39Tb4.jpg)

## 总结

* Rust 中写的注释代码，可以用来做方法示例，或者当作测试，如果是测试，运行`cargo test`	, cargo	不仅会测试tests文件夹下的测试案例，还会寻找注释中的测试。
* 什么时候写注释呢？优秀的程序员总是强调方法名即注释等。但有不确定的时候就得写注释啦。
	*	在rust中，在程序会panic的时候需要写注释告诉调用者可能panic的方法
	*	返回值是Result类型的时候，需要告诉调用者，Ok 和 Err的数据会是什么

Rust 的编译器相当严谨，结合TDD 写代码应该会很爽。


## Reference

* [1.博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [2.图床:https://sm.ms/](https://sm.ms/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)

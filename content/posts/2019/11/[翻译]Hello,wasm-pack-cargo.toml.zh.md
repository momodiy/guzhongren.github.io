---
title: "[翻译]Hello,wasm Pack Cargo.toml"
date: 2019-11-27T23:23:36+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["Web", "wams", "webAssembly", "rust"]
categories: ["Web"]
hiddenFromHomePage: false

featuredImage: ""
featuredImagePreview: ""

toc: true
autoCollapseToc: true
math: true
comment: true
---

![Photo by La Miko from Pexels](https://images.pexels.com/photos/3681653/pexels-photo-3681653.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260)

## Cargo.toml

`cargo.toml`是Rust 包管理器 `cargo` 的清单文件。这个文件包 `name`、 `version` 和包的依赖，在 Rust 中，我们一般称之为 `crate`。

在示例中给出了一系列信息，但是我们主要讨论如下三点：
- `crate-type`
- `wasm-bindgen` 依赖
- `[features]` 和 `wee_alloc`、`console_error_panic_hook` 依赖

### 1.`crate-type`

```toml
[lib]
crate-type = ["cdylib", "rlib"]
```

`Rust-wasm` 包与通常的 `crate` 有一点不同，作为 WebAssembly 项目， 我们需要在 `cargo.toml` 中加入该说明。

如果你熟悉其他的 Rust crate，那么你肯定知道，大多的 crate 的类型是 `rlib`(默认)， 或者是二进制形式的 `bin`(这种形式不需要 `crate-type` 注解), 并且 `[lib]` 注解在普通的 `Cargo` 项目中并不需要指定。

crate-type = ["cdylib"] 指示你的工程将会被编译为动态系统库 [dynamic system library], 但是对于 WebAssembly，他将会编译为一个没有启动函数的 .wasm 文件，在 Linux 平台上，他将会创建*.so 文件，在macOS 上将会创建*.dylib文件，在 windows 平台上将会创建 *.dylib 文件。

我们通常指定 `crate-type = ["rlib"]` 来确保我们的库可以用 wasm-pack 来做单元测试（稍后会看到）。如果没有这个配置，我们将不能测试我们的库，因为 cdylib 包类型和 wasm-pack 的单元测试类型相冲突。

你可以使用此[链接](https://doc.rust-lang.org/reference/linkage.html)获取更多关于包类型的知识。

### 2. wasm-bindgen 依赖

wasm-bindgen 在WebAssembly 中是一个重要的依赖。 这个包允许我们使用 `[wasm-bindgen]` 为在 JavaScript 和 Rust 生成的 wasm 之间的代码打标签。以使我们使用它的属性可以导入 JS 并且导出 Rust。

```toml
wasm-bindgen = "0.2"
```
当我们讨论 lib.rs 生成什么内容的时候，将会看到更多关于怎么使用这个库。
如果你从 JavaScript 技术栈过来，你可能注意到了当我们添加依赖的时候并没有加 `^` 或者 `~` ,看起来像是我们只要 `0.2` 这个版本。然而，事实并非如此！在 Rust 里， `^` 是默认的，你可使用这个 [链接](https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html)查看更多信息

### 3. [features] 和 wee_alloc, console_error_panic_hook dependencies

作为我们设计模板的工作的一部分，该模板可帮助人们发现针对特定用例的有用包，该模板包括两个依赖项，这对于开发Rust-wasm包的人们可能非常有用：console_error_panic_hook 和 wee_alloc。

因为这些依赖关系主要在 Rust-wasm 包开发工作流程的特定部分中有用，所以我们还设置了一些粘合代码，使我们既可以将它们都包含为依赖关系，又可以选择将它们包含在内。

```toml
[features]
default = ["console_error_panic_hook"]

[dependencies]
wasm-bindgen = "0.2"

# The `console_error_panic_hook` crate provides better debugging of panics by
# logging them with `console.error`. This is great for development, but requires
# all the `std::fmt` and `std::panicking` infrastructure, so isn't great for
# code size when deploying.
console_error_panic_hook = { version = "0.1.1", optional = true }

# `wee_alloc` is a tiny allocator for wasm that is only ~1K in code size
# compared to the default allocator's ~10K. It is slower than the default
# allocator, however.
#
# Unfortunately, `wee_alloc` requires nightly Rust when targeting wasm for now.
wee_alloc = { version = "0.4.2", optional = true }
```

在我们的代码中，只有在启用某些 [features] 的情况下，我们才会将代码的某些部分标记为正在运行，特别是 console_error_panic_hook 和 wee_alloc。默认情况下，仅启用 console_error_panic_hook。要禁用或启用任一功能，默认情况下，我们可以在 [features] 下编辑 default 数组。

要了解有关这些功能的更多信息，我们将在 src/lib.rs 和 src/utils.rs 部分中深入讨论它们。
 简要地，它们包括：
 * console_error_panic_hook ，用于将奔溃消息记录到开发人员控制台的功能。
 * wee_alloc，一个使代码量更小而优化的分配器。



## Reference

[1.https://guzhongren.github.io/](https://guzhongren.github.io/)

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)
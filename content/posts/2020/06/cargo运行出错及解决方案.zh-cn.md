---
title: "Cargo运行出错及解决方案"
date: 2020-06-06T11:03:11+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["rust", "nightly", "cargo", "rustup", "-Zprofile"]
categories: ["Rust"]
featuredImage: "https://images.unsplash.com/photo-1591414855728-7e70d9a7b4e0?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1267&q=80"
images: [""]
---
## 问题

```shell
❯ cargo run
error: failed to run `rustc` to learn about target-specific information

Caused by:
  process didn't exit successfully: `rustc - --crate-name ___ --print=file-names -Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort --crate-type bin --crate-type rlib --crate-type dylib --crate-type cdylib --crate-type staticlib --crate-type proc-macro --print=sysroot --print=cfg` (exit code: 1)
--- stderr
error: the option `Z` is only accepted on the nightly compiler`
```

最近更新了`rust`, 然后运行`cargo run`, 莫名其妙的出现了上面的问题。

## 原因

在 rust 官网的 issue 里找解决方案，都是open 状态的，没有实际意义。那么就得回到原始方式。
按照提示，说`Z` 这个参数仅适用于`nightly`版本的 rust 编译器，但是我用的是`stable`版本的rust;

```shell
❯ rustup show
Default host: x86_64-apple-darwin
rustup home:  /Users/c4/.rustup

stable-x86_64-apple-darwin (default)
rustc 1.44.0 (49cae5576 2020-06-01)

```
版本确定，那么只能将语音归结到命令行某个地方有注入参数。第一个想到的就是环境变量，打开我的`~/.zshrc`, 果然在最下面找到了这么一条记录, 看到`-Z`, 应该就是他了。

```shell
export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
```

## 解决方案

删除该行记录，运行程序，成功输出`hello world`。


## Reference

* [1.博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [2.图床:https://sm.ms/](https://sm.ms/)
* [3. grcov](https://github.com/mozilla/grcov/issues/433)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)

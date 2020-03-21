---
title: "Practise With Apply Pay"
date: 2020-03-21T11:04:51+08:00
draft: true
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["Apple Pay", "Develope", "Wallet", ]
categories: ["Web"]
hiddenFromHomePage: false

featuredImage: ""
featuredImagePreview: ""

toc: true
autoCollapseToc: true
math: true
comment: true
---

![Photo by Blake Wisz from unsplash.com](https://images.unsplash.com/photo-1556740714-a8395b3bf30f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80)

## 引言

最近支付宝和 [Apple Pay](https://www.apple.com/apple-pay/) 搞了一波动作，Apple Pay 的场景也越来越多了，正好我现在的项目正在搞 Apple Pay，并在本地模拟了一下 Apple Pay 的流程，所以趁热总结一下。

Apple Pay 的开发需要用到 Apple Developer Account, 所以要提前申请呀，只要有了这个账号，别的大都不需要关心，只需要关注开发就可以了。

Apple Pay 开发中要用到信用卡或者储蓄卡，作为开发者我们不需要准备这些，Apple 为开发者提供了 [Sandbox-testing](https://developer.apple.com/apple-pay/sandbox-testing/) 账户，也就是模拟账户，不会发生真实的 Money 交易，但可以正常与 Apple Pay 的后段 API 交互，减轻了开发的流程。

Apple Pay 的应用与开发都需要 HTTPS ,数据要经过 TLS/SSL 加密来确保交易安全。

## 工具链

- Mac OS
- [openssl](https://github.com/openssl/openssl)
- NodeJS
- HTML5
- JavaScript
- Apple Developer Account(有个有钱的朋友真的很重要)
- Safari (所有关于 Apple Pay 的操作只能在此浏览器中实现)
- 不需要信用卡 🐶

## 环境搭建

![Apple Pay Region](https://pic4.zhimg.com/80/v2-f394d11dfde6187316ab834c599740f6.png)

Apple Pay 受到[国家地域的限制](https://www.apple.com/ios/feature-availability/#apple-pay)，所以我们需要将 Mac 的 `Region`切换到可用区并重启电脑使之生效。 否则会在添加卡片时出现 `设置Apple Pay 时发生错误`。
![Apple Pay Error](https://pic4.zhimg.com/80/v2-94afc3a027f174306a89551d1a83d7b8.png)

### Apple Pay Wallet 设置

在没有开启 Apple Pay 的时候， `System Performance` 中是没有 Wallet 的，我们需要用申请到的`Apple Developer Account`登陆到系统中，此时还是没有显示 Wallet 的话，就点开[Apple Pay Demo](https://applepaydemo.apple.com)中的 `Pay` 按钮，系统会自动弹出如下弹框
![Apple Pay Setting](https://pic4.zhimg.com/80/v2-4317291719731c4d3f7d2567d71887d1.png)
点击`Apple Pay 偏好设置`，进入添加卡片控制台

![Image](https://pic4.zhimg.com/80/v2-78680e2a8eef2af50627c147369e5dcc.png)

> 切换地域后系统语言设置为英语了。

点击 `添加卡片`可进入添加卡片页面
![默认卡片](https://pic4.zhimg.com/80/v2-238d28158dc7aee7557be6d1ef0c1129.png)
此时系统可能会已经有卡片了，需要你输入信用卡的安全识别码，我们直接忽略点击右下角的`Add a Different Credit or Debit Card`按钮

![添加卡片](https://pic4.zhimg.com/80/v2-aacb63829e97da9692f5f3b0c5434b50.png)
进入扫描或者输入卡片信息的页面，我们选择右下角的`Enter Card Details Manually`,
进入卡信息输入页面，我们在 Apple 提供的[Sandbox](https://developer.apple.com/apple-pay/sandbox-testing/)中选择一个卡片信息填入即可。
后面的步骤只是 Apple Pay 的验证。
至此，Apple Pay 相关的环境搭建就搞完了。

## Demo

### 新建 Demo

```shell
$ mkdir apple
$ cd apple
$ git init
$ npm init -y
$ npm install http-server
```

### 生成证书

证书用来在本地启用 https

```shell
$ openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
```

> 此命令中大部分信息可以随意填写，但是对于 `Common name` 这个设置需要设置为`127.0.0.1` 或者`localhost`.

运行此命令后, 在项目根目录生成 `cert.pem` 和 `key.pem` 两个文件,

### Coding

#### 1.package.json

```json
  {
    "name": "apple",
    "version": "1.0.0",
    "description": "",
    "main": "index.js",
    "scripts": {
      "test": "echo \"Error: no test specified\" && exit 1",
 +    "dev": "http-server -S -C cert.pem" //  启用https
    },
    "author": "",
    "license": "ISC"
  }
```

#### 2.index.html

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <script src="./index.js"></script>
  </head>
  <body>
    <button onclick="pay()">Apple Pay</button>
  </body>
</html>
```

在页面上显示一个 Apple Pay 按钮，方便触发 Apple Pay。

#### 3.index.js

```JavaScript
function pay() {
  startApplePaySession()
}

/**
 * 检测当前浏览器是否支持 Apple Pay
 */
function checkApplePaySupported() {
  return window.ApplePaySession && window.ApplePaySession.canMakePayments()
}

function startApplePaySession() {
  if(!checkApplePaySupported()) {
    alert("Your browser is not supported for Apple Pay")
  }
  // 需要指定 Apple pay js 的版本
  const version = 3;
  // 模拟merchant 需要收取的费用和支持的支付方式等
  const request = {
    "countryCode": "US",
    "currencyCode": "USD",
    "merchantCapabilities": [
      "supports3DS"
    ],
    "supportedNetworks": [
      "visa",
      "masterCard",
      "amex",
      "discover"
    ],
    "total": {
      "label": "Demo (Card is not charged)",
      "type": "final",
      "amount": "1.99"
    }
  }
  // 构建checkApplePaySupported()
  session = new ApplePaySession(version, request)
  window.session = session

  // 监听收货联系人改变的事件
  session.onshippingcontactselected = function onshippingcontactselected(event) {
    // session.completeShippingContactSelection(update)
  };
  // 监听送货防水改变的事件
  session.onshippingmethodselected = function onshippingmethodselected(event) {
    // session.completeShippingMethodSelection(update)
  };
  // 监听对此次支付认证的事件
  session.onpaymentauthorized = function onpaymentauthorized(event) {
    // session.completePayment(update)
  };
  // 监听支付方式改变的事件
  session.onpaymentmethodselected = function onpaymentmethodselected(event) {
    // session.completePaymentMethodSelection(update)
  };
  // 监听取消支付的事件
  session.oncancel = function oncancel(evt) {
    console.log('Cancel Apple Pay', evt)
  };
  // 监听验证merchant有效性的事件，这部分是要和 PSP 验证的，如果此部分验证不通过，在Mac上是不会出现 `Pay with Touch ID`的。
  session.onvalidatemerchant = function onvalidatemerchant(event) {
    console.log('onvalidatemerchant: ', '验证merchant账户的有效性')
  }
  // 开始调起 Apple Pay
  session.begin()
}
```

### 运行

```shell
$ yarn dev
Starting up http-server, serving ./ through https
Available on:
  https://127.0.0.1:8080
  https://192.168.31.91:8080
Hit CTRL-C to stop the server
```

![Apple Pay](https://pic4.zhimg.com/80/v2-518a2efa3455b471a8bb5024d866a480.png)

## 总结

## Reference

- [1.博客：https://guzhongren.github.io/](https://guzhongren.github.io/)
- [2.Apple Pay Developer Document：https://developer.apple.com/documentation/](https://developer.apple.com/documentation/)\*
- [3.Apple Pay On Web Document：https://developer.apple.com/documentation/apple_pay_on_the_web](https://developer.apple.com/documentation/apple_pay_on_the_web)\*
- [4.Apple Pay Demo: https://applepaydemo.apple.com](https://applepaydemo.apple.com)
- [5.Apple Pay Sandbox-testing: https://developer.apple.com/apple-pay/sandbox-testing/](https://developer.apple.com/apple-pay/sandbox-testing/)
- [6.Openssl: https://www.openssl.org/](https://www.openssl.org/)
- [7. Apple Pay 介绍](https://www.apple.com/apple-pay/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

---

![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)

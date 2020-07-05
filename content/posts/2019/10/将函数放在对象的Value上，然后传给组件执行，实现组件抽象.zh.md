---
title: "将函数放在对象的Value上，然后传给组件执行，实现组件抽象"
date: 2019-10-14T21:36:26+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["code", "refactor", "react", "reactNative", "技术债务"]
categories: ["Code"]
featuredImage: "https://images.pexels.com/photos/3811731/pexels-photo-3811731.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260"
---

## 情景

在我们开发中，我们通常需要对某一系列的组件Coding, 但我们是程序员啊，我们怎么能容忍代码重复出现的坏味道呢。所以，对于一些列相同的操作我们就要用到循环处理了。

## 目标

![image](https://yqfile.alicdn.com/4254ffc9caefb928d7fdb8a60c6ed1aabe2bdc37.png)

我们需要将底部两个按钮 `新建询价`和 `采购助手`展示出来，并且点击他们的操作后有不同的交互。

## coding

对于此情况，我们需要将对两个按钮做抽象，抽象为数组，在render函数里循环执行即可，这里有个地方需要说明一下，我们把事件处理函数也放在了抽象好的对象上，如下

```js
const tools = [
      {
        index: 1,
        image: images.tabs.newEnquiryTool,
        title: '新建询价',
        onPress: () => {
          this.props.controlToolVisible(false)
          Actions.newEnquiry()
        },
      },
      {
        index: 2,
        image: images.tabs.purchaseAsstant,
        title: '采购助手',
        onPress: () => {
          Chatlogin().then(data => {
            if (data) {
              this.props.getAccountInfo(_.get(global.USER_INFO, 'imInfo.mpcAccId'))
                .then(chatInfo => {
                  this.props.controlToolVisible(false)
                  Actions.chat({
                    session: {
                      contactId: 123,
                      name: '31231',
                      sessionType: '0'
                    }
                  })
                })
                .catch(console.error)
            }
          })
        },
      },
    ]
```

在render函数里我们循环即可实现代码的抽象

```js
{
    tools.map((tool) => (
      <TouchableOpacity style={styles.toolWrapper} key={tool.index} onPress={tool.onPress} >
         <Image source={tool.image} />
         <Text style={styles.text}>{tool.title}</Text>
      </TouchableOpacity>))
}

```

## 总结

代码总是可以解决很多问题，在Coding 时，应该及时重构，将代码中的坏味道及时剔除，为以后业务功能开发解决技术债。



## Reference

[1.https://guzhongren.github.io/](https://guzhongren.github.io/)

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)
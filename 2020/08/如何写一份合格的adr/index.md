# 如何写一份合格的ADR


## Where from

最近在项目上要做技术变更，需要给处建议并和客户确认，在组内 TL 和 老 TWer 的帮助下，算是对 ADR 有了一个较为完全的认识，并知道了如何写一个 ADR，在此，做个记录，加深理解。

## 什么是 ADR

> *ADR* 即*Architectural Decision Records*，架构决策记录。
>
> * 架构决策（AD）是一种软件设计选择，针对功能性或非功能性的需求进行的选择设计。
>
> * 架构上重要的要求（ASR, Architecturally Significant Requirement）是对一个软件系统的体系结构和质量衡量效果的要求。
>
> * 架构决策记录（ADR）捕捉AD，如经常做写个人笔记或会议记录时; 在项目中创建和维护的ADR集合构成其决策日志。

所有这些都属于架构知识管理(AKM)的主题。

![Photo by Josep Martins](https://images.unsplash.com/photo-1583591900414-7031eb309cb6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=675&q=80)

## ADR 能干什么

* 它可以记录某些决定背后的动机.

其实这一条就够了，在敏捷项目或者大型项目开发中，我们不难避免作出架构变更的操作。如果一次次的变更都没有记录，对于后来的开发者或者维护者都会是灾难。
在没有文档或者前人的指导下，如果使用新的架构变更可能会导致意想不到的 bug 出现。

为了能使后来者了解项目架构变化或者更好的维护项目，将重要的架构变更记录下来是非常重要的。

* 为客户更好的呈现现象及解决方案

当你作为乙方，为你的甲方开发系统，突然有一个功能要更改之前的架构设计，那么你的这次的架构变更应该需要让甲方知道并同意，最好的方案就是给他 show 一个ADR.

* 梳理业务

ADR 是一个思考过程，也是一个记录过程； 将抽象的思考，以文字和图表等的形式记录下来，可以更好地辅助我们理解业务，共享知识。

![Photo by Brandi Redd](https://images.unsplash.com/photo-1470790376778-a9fbc86d70e2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=649&q=80)
## 什么情况下要使用ADR

如上所说，在项目架构有重大变更的时候需要做记录, 让所有关系人都了解到这次变更。在此需要说一下，对于敏捷宣言其中有一句，`工作的软件高于详尽的文档`， 这句话的意思不是不写文档。所以，必要的文档还是要写的。

## 怎么写呢

### 标题

标题(Title) 建议以 `ADR-[序号]-[项目/团队名称]-[ADR主题]` 这样的形式，直观且有序。

### 总结(Summary)

这部分的主要任务是让别人快速知道你的这次 ADR 的上下文(Context)是什么，有哪些目标(Objective),有哪些备选方案(Options)，谁在主导(Owner), 有谁审阅了(Reviews),有哪些相关的决策(Related Decisions), 当前 ADR 的状态(Status)是什么等。

一般情况下，在 ADR 开始的时候用一个表格来总体概括当前 ADR 的一些状态。比如：

|Item|Content|
|-|-|
|名称(Title)| ADR的标题|
|序号(ID)| ADR 序列号|
|主导人(Owner)| 负责人|
|审阅人(Reviewers)| 参与的审阅者|
|上下文(Context)| 这里介绍ADR的背景(background)，目标(objective)，是否紧急(urgent)，如果不解决会有什么影响(impact)或者风险(risk)，有什么限制,顾虑(constraints)等，所有可以为作出决定的内容都可以写在这里 |
|目标(Objective)| 列出所有要达到的目标|
|备选方案(Options)| 以列表(`Option`)形式列出所有的备选方案|
|相关决策(Title)| 关于此次决策相关的一些其他辅助链接|
|状态(Status)| 本 ADR 的状态，`INPROGRESS`, `PROPOSED`, `PENDING`, `DECIDED`和`REJECTED` 中的一个|
|决定(Decision)| 接受(`Accepted`)或者拒绝(`Rejected`)|
|决策(Consequences)| 选择了哪个方案，有什么后果或者代价|

### 详细背景(Background)

如果以上的表格并没有清楚的说明问题，那么在这块就可以详细说明了。

建议：

* 在阐述问题的时候尽量用图(截图，示意图，设计图，流程图)或者表来说明，因为图表比文字更直观，更容易理解；

### 方案对比(Option Comparison)

以上内容已经让你的甲方了解到了你们遇到了什么问题，接下来的内容就是在各个方案之间对比了，当然作为陈述 ADR 的人，你必须又一个你推荐(prefer)的方案。

方案对比一般也是一个表格，比如：

|方案(Options)|方案详细信息(Solution Details)|优势(pros)|劣势(Cons)|决策后果或代价(Consideration)|开发或测试成本(Dev&test Effort)|
|:-|:-|:-|:-|:-|:-|
|方案1-option1 title|详细信息|有哪些优势|有哪些劣势|有什么要被顾虑| 较小(Small), 中等(Medium)， 较难(High) 中的一个|
|方案2-option1 title|详细信息|有哪些优势|有哪些劣势|有什么要被顾虑| 较小(Small)|
|方案3-option1 title|详细信息|有哪些优势|有哪些劣势|有什么要被顾虑| 中等(Medium)|
|方案4-option1 title|详细信息|有哪些优势|有哪些劣势 | 有什么要被顾虑 | 较难(High)|

### 讨论拉通(Discuss)

上面所有做的工作都是为这一次讨论服务的，在拉通的会议上，需要拉上所有与本次变更有关系的人，当然最主要的是将甲方爸爸拉上；在会议上，你需要先陈述上上面的内容，最后把选择权交到甲方爸爸手里，千万不要把甲方爸爸的唯一的权利剥夺了。至于为什么，我也不知道。😄

在所有讨论完毕，要将 ADR 更新，并更新 ADR 的总结部分(Summary)， 方便后面的人快速得到决策信息。

## 参考项目

* [MADR](https://adr.github.io/madr/) - Markdown架构决策记录（MADR）。精益ADR可快速记录代码中的架构决策。
* [adr-log: https://adr.github.io/adr-log/](https://adr.github.io/adr-log/) - 从MADR生成体系结构决策日志。
* [嵌入式架构决策记录:https://adr.github.io/e-adr/](https://adr.github.io/e-adr/)显示如何通过ADR注释将分布式AD日志嵌入Java代码中。
* [eadlsync:https://adr.github.io/eadlsync/](https://adr.github.io/eadlsync/) - 将嵌入式架构决策记录与架构决策存储库同步。
* [SE Repo: https://github.com/adr/serepo](https://github.com/adr/serepo) - 软件工程资料库。用于版本化软件工程工件的存储库，可以是架构决策，模式等。

![Photo by Sheldon Liu](https://images.unsplash.com/photo-1569091791842-7cfb64e04797?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=675&q=80)
## 总结

ADR 在大型项目或者大公司的项目中经常会用到，不管是对现有业务的澄清总结，还是对不确定的业务的拉通都有积极作用。当然也是一个`甩锅利器`。

建议：

* 使用版本控制工具来管理 ADR, 比如[Confluence](https://www.atlassian.com/software/confluence),国内的话有[语雀](https://www.yuque.com/), [石墨](https://shimo.im/), 还有些代码管理平台也有`Wik`, 如阿里云的[云效](https://www.aliyun.com/product/yunxiao), 腾讯的[Coding](https://coding.net/)等； 当然如果是小项目也可以存在代码仓库中。

万事皆可法；工作中的大部分事物都是有套路的; 愿你选对套路，归来仍是高效 dev。

## Reference

* [博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [图床:https://sm.ms/](https://sm.ms/)
* [ADR: https://adr.github.io/](https://adr.github.io/)
* [架构设计实践之架构决策记录: https://zhuanlan.zhihu.com/p/141385447](https://zhuanlan.zhihu.com/p/141385447)
* [【译文】架构决策记录（Architecture Decision Records）](https://www.phodal.com/blog/documenting-architecture-decisions/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)


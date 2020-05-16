---
title: "Golang With SQLLite Practice"
date: 2019-09-01T10:56:39+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["Golang", "go", "SQLLite"]
categories: ["Golang"]
featuredImage: "https://i.loli.net/2020/03/29/JEtYLcPTCDIU2bs.png"
---

<!-- TOC -->

- [简介](#%E7%AE%80%E4%BB%8B)
- [目标](#%E7%9B%AE%E6%A0%87)
- [目的](#%E7%9B%AE%E7%9A%84)
- [Coding](#coding)
  - [目录结构](#%E7%9B%AE%E5%BD%95%E7%BB%93%E6%9E%84)
  - [封装 error 函数](#%E5%B0%81%E8%A3%85-error-%E5%87%BD%E6%95%B0)
  - [安装 SQLLite 库及其他库](#%E5%AE%89%E8%A3%85-sqllite-%E5%BA%93%E5%8F%8A%E5%85%B6%E4%BB%96%E5%BA%93)
  - [申明 DB 全局变量](#%E7%94%B3%E6%98%8E-db-%E5%85%A8%E5%B1%80%E5%8F%98%E9%87%8F)
  - [初始化数据库](#%E5%88%9D%E5%A7%8B%E5%8C%96%E6%95%B0%E6%8D%AE%E5%BA%93)
  - [用户模型构建及原子操作](#%E7%94%A8%E6%88%B7%E6%A8%A1%E5%9E%8B%E6%9E%84%E5%BB%BA%E5%8F%8A%E5%8E%9F%E5%AD%90%E6%93%8D%E4%BD%9C)
    - [用户模型](#%E7%94%A8%E6%88%B7%E6%A8%A1%E5%9E%8B)
    - [新增](#%E6%96%B0%E5%A2%9E)
    - [删除](#%E5%88%A0%E9%99%A4)
    - [修改](#%E4%BF%AE%E6%94%B9)
    - [查询](#%E6%9F%A5%E8%AF%A2)
  - [在应用中启动并调用用户模型的方法](#%E5%9C%A8%E5%BA%94%E7%94%A8%E4%B8%AD%E5%90%AF%E5%8A%A8%E5%B9%B6%E8%B0%83%E7%94%A8%E7%94%A8%E6%88%B7%E6%A8%A1%E5%9E%8B%E7%9A%84%E6%96%B9%E6%B3%95)
  - [运行结果展示](#%E8%BF%90%E8%A1%8C%E7%BB%93%E6%9E%9C%E5%B1%95%E7%A4%BA)
- [总结](#%E6%80%BB%E7%BB%93)
- [Reference](#reference)
- [Hereby declared（特此申明）](#hereby-declared%E7%89%B9%E6%AD%A4%E7%94%B3%E6%98%8E)

<!-- /TOC -->

## 简介

[SQLite](about:blank) 是一个进程内的库，实现了自给自足的、无服务器的、零配置的、事务性的 SQL 数据库引擎。它是一个零配置的数据库，这意味着与其他数据库一样，你不需要在系统中配置。在 Golang 中使用SQLLite 也相当简单，只需要安装 SQLLite 的Golang  包即可使用；
Golang 就不多介绍了，能看到这个肯定对 [Golang](https://golang.google.cn/) 有一定的了解。

仓库地址：<https://github.com/AndorLab/golang-sqllite>

## 目标

使用 SQLLite 通过构建一个社区用户表，包含如下字段; 通过 SQLLite 的 API 实现对社区用户表进行增删改查。

| 序号 | 字段     | 类型   | 说明     |
| ---- | -------- | ------ | -------- |
| 1    | uid      | int64  | id       |
| 2    | username | string | 用户名   |
| 3    | city     | string | 城市     |
| 4    | skills   | string | 技能     |
| 5    | created  | int64  | 创建时间 |

## 目的

了解 SQLLite ，学习 Golang 操作 SQLLite, 巩固 Golang 基础知识。

## Coding

### 目录结构

项目采用 Golang 传统的平铺式目录

```shell
.
├── LICENSE
├── Makefile      # 构建工具
├── README.md     # README
├── db.go         # 数据库操作
├── error.go      # 错误处理工具方法
├── fcc.db        # sqllite 数据库
├── go.mod        # go modules
├── go.sum        # go modules
├── main.go       # 项目入口
├── server.go     # 应用程序入口
└── userModel.go  # 用户模型

```

### 封装 error 函数

因为在 go 中会有很多的 error 的判断，为了代码精简，我们特封装一下 error; 下面的 *interface{}* 代表任何类型，类似 TypeScript 中的 *any*。

```golang
# error.go
func checkErr(data interface{}, err error) (interface{}, error) {
	if err != nil {
		log.Error(err)
		return nil, err
	}
	return data, err
}
```

### 安装 SQLLite 库及其他库

使用 go modules 之后，将所需的包放在 import 中，使用 *go mod tidy* 命令后，go 会自动安装程序使用到的包。

 日志相关的库，主要用于在控制台打印结果
```golang
# server.go
import (
	"github.com/labstack/gommon/log"
)

```
SQLLite 包
```golang
# db.go
_ "github.com/mattn/go-sqlite3"
```

### 申明 DB 全局变量

因为在程序中，我们要通过数据库来获取数据，那么存在一个全局的数据库指针是很有必要的。

```golang
# main.go
var db = new(sql.DB)
```

### 初始化数据库

SQLLite 初始化数据库非常简单，只要指定数据库驱动和数据库文件就可以。为了在程序的整个生命周期中操作数据库，我们将 db 返回。

```golang
// openDB 打开数据库
func openDB() *sql.DB {
	//打开数据库，如果不存在，则创建
	db, err := sql.Open("sqlite3", "./fcc.db")
	checkErr(db, err)
	return db
}
```
创建好 db 后，需要创建表结构，执行如下数据库操作命令即可完成用户表的创建。
```golang
// initDB 初始化数据库
func initDB() {
	//创建表
	sqlTable := `
			CREATE TABLE IF NOT EXISTS userinfo(
					uid INTEGER PRIMARY KEY AUTOINCREMENT,
					username VARCHAR(64) NULL,
					city VARCHAR(64) NULL,
					skills VARCHAR(128) NULL,
					created BIGINT NULL
			);
			`
	db.Exec(sqlTable)
}
```

### 用户模型构建及原子操作

构建现代程序，强调程序的健壮性，封装就是比较重要的；用 MVC、 MVVM 的观点，我们需要有一个 Model 来提供对象的原子操作。在这，我们将用户抽象为UserModel，对用户的增删改查封装到 *insert*、*dleete*、*update* 和 *query*。

#### 用户模型

```golang
// UserModel 用户模型
type UserModel struct {
	uid      int64
	username string
	city     string
	skills   string
	created  int64
}

```
对用户的原子操作

#### 新增

```golang
// insert 新增
func (u UserModel) insert() (sql.Result, error) {
	stmt, err := db.Prepare("insert into userinfo(username, city, skills, created) values(?,?,?,?)")
	checkErr(stmt, err)
	res, err := stmt.Exec(u.username, u.city, u.skills, time.Now().Unix())
	checkErr(res, err)
	return res, nil
}
```

#### 删除

```golang
// delete 删除
func (u UserModel) delete(id int64) int64 {
	stmt, err := db.Prepare("delete from userinfo where uid=?")
	checkErr(stmt, err)
	res, err := stmt.Exec(id)
	checkErr(res, err)
	affect, err := res.RowsAffected()
	checkErr(affect, err)
	return affect
}
```

#### 修改

```golang
// update	更新用户技能
func (u UserModel) update(id int) int64 {
	stmt, err := db.Prepare("update userinfo set skills=? where uid=?")
	checkErr(stmt, err)
	res, err := stmt.Exec(u.skills, id)
	checkErr(res, err)
	affect, err := res.RowsAffected()
	checkErr(affect, err)
	return affect
}
```

#### 查询

```golang
// query 查询
func (u UserModel) query() ([]UserModel, error) {
	rows, err := db.Query("select * from userinfo")
	checkErr(rows, err)
	var userList = []UserModel{}
	for rows.Next() {
		var user = UserModel{}
		err = rows.Scan(&user.uid, &user.username, &user.city, &user.skills, &user.created)
		checkErr(nil, err)
		userList = append(userList, user)
	}
	rows.Close()
	return userList, nil
}
```

### 在应用中启动并调用用户模型的方法

在上面我们完成了对用户模型及原子操作的封装，那么接下来就是通过应用程序将分装的内容调用，传入正确的参数进行调用。
我们在此封装一个 *startAPP* 方法，在这个里面我们调用封装好的用户操作的接口，实现功能。

因为数据库要在整个生命周期存在，当程序结束的时候，我们应该将数据库链接释放，所以我们用到了 go 的 *defer* 关键字
```golang
# server.go
  db = openDB()
  defer db.Close()
  initDB()
```

调用用户操作的增删改查并打印结果, 对于不同的操作，我们应该有不同的数据，所以在程序中会有 *user*、和 *updateUser* 两个对象

```golang
# server.go
  user := UserModel{
  	username: "谷中仁",
  	city:     `西安`,
  	skills:   `TypeScript`,
  }
  // insert
  result, err := user.insert()
  id, err := result.LastInsertId()
  checkErr(id, err)
  log.Info("增：操作数据的id:", id)
  // update
  updateUser := UserModel{
  	skills: `golang`,
  }
  affectedRow := updateUser.updateSkills(1)
  log.Info("改：影响的行数：", affectedRow)
  // query
  queryUser := UserModel{}
  list, _ := queryUser.query()
  log.Info("查：", list)
  // delete
  affect := queryUser.delete(1)
  log.Info("删：", affect)  
  // query
  list, _ = queryUser.query()
  log.Info("查：", list)
```

### 运行结果展示

```shell
$ make run
go run *.go
{"time":"2019-08-31T14:21:48.941164+08:00","level":"INFO","prefix":"-","file":"server.go","line":"21","message":"增：操作数据的id:1"}
{"time":"2019-08-31T14:21:48.941842+08:00","level":"INFO","prefix":"-","file":"server.go","line":"27","message":"改：影响的行数：1"}
{"time":"2019-08-31T14:21:48.942034+08:00","level":"INFO","prefix":"-","file":"server.go","line":"31","message":"查：[{1 谷中仁 西安 golang 1567232508}]"}
{"time":"2019-08-31T14:21:48.942599+08:00","level":"INFO","prefix":"-","file":"server.go","line":"34","message":"删：1"}
{"time":"2019-08-31T14:21:48.942696+08:00","level":"INFO","prefix":"-","file":"server.go","line":"38","message":"查：[]"}
```

## 总结

SQLLite 对开发者非常友好，不用安装在机器上，只要指定SQLLite的驱动和数据库存储文件即可对 SQLLite 数据库进行操作；Golang 作为比较流行的语言，对数据库也非常友好，提供了基本的数据库接口，
至于用户需要什么样的数据库，自己开发对应的数据库驱动即可。当然在 GitHub 已经有很多开源爱好者开发了比较流行的数据库的驱动可以直接拿来用。

SQLLite 使用的也是标准的 SQL 语法，可以让不同的开发者快速入手。

为什么没有用到 Golang 的 Web 框架？

因为我们的侧重点在 Golang 与 SQLLite，不在 API 实现上，最小化的实现目标，才是我们学习知识最快速的途径。

原文链接：<https://chinese.freecodecamp.org/news/golang-with-sqllite-practice/>



## Reference

* [1.博客：https://guzhongren.github.io/](https://guzhongren.github.io/)*
* [2.原文：https://yq.aliyun.com/articles/716696?spm=a2c4e.11155435.0.0.5d7c3312dFgns3](https://yq.aliyun.com/articles/716696?spm=a2c4e.11155435.0.0.5d7c3312dFgns3)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)

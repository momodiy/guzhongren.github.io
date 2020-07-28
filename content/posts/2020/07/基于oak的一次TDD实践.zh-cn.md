---
title: "基于oak的一次TDD实践"
date: 2020-07-24T22:21:11+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["deno", "oak", "tdd", "git", "mvc", "fetch"]
categories: ["deno"]
featuredImage: "https://i.loli.net/2020/07/27/Q3pqoCGe7PkKSOv.jpg"
images: [""]
---

## `Talking is cheap! Show me code!`

> [源码地址：`Deno Restful API With PostgreSql & TDD`](https://github.com/guzhongren/deno-restful-api-with-postgresql-tdd)

## 简介

`Deno` 是`ry(Ryan Dahl)`的新项目，近期发布了其 `1.0.0` 版，在开发圈子里掀起了不小的风浪，与之创建的 Node 运行时有异曲同工之妙，`真香定律`又一次出现了。

在软件开发中，为了开发出可维护，高质量的程序，使用`TDD`开发可以有效提升项目质量和开发效率。

在这篇博客中，我将使用`Deno`, `Typescript`, `PostgreSql`来开发一个用户管理的 `API` 接口。

## Deno & oak

下面都是来自官网的介绍，写的很通俗易懂，就不用我来解读了。

### Deno

> Deno 是一个简单、现代且安全的 JavaScript 和 TypeScript 运行时环境，其基于 V8 引擎并采用 Rust 编程语言构建。
> * 默认安全设置。除非 显式开启，否则没有文件、网络，也不能访问运行环境。
> * 天生支持 TypeScript。
> * 只有一个单一的可执行文件。
> * 自带实用工具，例如依赖检查器（deno info）和 代码格式化工具（deno fmt）。
> * 有一套经过审核（审计）的标准模块， 确保与 Deno 兼容： deno.land/std。

### [oak](https://github.com/oakserver/oak)

> A middleware framework for Deno's net server 🦕

`oak` 是借鉴 `Node` 框架`Koa`的设计思路开发的一个高性能的框架，其`洋葱模型`式的中间件等思路在开发中使用起来也是非常方便。

## 目标

基于对以上的基础知识的认识，我们计划开发一个用户管理的`API`平台；对于后端简单来说，就是提供关于用户的增删改查（`CURD`）操作。所以我们的主要目标就是提供4个对用户`CURD`的接口。

## 工具

> 工欲善其事，必先利其器。

### 开发工具

[`VS Code`](https://code.visualstudio.com/), [`Docker`](https://www.docker.com/)

### 环境工具

[`Deno`](https://deno.land/), [`Typescript`](https://www.typescriptlang.org/), [`Node`](https://nodejs.org/)

> 注： Node 是用来调试 Deno的

## 基础环境信息

我的环境信息如下：

```shell
❯ node -v
v12.13.0

❯ deno --version
deno 1.2.0
v8 8.5.216
typescript 3.9.2

❯ docker --version
Docker version 19.03.8, build afacb8b

```

其他信息

|类型|版本|备注|
|:--|:--:|:--:|
|[PostgreSql](https://hub.docker.com/_/postgres)|12||
|[PGAdmin](https://hub.docker.com/r/dpage/pgadmin4)|latest||

### 项目结构

```shell
❯ tree -L 1 deno-restful-api-with-postgresql-tdd
deno-restful-api-with-postgresql-tdd
├── .github         // github action
├── .vscode         // debug 及 vscode 配置文件
├── LICENSE         // 仓库许可
├── README.md       // 项目说明，包括数据库连接，简化后的运行命令等
├── _resources      // 基础资源
│   ├── IaaS        // 基础设施，docker-compose 启动postgresql
│   ├── httpClient  // http请求测试
│   └── migration   // 负责生成数据库表
├── deps.ts         // 项目依赖的库及项目中要用到的资源（import）
├── lock.json       // 完整性检查与锁定文件, 参考：https://nugine.github.io/deno-manual-cn/linking_to_external_code/integrity_checking.html
├── makefile        // 将开发需要的命令行简化后目录
├── src             // 源代码目录
└── tests           // 测试目录

5 directories, 5 files

```

## 实现过程

> 先说明一下，如果要用文字写完整个开发过程个人认为是没有必要的，所以就以最开始的`health`和`addUser`(`post`接口)为例， 其他接口请参考[代码实现](https://github.com/guzhongren/deno-restful-api-with-postgresql-tdd)。

### 启动基础设施(数据库)并初始化数据表

#### 启动数据库

```shell
❯ make db
cd ./_resources/Iaas && docker-compose up -d
Starting iaas_db_1 ... done
Starting iaas_pgadmin_1 ... done
```

#### 登录`pgadmin`, 在默认的数据库`postgres`中新建`Query`并执行如下操作，完成初始化数据库

```sql
CREATE TABLE public."user"
(
    id uuid NOT NULL,
    username character varying(50)  NOT NULL,
    registration_date timestamp without time zone,
    password character varying(20)  NOT NULL,
    deleted boolean
);
```

### src 最终目录

```shell
❯ tree -a -L 4 src
src
├── Utils
│   └── client.ts
├── config.ts
├── controllers
│   ├── UserController.ts
│   ├── health.ts
│   └── model
│       └── IResponse.ts
├── entity
│   └── User.ts
├── exception
│   ├── InvalidedParamsException.ts
│   └── NotFoundException.ts
├── index.ts
├── middlewares
│   ├── error.ts
│   ├── logger.ts
│   └── time.ts
├── repositories
│   └── userRepo.ts
├── router.ts
└── services
    ├── UserService.ts
    └── fetchResource.ts

8 directories, 16 files
```

在开始之前，我们先定义一些常用的结构体和对象，如: response，exception 等

```ts
// src/controllers/model/IResponse.ts
export default interface IResponse {
  success: boolean; // 表示此次请求是否成功
  msg?: String;     // 发生错误时的一些日志信息
  data?: any;       // 请求成功时返回给前端的数据
}
```

```ts
// src/entity/User.ts
export default interface IUser {
  id?: string;
  username?: string;
  password?: string;
  registrationDate?: string;
  deleted?: boolean;
}
export class User implements IUser {}

```

异常用来处理错误情况，在最终返回给用户结果的时候，我们不能将异常返回给用户，而是以一种更友好的方式返回，具体流程可以参考`src/middlewares/error.ts`这个中间件的处理方式。

```ts
// src/exception/InvalidedParamsException.ts
export default class InvalidedParamsException extends Error {
  constructor(message: string) {
    super(`Invalided parameters, please check, ${message}`);
  }
}
```

```ts
// src/exception/NotFoundException.ts
export default class NotFoundException extends Error {
  constructor(message: string) {
    super(`Not found resource, ${message}`);
  }
}

```

### 依赖管理

Deno 没有像 Node 一样的诸如`package.json`来管理依赖，因为`Deno`的依赖是去中心化的，也就是以远程文件作为库，这一点和`Golang`很像。

我将系统中用到的依赖存放在根目录的`deps.ts`中，在最终提交的时候做一次[`完整性检查与锁定文件`](https://nugine.github.io/deno-manual-cn/linking_to_external_code/integrity_checking.html), 来保证我所有的依赖在与其他协作者之间是相同的。

首先导入用到的测试相关的依赖。**在后面开发中用到的相关依赖请自行添加到本文件中。** 比较重要的我会列出来。

```ts
export {
  assert,
  equal,
} from "https://deno.land/std/testing/asserts.ts";

```

### 测试先行

现在`tests`目录下新建一个测试命名为`index.test.ts`, 写基本测试，证明测试和程序是可以`work`的。

```ts
import { assert, equal } from "../deps.ts";
const { test } = Deno;

test("should work", () => {
  const universal = 42;
  equal(42, universal);
  assert(42 === universal);
});

```

### 第一次运行测试

```shell
❯ make test
deno test --allow-env --allow-net -L info
Check file:///xxxx/deno-restful-api-with-postgresql-tdd/.deno.test.ts
running 1 tests
test should work ... ok (6ms)

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out (6ms)
```

### 建立测试固件

将测试中用到的通用的测试信息存放在测试固件（`testFixtures`）中，可以在测试中复用，且可以简化代码。

```ts
// tests/testFixtures.ts
export const TEST_PORT = 9000
```

### health 接口

`health` 接口可以作为系统的健康检查的一个出口，在运维平台中非常实用。对于此接口，我们只需要返回一个状态`OK`即可。其他情况可忽略。那么对应的`Todo`应该如下：

> 当访问到系统的时候，应该返回系统的状态，且为OK。

所以，测试代码如下：

```ts
import {
  assertEquals,
  Application,
  Router,
} from "../../deps.ts";
import { getHealthInfo } from "../../src/controllers/health.ts";
import {TEST_PORT} from '../testFixtures.ts'

const { test } = Deno;

test("health check", async () => {
  const expectResponse = {
    success: true,
    data: "Ok",
  };

  const app = new Application();
  const router = new Router();
  const abortController = new AbortController();
  const { signal } = abortController;

  router.get("/health", async ({ response }) => {
    getHealthInfo({ response });
  });

  app.use(router.routes());

  app.listen({ port: TEST_PORT, signal });

  const response = await fetch(`http://127.0.0.1:${TEST_PORT}/health`);

  assertEquals(response.ok, true);
  const responseJSON = await response.json();

  assertEquals(responseJSON, expectResponse);
  abortController.abort();
});

```

#### given

> - 上面的代码中，首先声明了我们期望的数据结构，即`expectResponse`；
> - 然后创建一个应用程序和一个路由，
> - 再创建一个终止应用的控制器，且从中取到信号标识，
> - 接着， 向路由中添加一个`health`路由及其handler；
> - 然后将路由挂在到应用程序上；
> - 监听应用程序端口，且传入应用程序信号。

#### when

> - 给启动的应用发一个get请求，请求路径为`/health`;

#### then

> - 根据fetch到的结果进行判定，看收到的`response`是不是和期望的一致， 且在最后终止上面的应用程序。
> - 到此，如果运行测试肯定会发生错误，解决问题的也很简单，就是去实现`getHealthInfo` handler。

#### 实现 `getHealthInfo` handler

在src/controller下新建`health.ts`，并以最简单的方案实现上面期望的结果，如下：

```ts
// src/controllers/health.ts
import { Response, Status } from "../../deps.ts";
import IResponse from "./model/IResponse.ts";

export const getHealthInfo = ({ response }: { response: Response }) => {
  response.status = Status.OK;
  const res: IResponse = {
    success: true,
    data: "Ok",
  };
  response.body = res;
};

```

#### 运行测试

运行测试命令，测试通过;

```shell
❯ make test
deno test --allow-env --allow-net -L info
Check file://xxx/deno-restful-api-with-postgresql-tdd/.deno.test.ts
running 2 tests
test should work ... ok (6ms)
test health check ... ok (3ms)

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out (9ms)
```

至此，使用`TDD`完成第一个简单的`health`接口；但对外没有暴露接口，所以需要在`src`目录中实现一个对外暴露该接口的应用。

##### 新建`config.ts`， 做应用程序的配置管理文件

```ts
// src/config.ts
const env = Deno.env.toObject();
export const APP_HOST = env.APP_HOST || "127.0.0.1";
export const APP_PORT = parseInt(env.APP_PORT) || 8000;

export const API_VERSION = env.API_VERSION || "/api/v1";

```

配置文件中，记录了应用程序启动的默认host, 端口，及数据库相关的信息，最后记录了应用程序api的前缀。

在开始之前，需要在`deps.ts`中引入所需要的库；

```ts
export {
  Application,
  Router,
  Response,
  Status,
  Request,
  RouteParams,
  Context,
  RouterContext,
  helpers,
  send,
} from "https://deno.land/x/oak/mod.ts";
```

##### 新建路由 `router.ts`, 引入`Heath.ts`并绑定路由

```ts
// src/router.ts
import { Router } from "../deps.ts";
import { API_VERSION } from "./config.ts";
import { getHealthInfo } from "./controllers/health.ts";

const router = new Router();

router.prefix(API_VERSION);
router
  .get("/health", getHealthInfo)
export default router;

```

##### 新建`index.ts`, 建立应用程序

```ts
// src/index.ts
import { Application, send } from "../deps.ts";
import { APP_HOST, APP_PORT } from "./config.ts";
import router from "./router.ts";


export const listenToServer = async (app: Application) => {
  console.info(`Application started, and listen to ${APP_HOST}:${APP_PORT}`);
  await app.listen({
    hostname: APP_HOST,
    port: APP_PORT,
    secure: false,
  });
};

export function createApplication(): Promise<Application> {
  const app = new Application();
  app.use(router.routes());
  return Promise.resolve(app);
}

if (import.meta.main) {
  const app = await createApplication();
  await listenToServer(app);
}
```

##### 启动应用

如果是`VSCode`， 可以使用`F5`功能键，快速启动应用，在低版本的 `VS Code(1.47.2以下)` 中可以启动调试。也可以以下命令启动；

```shell
❯ make dev
deno run --allow-net --allow-env ./src/index.ts
数据库链接成功！
Application started, and listen to 127.0.0.1:8000
```

##### 调用接口测试结果

这里使用`VS Code` 的[`Rest Client`](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)插件进行辅助测试。

###### 请求体

```
// _resources/httpClient/healthCheck.http
GET http://localhost:8000/api/v1/health HTTP/1.1
```

###### 请求结果

```
HTTP/1.1 200 OK
content-length: 28
x-response-time: 0ms
content-type: application/json; charset=utf-8

{
  "success": true,
  "data": "Ok"
}
```

至此，完成第一个接口，有 `Oak` 提供应用服务，经过了`Unit test`和 `RestClient`的测试。完成了开始的`Todo`。

### 添加用户接口(`addUser`)

添加用户涉及到`Controller`, `Service` 和 `Repository`, 所以我们分三步来实现该接口。

#### Controller

`Controller` 是控制层，对外提供服务；添加用户接口可以为系统添加用户，那么对应的`Todo`如下：

> * 输入用户名和密码，返回特定数据结构的用户信息
> * 参数必须输入，否则抛异常
> * 如果输入错误参数，则抛异常

在此过程中，我们需要用到[`mock`](https://github.com/udibo/mock)来 `mock` 第三方依赖。

导入所需依赖，并新建`UserController.test.ts`，在`Coding` 过程中需要实现`UserService`, 但不需要实现`addUser`方法； 测试如下：

```ts
// tests/controllers/UserController.test.ts
import {
  stub,
  Stub,
  assertEquals,
  v4,
  assertThrowsAsync,
  Application,
  Router,
} from "../../deps.ts";
import UserController from "../../src/controllers/UserController.ts";
import IResponse from "../../src/controllers/model/IResponse.ts";
import UserService from "../../src/services/UserService.ts";
import IUser, { User } from "../../src/entity/User.ts";
import InvalidedParamsException from "../../src/exception/InvalidedParamsException.ts";
import {TEST_PORT} from '../testFixtures.ts'

const { test } = Deno;


const userId = v4.generate();
const registrationDate = (new Date()).toISOString();

const mockedUser: User = {
  id: userId,
  username: "username",
  registrationDate,
  deleted: false,
};

test("#addUser should return added user when add user", async () => {
  const userService = new UserService();
  const queryAllStub: Stub<UserService> = stub(userService, "addUser");
  const expectResponse = {
    success: true,
    data: mockedUser,
  };
  queryAllStub.returns = [mockedUser];
  const userController = new UserController();
  userController.userService = userService;

  const app = new Application();
  const router = new Router();
  const abortController = new AbortController();
  const { signal } = abortController;

  router.post("/users", async (context) => {
    return await userController.addUser(context);
  });

  app.use(router.routes());

  app.listen({ port: TEST_PORT, signal });

  const response = await fetch(`http://127.0.0.1:${TEST_PORT}/users`, {
    method: "POST",
    body: "name=name&password=123",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  });

  assertEquals(response.ok, true);
  const responseJSON = await response.json();

  assertEquals(responseJSON, expectResponse);
  abortController.abort();

  queryAllStub.restore();
});

test("#addUser should throw exception about no params given no params when add user", async () => {
  const userService = new UserService();
  const queryAllStub: Stub<UserService> = stub(userService, "addUser");
  queryAllStub.returns = [mockedUser];
  const userController = new UserController();
  userController.userService = userService;

  const app = new Application();
  const router = new Router();
  const abortController = new AbortController();
  const { signal } = abortController;

  router.post("/users", async (context) => {
    await assertThrowsAsync(
      async () => {
        await userController.addUser(context);
      },
      InvalidedParamsException,
      "should given params: name ...",
    );
    abortController.abort();
    queryAllStub.restore();
  });

  app.use(router.routes());

  app.listen({ port: TEST_PORT, signal });

  const response = await fetch(`http://127.0.0.1:${TEST_PORT}/users`, {
    method: "POST",
    body: "",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  });
  await response.body!.cancel();
});

test("#addUser should throw exception about no correct params given wrong params when add user", async () => {
  const userService = new UserService();
  const queryAllStub: Stub<UserService> = stub(userService, "addUser");

  queryAllStub.returns = [mockedUser];
  const userController = new UserController();
  userController.userService = userService;

  const app = new Application();
  const router = new Router();
  const abortController = new AbortController();
  const { signal } = abortController;

  router.post("/users", async (context) => {
    await assertThrowsAsync(
      async () => {
        await userController.addUser(context);
      },
      InvalidedParamsException,
      "should given param name and password",
    );
    abortController.abort();
    queryAllStub.restore();
  });

  app.use(router.routes());

  app.listen({ port: TEST_PORT, signal });

  const response = await fetch(`http://127.0.0.1:${TEST_PORT}/users`, {
    method: "POST",
    body: "wrong=params",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  });
  await response.body!.cancel();
```

`controller` 这一层需要调用`service`的服; 作为`service`，对于`controller`是一个第三方服务，因此需要将`service`的方法`mock`，并以参数的形式传入`Controller`;下面这段代码就是`mock`的应用；

```ts
  const userService = new UserService();
  const queryAllStub: Stub<UserService> = stub(userService, "addUser");
  const expectResponse = {
    success: true,
    data: mockedUser,
  };
  queryAllStub.returns = [mockedUser];
  const userController = new UserController();
  userController.userService = userService;
```

在此解释两个测试，第一个测试即`#addUser should return added user when add user`;

##### given

> * mock `UserService`,给UserService的 `addUser`方法打桩，并返回特定的用户结构;
> * 新建测试服务，并将 `UserController`注册给post接口 `/users`;

##### when

> * 传入正确的form类型的参数，用`fetch`请求`http://127.0.0.1:9000/users`;

##### then

> * 对获取到的结果进行判定，并中断测试应用，将打桩的方法恢复。

在此解释两个测试，第二个测试即`#addUser should throw exception about no params given no params when add user`; `given`和`when`与第一个测试的`given`和`when`查不多，只是`body`参数为空;最重要的不同点是这次的`then`是在`when`里面，因为抛异常会在`handler`上抛，所以，需要将`then`的判定放在`handler` 上。这里用到了`Deno`的`assertThrowsAsync`来捕获异常并判定异常。

##### given

> * `mock` `UserService`,给UserService的 `addUser`方法打桩，并返回特定的用户结构;
> * 新建测试服务，并将 `UserController`注册给post接口 `/users`;

##### when

> * 给`body`传入空参数，用`fetch`请求`http://127.0.0.1:9000/users`;

##### then

> * `then`部分处于`given`的路由处理`handler`中，对异常进行捕获并判定，接着中断测试应用，将打桩的方法恢复。

##### 运行测试

```shell
❯ make test
deno test --allow-env --allow-net -L info
Check file:///xxx/deno-restful-api-with-postgresql-tdd/.deno.test.ts
running 5 tests
test should work ... ok (5ms)
test UserController #addUser should return added user when add user ... ok (21ms)
test UserController #addUser should throw exception about no params given no params when add user ... ok (4ms)
test UserController #addUser should throw exception about no correct params given wrong params when add user ... ok (3ms)
test health check ... ok (4ms)

test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out (37ms)

```

#### Service

`Service`是服务层，通过组合其他服务和调用底层数据接口层提供服务；对于用户添加，对于添加用户的`Service`, 我们只需要将用户对象传递过来，然后由`Repository`来处理；所以，我们的`Todo`对应如下：

> 当传入期望的用户信息，可返回特定数据结构的用户信息

新建`UserService.test.ts`， 并导入相关依赖；

```ts
// tests/services/UserService.test.ts
import {
  stub,
  Stub,
  assertEquals,
  v4,
} from "../../deps.ts";
import UserRepo from "../../src/repositories/userRepo.ts";
import UserService from "../../src/services/UserService.ts";
import IUser from "../../src/entity/User.ts";
const { test } = Deno;

test("UserService #addUser should return added user", async () => {
  const parameter: IUser = {
    username: "username",
    password: "password",
  };
  const registrationDate = (new Date()).toISOString();
  const id = v4.generate();
  const mockedUser: IUser = {
    ...parameter,
    id,
    registrationDate,
    deleted: false,
  };
  const userRepo = new UserRepo();
  const createUserStub: Stub<UserRepo> = stub(userRepo, "create");
  createUserStub.returns = [mockedUser];

  const userService = new UserService();
  userService.userRepo = userRepo;

  assertEquals(await userService.addUser(parameter), mockedUser);
  createUserStub.restore();
});
```

代码逻辑很简单，基本不需要解释。运行测试肯定会失败，为了让代码通过测试，编写`UserService.ts`, 在`UserService.ts`中调用`Repository`的`create`方法。所以，也需要简单实现`UserRepo`，只需要添加`create`方法即可。

```ts
// src/services/UserService.ts
import UserRepo from "../repositories/userRepo.ts";
import IUser from "../entity/User.ts";

export default class UserService {
  constructor() {
    this.userRepo = new UserRepo();
  }
  userRepo = new UserRepo();
  async addUser(user: IUser) {
    return await this.userRepo.create(user);
  }
```

##### 运行测试

```shell
❯ make test
deno test --allow-env --allow-net -L info
Check file:///xxx/deno-restful-api-with-postgresql-tdd/.deno.test.ts
running 6 tests
test should work ... ok (5ms)
test UserController #addUser should return added user when add user ... ok (21ms)
test UserController #addUser should throw exception about no params given no params when add user ... ok (4ms)
test UserController #addUser should throw exception about no correct params given wrong params when add user ... ok (3ms)
test health check ... ok (4ms)
test UserService #addUser should return added user ... ok (1ms)

test result: ok. 6 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out (38ms)

```

#### Repository

`Repository`通常和数据库交互，将传入的数据持久化到数据库中；对于添加用户这个接口，我们的需求因该是将传入的信息以数据库要求的格式存储起来，并将结果返回给`Service`;因此，`Todo`大致如下：

> * 将传入的用户存入数据亏并返回特定数据结构的信息
> * 如果参数中缺少基本字段则抛异常

测试如下：

```ts
// tests/repositories/UserRepo.test.ts
import {
  stub,
  Stub,
  Client,
  assertEquals,
  v4,
  assert,
  assertMatch,
  assertThrowsAsync,
} from "../../deps.ts";
import UserRepo from "../../src/repositories/userRepo.ts";
import client from "../../src/Utils/client.ts";
import IUser from "../../src/entity/User.ts";
import NotFoundException from "../../src/exception/NotFoundException.ts";
import InvalidedParamsException from "../../src/exception/InvalidedParamsException.ts";
const { test } = Deno;

test("UserRepo #create should return mocked User given username&password when create", async () => {
  const queryStub: Stub<Client> = stub(client, "query");
  const mockedQueryResult = {
    rowCount: 1,
  };
  queryStub.returns = [mockedQueryResult];
  const parameter: IUser = {
    username: "username",
    password: "password",
  };
  const userRepo = new UserRepo();
  userRepo.client = client;
  const createdUserResult = await userRepo.create(parameter);

  assertEquals(createdUserResult.username, parameter.username);
  assertEquals(createdUserResult.password, parameter.password);
  assert(v4.validate(createdUserResult.id!));
  assertMatch(
    createdUserResult.registrationDate!,
    /[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}\.[\d]{1,3}Z/,
  );

  queryStub.restore();
});

test("UserRepo #create should throw exception given no value for field when create", async () => {
  const parameter: IUser = {
    username: "",
    password: "",
  };

  const userRepo = new UserRepo();

  assertThrowsAsync(async () => {
    await userRepo.create(parameter)
  }, InvalidedParamsException,
  "should supply valid username and password!")
});

```

因为`Repository`层要和数据库打交道，所以需要一个和数据库操作相应的处理工具库；在此我们期望通过使用`PostgreSql`自己的的`Client`来执行数据库操作。

在上面第一个测试代码中， 我们`mock`了`Client`的`query`方法，并且返回了预定的数据。接着调用`UserRepo`的`create`方法，判断返回数据的数据字段值与期望值是否一致。

运行测试依旧会失败，接下来以最简单的方式实现让测试通过。

导入`PostgreSql`相关的依赖；

```ts
export { Client } from "https://deno.land/x/postgres/mod.ts";
```

及定义数据库连接信息

```ts
// src/config.ts
export const DB_HOST = env.DB_HOST || "localhost";
export const DB_USER = env.DB_USER || "postgres";
export const DB_PASSWORD = env.DB_PASSWORD || "0";
export const DB_DATABASE = env.DB_DATABASE || "postgres";
export const DB_PORT = env.DB_PORT ? parseInt(env.DB_PORT) : 5432;

```

获取数据库连接的`Client`实例

```ts
// src/Utils/client.ts
import { Client } from "../../deps.ts";
import {
  DB_HOST,
  DB_DATABASE,
  DB_PORT,
  DB_USER,
  DB_PASSWORD,
} from "../config.ts";

const client = new Client({
  hostname: DB_HOST,
  database: DB_DATABASE,
  user: DB_USER,
  password: DB_PASSWORD,
  port: DB_PORT,
});

export default client;

```

数据库应该在应用启动时连接，所以在`index.ts`引入`client`并建立连接和管理连接。

```ts
if (import.meta.main) {
+  await client.connect();
+  console.info("数据库链接成功！");
   const app = await createApplication();
   await listenToServer(app);
+  await client.end();
}

```

##### 重新启动测试

```shell
❯ make test
deno test --allow-env --allow-net -L info
Check file:///xxx/deno-restful-api-with-postgresql-tdd/.deno.test.ts
running 8 tests
test should work ... ok (2ms)
test UserRepo #create should return mocked User given username&password when create ... ok (1ms)
test UserRepo #create should throw exception given no value for field when create ... ok (1ms)
test UserController #addUser should return added user when add user ... ok (14ms)
test UserController #addUser should throw exception about no params given no params when add user ... ok (4ms)
test UserController #addUser should throw exception about no correct params given wrong params when add user ... ok (2ms)
test health check ... ok (3ms)
test UserService #addUser should return added user ... ok (1ms)

test result: ok. 8 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out (28ms)

```

##### 请求体

由`RestClient`验证请求； 现在启动应用，发送如下请求；

```
// _resources/httpClient/addUser.http
POST http://localhost:8000/api/v1/users HTTP/1.1
Content-Type: application/x-www-form-urlencoded

name=foo&password=123

```

##### 请求结果

```
HTTP/1.1 201 Created
content-length: 149
x-response-time: 34ms
content-type: application/json; charset=utf-8

{
  "success": true,
  "data": {
    "username": "foo",
    "password": "123",
    "id": "7aea0bb7-e0bc-4f1f-a516-3a43f4e30fb6",
    "registrationDate": "2020-07-27T14:11:24.140Z"
  }
}
```

异常情况可以自己制造，在此就不演示了，至此完成用户添加的接口。

## 打包

按照上面的步骤，我们可以完成查询单个用户(`GET`:`/users/:id`), 查询所有用户(`GET`:`/users`)和删除(`DELETE`:`/users/:id`)等接口，快速且高效。当我们完成测试和接口后，使用`deno`的命令行工具，我们可以将整个工程打包为一个`.js`文件;

```shell
❯ make bundle
mkdir dist
deno bundle src/index.ts dist/platform.js
Bundle file:///xxx/deno-restful-api-with-postgresql-tdd/src/index.ts
Emit "dist/platform.js" (856.11 KB)

```

对于`NodeJs`开发的后端应用，可怕的`node_modules`依赖在打包时会是个问题，一般的`Node`后端应用都是直接将环境变量更新一下，然后将其部署在生产环境；
开发者写的工程文件并没有多大，而应用依赖的`node_modules`大多时候时工程文件的几十倍甚至几百倍。然后`Deno`很好的解决了这个问题。

## 启动应用

如有需要将打包好的`.js`拷贝到目标目录，只要有`Deno`环境，我们就可以直接启动应用；

```shell
❯ make start 
APP_PORT=1234 deno run --allow-net --allow-env ./dist/platform.js 
数据库链接成功！
Application started, and listen to 127.0.0.1:1234
```

## 乱中取整

通过学习`Deno`,有了一些心得体会；

* 兼容浏览器`API`,`Deno`工程可以使用`Javascript`和`Typescript`进行编程，大大降低了认知复杂度和学习难度；
* 如果使用`Typescript`开发，那么会避免`动态一时爽，重构火葬场`的尴尬局面，所以推荐使用`Typescript`来写应用；
* 去中心化仓库，以单文件的形式分发，在协作开发的时候，为了统一库版本，就需校验依赖的版本，`Deno`提供了生成`lock.json`的形式来保证不同协作者之间的版本依赖；
* ...

最后感谢[海门](https://yihaimen.github.io/)和[亦乐](https://github.com/hylerrix)的校对与指导；在他们的帮助下，我顺利完成了这篇博客。

## Reference

* [源码: https://github.com/guzhongren/deno-restful-api-with-postgresql-tdd](https://github.com/guzhongren/deno-restful-api-with-postgresql-tdd)
* [博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [图床:https://sm.ms/](https://sm.ms/)
* [Denoland: https://deno.land/](https://deno.land/)
* [VS Code: https://code.visualstudio.com/](https://code.visualstudio.com/)
* [Docker: https://www.docker.com/](https://www.docker.com/)
* [Typescript: https://www.typescriptlang.org/](https://www.typescriptlang.org/)
* [Node: https://nodejs.org/](https://nodejs.org/)
* [mock: https://github.com/udibo/mock](https://github.com/udibo/mock)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](/images/wechat/扫码_搜索联合传播样式-标准色版.png)

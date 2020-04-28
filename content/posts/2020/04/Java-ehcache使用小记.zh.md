---
title: "Java Ehcache使用小记"
date: 2020-04-28T22:49:48+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["Java"]
categories: ["cache", "ehcache", "Junit", "CacheManager"]
hiddenFromHomePage: false

featuredImage: "https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
featuredImagePreview: "https://images.pexels.com/photos/2881785/pexels-photo-2881785.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"

toc: true
autoCollapseToc: true
math: true
comment: true
---

在应用开发过程中，我们需要将某些数据临时性的存储在内存中，在一定的时间段内我们可以通过key/value的形式获取，在Java的spring框架中有很多缓存框架，在这我选择使用ehcache,主要是因为该框架方便使用，且提供TTL;

ehcache提供了多种缓存策略，主要分为内存和磁盘两级，所以无需担心容量问题。如果配合TTL ,访问量不大，或者开发环境下完全适用。

下面开始对我使用的标签式和CacheManager两种形式做一记录。

## 基础搭建

不管是标签式还是CacheManager都需要添加dependence, 添加ehcache.xml和数据结构, 所以就直接在前面共用了。

### 添加dependence

需要在pom.xml中加入如下

```xml
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-cache</artifactId>
		</dependency>
		<dependency>
			<groupId>net.sf.ehcache</groupId>
			<artifactId>ehcache</artifactId>
		</dependency>

		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<optional>true</optional>
		</dependency>
```

### 添加ehcache.xml配置文件

ehcache使用需要配合ehcache.xml文件，文件位于src/main/resource文件夹下， 内容如下，name 为cache的名称auth.

```xml
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="ehcache.xsd">

    <cache name="auth"
           maxEntriesLocalHeap="200"
           timeToLiveSeconds="600">
    </cache>

</ehcache>
```
### 数据结构

```java

package com.example.demo.Entity;


import lombok.Data;

@Data
public class CacheEntity {

    private String id;
    private String key;
}

```

#### 标签式

在程序启动处加入标签@EnableCaching， 结果如下

```java
@Slf4j
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
@EnableCaching
public class DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}
}

```

#### 编写cache service代码

这是最终要的部分， 使用Cacheput 将数据缓存在内存中，value="auth"相当于数据缓存存在auth这个内存区域，key="#key"表示，数据索引使用key,根据key 来查找数据。

```java

import com.example.demo.Entity.CacheEntity;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class CacheService {


    @CachePut(value = "auth", key="#key")
    public CacheEntity put(String key, String id, String secret) {
        CacheEntity cacheEntity = new CacheEntity();
        cacheEntity.setId(id);
        cacheEntity.setKey(secret);
        return cacheEntity;
    }

    @Cacheable(value = "auth", key="#key")
    public CacheEntity get(String key) {
        return new CacheEntity();
    }
}
```

#### 测试

对于编写的代码需要进行测试，增强我们编码的信心。

测试使用的是JUnit4

```java

package com.example.demo;

import com.example.demo.Entity.CacheEntity;
import com.example.demo.Serivce.CacheService;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.annotation.Before;
import org.junit.Assert;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@SpringBootTest
@RunWith(SpringRunner.class)
@Slf4j
class DemoApplicationTests {

    @Autowired
    private CacheService cacheService;

    @Before(value = "1")
    public void before() {

    }

    @Test
    void contextLoads() {
        Assert.assertEquals(42, 42);
        System.out.println(42);
    }

    @Test
    void shouldPrint1_whenStart() {
        cacheService.put( "1","1", "1");
        log.info("test");
        for (int i = 0; i < 10; i++) {
            CacheEntity nth = cacheService.get("1");
            log.info("第 {}次， {}", nth, nth.getId());
            Assert.assertEquals("1", nth.getId());
        }
    }

    @Test
    public void shouldFindNullOfId_whenGiveOutScopeKey()  {
        cacheService.put("1", "1", "1");
        CacheEntity cacheEntity = cacheService.get("2");
        Assert.assertEquals(null, cacheEntity.getId());
    }
    @Test
    public void shouldGet3_whenInput1and3()  {
        cacheService.put("1","1", "1");
        cacheService.put("3","3", "3");
        CacheEntity th3 = cacheService.get("3");
        Assert.assertEquals("3", th3.getId());
    }

}

```

### CacheManager形式

给予cacheManager，service和测试都得重写。

#### service

```java
package com.example.demo.Serivce;


import com.example.demo.Entity.CacheEntity;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import net.minidev.json.JSONValue;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;

@Service
@Slf4j
public class CacheService {

    CacheManager cacheManager = new CacheManager("/Users/c4/Downloads/demo/src/main/resources/ehcache.xml");
    Cache cache = cacheManager.getCache("auth");

    public CacheEntity put(String key, String clientId, String clientSecret) {
        CacheEntity cacheEntity = new CacheEntity();
        cacheEntity.setId(clientId);
        cacheEntity.setKey(clientSecret);
        cache.put(new Element(key, cacheEntity));

        return cacheEntity;
    }

    public CacheEntity get(String key) throws JsonProcessingException {
        return new ObjectMapper().readValue(JSONValue.toJSONString(cache.get(key)), CacheEntity.class);
    }

}
```

#### 测试

```java

package com.example.demo;

import com.example.demo.Entity.CacheEntity;
import com.example.demo.Serivce.CacheService;
import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.annotation.Before;
import org.junit.Assert;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@SpringBootTest
@RunWith(SpringRunner.class)
@Slf4j
class DemoApplicationTests {

    @Autowired
    private CacheService cacheService;

    @Before(value = "1")
    public void before() {

    }

    @Test
    void contextLoads() {
        Assert.assertEquals(42, 42);
        System.out.println(42);
    }

    @Test
    void shouldPrint1_whenStart() throws JsonProcessingException {
        cacheService.put( "1","1", "1");
        log.info("test");
        for (int i = 0; i < 10; i++) {
            CacheEntity nth = cacheService.get("1");
            log.info("第 {}次， {}", nth, nth.getId());
            Assert.assertEquals("1", nth.getId());
        }
    }

    @Test
    public void shouldFindNullOfId_whenGiveOutScopeKey() throws JsonProcessingException {
        cacheService.put("1", "1", "1");
        CacheEntity cacheEntity = cacheService.get("2");
        Assert.assertEquals(null, cacheEntity.getId());
    }
    @Test
    public void shouldGet3_whenInput1and3() throws JsonProcessingException {
        cacheService.put("1","1", "1");
        cacheService.put("3","3", "3");
        CacheEntity th3 = cacheService.get("3");
        Assert.assertEquals("3", th3.getId());
    }

}
```


## Reference

* [1.博客:https://guzhongren.github.io/](https://guzhongren.github.io/)
* [2.图床:https://sm.ms/](https://sm.ms/)
* [3.Spring-cache: https://spring.io/guides/gs/caching/](https://spring.io/guides/gs/caching/)

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)

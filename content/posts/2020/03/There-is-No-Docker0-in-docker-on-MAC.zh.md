---
title: "There is No Docker0 in docker on MAC"
date: 2020-03-10T21:19:05+08:00
draft: false
author: "谷中仁"
authorLink: "https://guzhongren.github.io"
description: ""
license: "Creative Commons Attribution 4.0 International license"

tags: ["docker", "container", "mac", "network", "docker0", "sidecar", "host"]
categories: ["container"]
hiddenFromHomePage: false

featuredImage: "https://www.docker.com/sites/default/files/d8/2019-04/any-appplication.jpg"
featuredImagePreview: "https://www.docker.com/sites/default/files/d8/2019-04/any-appplication.jpg"

toc: true
autoCollapseToc: true
math: true
comment: true
---

## 事发经过

今天在工作的时候，我们有一个sidecar, 所有的请求都先要到sidecar里经过鉴权，如果鉴权通过没sidecar 会将请求转发到真正的程序，然后再将结果由sidecar 转发出去，
而现在我需要调试sidecar, 我的外部程序正常启动，但是sidecar 是由另一个同事写的，并且由已经打包好的镜像， 那么我直接在本地与docker 进行host网桥对接，那么三个程序就可以一起已来了。多么美好的想法啊。


## 处理

在上面的想法的基础上，进行了实践，将docker-compose中 sidecar的网络（network_mode）设置为了 `host`, 

```yaml
network_mode: "host"
```
然而在请求时，找不到对应的IP。
查找原因

```shell
c4@TW  ~/   blog  ifconfig  
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
        options=1203<RXCSUM,TXCSUM,TXSTATUS,SW_TIMESTAMP>
        inet 127.0.0.1 netmask 0xff000000 
        inet6 ::1 prefixlen 128 
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1 
        nd6 options=201<PERFORMNUD,DAD>
gif0: flags=8010<POINTOPOINT,MULTICAST> mtu 1280
stf0: flags=0<> mtu 1280
en5: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        ether ac:de:48:00:11:22 
        inet6 fe80::xxx:48ff:fe00:1122%en5 prefixlen 64 scopeid 0x4 
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect (100baseTX <full-duplex>)
        status: active
ap1: flags=8802<BROADCAST,SIMPLEX,MULTICAST> mtu 1500
        options=400<CHANNEL_IO>
        ether f2:18:xx:54:52:1e 
        media: autoselect
        status: inactive
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        options=400<CHANNEL_IO>
        ether f0:18:98:54:52:1e 
        inet6 fe80::xx:f719:eeb5:dfb9%en0 prefixlen 64 secured scopeid 0x6 
        inet 192.168.31.91 netmask 0xffffff00 broadcast 192.168.31.255
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect
        status: active
p2p0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 2304
        options=400<CHANNEL_IO>
        ether 02:18:98:54:52:1e 
        media: autoselect
        status: inactive
awdl0: flags=8943<UP,BROADCAST,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1484
        options=400<CHANNEL_IO>
        ether 0a:xx:ca:15:5b:c5 
        inet6 fe80::8aa:caff:fe15:5bc5%awdl0 prefixlen 64 scopeid 0x8 
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect
        status: active
llw0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        options=400<CHANNEL_IO>
        ether 0a:xx:ca:15:5b:c5 
        inet6 fe80::8aa:caff:fe15:5bc5%llw0 prefixlen 64 scopeid 0x9 
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect
        status: active
en1: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
        options=460<TSO4,TSO6,CHANNEL_IO>
        ether 82:xx:de:8b:38:01 
        media: autoselect <full-duplex>
        status: inactive
en2: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
        options=460<TSO4,TSO6,CHANNEL_IO>
        ether 82:xx:de:8b:38:00 
        media: autoselect <full-duplex>
        status: inactive
en3: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
        options=460<TSO4,TSO6,CHANNEL_IO>
        ether 82:xx:de:8b:38:05 
        media: autoselect <full-duplex>
        status: inactive
en4: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 1500
        options=460<TSO4,TSO6,CHANNEL_IO>
        ether 82:xx:de:8b:38:04 
        media: autoselect <full-duplex>
        status: inactive
bridge0: flags=8822<BROADCAST,SMART,SIMPLEX,MULTICAST> mtu 1500
        options=63<RXCSUM,TXCSUM,TSO4,TSO6>
        ether 82:23:de:8b:38:01 
        Configuration:
                id 0:0:0:0:0:0 priority 0 hellotime 0 fwddelay 0
                maxage 0 holdcnt 0 proto stp maxaddr 100 timeout 1200
                root id 0:0:0:0:0:0 priority 0 ifcost 0 port 0
                ipfilter disabled flags 0x2
        member: en1 flags=3<LEARNING,DISCOVER>
                ifmaxaddr 0 port 10 priority 0 path cost 0
        member: en2 flags=3<LEARNING,DISCOVER>
                ifmaxaddr 0 port 11 priority 0 path cost 0
        member: en3 flags=3<LEARNING,DISCOVER>
                ifmaxaddr 0 port 12 priority 0 path cost 0
        member: en4 flags=3<LEARNING,DISCOVER>
                ifmaxaddr 0 port 13 priority 0 path cost 0
        media: <unknown type>
        status: inactive
utun0: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1380
        inet6 fe80::xxxx:1af1:10a7:18f4%utun0 prefixlen 64 scopeid 0xf 
        nd6 options=201<PERFORMNUD,DAD>
utun1: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 2000
        inet6 xxxx::ecd9:69a7:bac4:865a%utun1 prefixlen 64 scopeid 0x10 
        nd6 options=201<PERFORMNUD,DAD>
gpd0: flags=8862<BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1400
        ether xx:50:41:00:01:01 
        inet 10.202.103.219 netmask 0xffffffff broadcast 10.202.103.219
utun2: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1380
        inet6 xxxx::92bd:7d57:a05b:e978%utun2 prefixlen 64 scopeid 0x12 
        nd6 options=201<PERFORMNUD,DAD>
utun3: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1380
        inet6 xxxx::1920:c84d:763d:6dca%utun3 prefixlen 64 scopeid 0x13 
        nd6 options=201<PERFORMNUD,DAD>

```
贴这么多code ，其实没有什么用，因为里面没有docker0这个网络。那么我们怎么可以让外部的程序访问容器呢。

> 在使用 Docker 时，要注意平台之间实现的差异性，如 Docker For Mac 的实现和标准 Docker 规范有区别，Docker For Mac 的 Docker Daemon 是运行于虚拟机 (xhyve) 中的，而不是像 Linux 上那样作为进程运行于宿主机，因此 Docker For Mac 没有 docker0 网桥，不能实现 host 网络模式，host 模式会使 Container 复用 Daemon 的网络栈 (在 xhyve 虚拟机中)，而不是与 Host 主机网络栈，这样虽然其它容器仍然可通过 xhyve 网络栈进行交互，但却不是用的 Host 上的端口 (在 Host 上无法访问)

> Use your internal IP address or connect to the special DNS name host.docker.internal which will resolve to the internal IP address used by the host.


## 总结如下

* docker 在 mac 和 windows上是运行在虚拟机（`xhyve`）上的，所以网络是由问题的，如果指定host， 那么也是在访问虚拟机上的host, 并不是主机上的host。
* docker 在linux 上是利用namespace进行资源划分的。
* > docker 18.03 加入了一个 feature，在容器中可以通过 host.docker.internal 来访问主机

## 结论

在mac上如果容器要访问主机上的资源，需要在容器中的应用只指定主机的域名`host.docker.internal`。

## Reference

[1.https://learnku.com/articles/33046/](https://learnku.com/articles/33046/)
[2.https://github.com/docker/for-linux/issues/264](https://github.com/docker/for-linux/issues/264)

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)
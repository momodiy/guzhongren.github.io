# Harbor 安装小记

## 场景
 
在搭建私有云环境时，我们需要将我们打包的镜像存储在局域网内，而不是把镜像推送到hub.docker.com；一方面是因为安全问题，另一方面在局域网内存储，网速炒鸡快。当然对于私有云搭建，在本地搭建镜像仓库那是必须的。接下来，对我安装Harbor 做一个记录。

## 分析

因为 Harbor 是用 docker 跑起来的，所以我们的机器上必须有 docker 环境，还有比较中要的一点，Harbor 需要使用docker-compose, 所以需要 docker-compose。

## 安装

### docker 安装

略...（相信你肯定不会怪我）

### docker-compose 安装

```shell
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
docker-compose version 1.24.0, build 1110ad01
```
### 安装Harbor

> 离线安装版

#### 获取并解压
```shell
$ wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.0.tgz
$ tar xvf harbor-offline-installer-v1.8.0.tgz
```
解压会生成 Harbor 文件夹

#### 修改配置文件

```shell
$ cd Harbor
$ vim /Harbor.yaml
```
需要配置的地方有几处，但最重要的是hostname, hostname 必须指定为域名，不能使localhost,127.0.0.1 这样的地址，别的密码、端口可可定义。如下是我的配置

```yaml
# Configuration file of Harbor

# The IP address or hostname to access admin UI and registry service.
# DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: hub.k8s.com

# http related config
http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
  port: 80

# https related config
# https:
#   # https port for harbor, default is 443
#   port: 443
#   # The path of cert and key files for nginx
#   certificate: /your/certificate/path
#   private_key: /your/private/key/path

# Uncomment external_url if you want to enable external proxy
# And when it enabled the hostname will no longer used
# external_url: https://reg.mydomain.com:8433

# The initial password of Harbor admin
# It only works in first time to install harbor
# Remember Change the admin password from UI after launching Harbor.
harbor_admin_password: Harbor12345

# Harbor DB configuration
database:
  # The password for the root user of Harbor DB. Change this before any production use.
  password: root123

# The default data volume
data_volume: /data

# Harbor Storage settings by default is using /data dir on local filesystem
# Uncomment storage_service setting If you want to using external storage
# storage_service:
#   # ca_bundle is the path to the custom root ca certificate, which will be injected into the truststore
#   # of registry's and chart repository's containers.  This is usually needed when the user hosts a internal storage with self signed certificate.
#   ca_bundle:

#   # storage backend, default is filesystem, options include filesystem, azure, gcs, s3, swift and oss
#   # for more info about this configuration please refer https://docs.docker.com/registry/configuration/
#   filesystem:
#     maxthreads: 100
#   # set disable to true when you want to disable registry redirect
#   redirect:
#     disabled: false

# Clair configuration
clair:
  # The interval of clair updaters, the unit is hour, set to 0 to disable the updaters.
  updaters_interval: 12

  # Config http proxy for Clair, e.g. http://my.proxy.com:3128
  # Clair doesn't need to connect to harbor internal components via http proxy.
  http_proxy:
  https_proxy:
  no_proxy: 127.0.0.1,localhost,core,registry

jobservice:
  # Maximum number of job workers in job service
  max_job_workers: 10

chart:
  # Change the value of absolute_url to enabled can enable absolute url in chart
  absolute_url: disabled

# Log configurations
log:
  # options are debug, info, warning, error, fatal
  level: info
  # Log files are rotated log_rotate_count times before being removed. If count is 0, old versions are removed rather than rotated.
  rotate_count: 50
  # Log files are rotated only if they grow bigger than log_rotate_size bytes. If size is followed by k, the size is assumed to be in kilobytes.
  # If the M is used, the size is in megabytes, and if G is used, the size is in gigabytes. So size 100, size 100k, size 100M and size 100G
  # are all valid.
  rotate_size: 200M
  # The directory on your host that store log
  location: /var/log/harbor

#This attribute is for migrator to detect the version of the .cfg file, DO NOT MODIFY!
_version: 1.8.0

# Uncomment external_database if using external database. Currently only support POSTGRES.
# Four databases are needed to be create first by users for Harbor core, Clair, Notary server
# and Notary signer. And the tables will be generated automatically when Harbor starting up.
# NOTE: external_database is unable to custom attributes individually, you must do them in block.
# external_database:
#   harbor:
#     host: harbor_db_host
#     port: harbor_db_port
#     db_name: harbor_db_name
#     username: harbor_db_username
#     password: harbor_db_password
#     ssl_mode: disable
#   clair:
#     host: clair_db_host
#     port: clair_db_port
#     db_name: clair_db_name
#     username: clair_db_username
#     password: clair_db_password
#     ssl_mode: disable
#   notary_signer:
#     host: notary_signer_db_host
#     port: notary_signer_db_port
#     db_name: notary_signer_db_name
#     username: notary_signer_db_username
#     password: notary_signer_db_password
#     ssl_mode: disable
#   notary_server:
#     host: notary_server_db_host
#     port: notary_server_db_port
#     db_name: notary_server_db_name
#     username: notary_server_db_username
#     password: notary_server_db_password
#     ssl_mode: disable

# Uncomment external_redis if using external Redis server
# external_redis:
#   host: redis
#   port: 6379
#   password:
#   # db_index 0 is for core, it's unchangeable
#   registry_db_index: 1
#   jobservice_db_index: 2
#   chartmuseum_db_index: 3

# Uncomment uaa for trusting the certificate of uaa instance that is hosted via self-signed cert.
# uaa:
#   ca_file: /path/to/ca
```

#### 执行安装

```shell
$ ./install.sh
......
Creating harbor-portal     ... done
Creating nginx             ... done

 ----Harbor has been installed and started successfully.----

Now you should be able to visit the admin portal at http://hub.k8s.com.
For more details, please visit https://github.com/goharbor/harbor .
```
最后出现如上提示就安装成功了。将hub.k8s.com解析到本地即可访问。

![harbor](https://i.loli.net/2020/03/29/yhiqAI93LSwzVtk.jpg)

### 配置/etc/docker/daemon.json

> 配置此项的目的是让 docker push 可以将镜像推送到私有仓库中

```shell
$ vim /etc/docker/daemon.json
{
  "registry-mirrors": ["https://gmjjwogo.mirror.aliyuncs.com"],
  "insecure-registries": ["hub.k8s.com"] # 追加内容，必须符合json规范
}
```

#### 重启 docker 

```shell
$ systemctl restart docker
```
#### 将本地golang 镜像推送到私有仓库

```shell
$ docker login hub.k8s.com
Username: admin
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```
#### 为golang 打标签并推送镜像

```shell
$ docker tag golang:alpine hub.k8s.com/cms/golang:alpine
$  docker push hub.k8s.com/cms/golang:alpine
The push refers to repository [hub.k8s.com/cms/golang]
23419e186866: Pushed
1f6ba46a9c52: Pushed
968d46c1d20e: Pushed
b87598efb2f0: Pushed
f1b5933fe4b5: Pushed
alpine: digest: sha256:5ec3232b32e6876c0941d66d8392f667c77ca1ef14cafb85991deea4339b92da size: 1365
```

## 小结

Harbor 是一个 docker 镜像私有仓库的解决方案，是基于 docker-compose 运行起来的，使用相对简单。



## Reference

* [1.博客：https://guzhongren.github.io/](https://guzhongren.github.io/)*

## Hereby declared（特此申明）

本文仅代表个人观点，与[ThoughtWorks](https://www.thoughtworks.com/) 公司无任何关系。

----
![谷哥说-微信公众号](https://ftp.bmp.ovh/imgs/2020/02/b7282c60d4d581ad.png)


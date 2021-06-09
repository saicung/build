# 如何快速搭建梯子服务 ?

> 该脚本目前仅支持 CentOS 操作系统，否则的无法使用 `yum` 等命令。如有疑问可以提交 Issues。

在开始之前，请确保部署的服务器上已存在 docker-compose 命令，在运行时也会对该命令的检查并给予安装部署。
可参考 [Install Docker Compose](https://docs.docker.com/compose/install/)

该脚本支持 ipsec 和 shadowsocks，可以看到该脚本的用法：

```bash
[root@leaZh data]# ./build.sh 

用法: 
    $PROGRAM [ -h --help -?  查看帮助 ]
            [ -d, --data_dir     [可选] 挂载目录, 默认为 /data/ladder]
            [ -t --type          [必填] 选择部署 ladder 的类型  ipsec and shadowsocks ]
            [ -p, --port         [可选] shadowsocks 服务端口, 默认为 20105 ]
            [ -i                 [可选] ipsec 服务端口1, 默认为 500 ]
            [ -I                 [可选] ipsec 服务端口2, 默认为 4500 ]
            [ -u, --user         [可选] 除 admin 用户外的用户, 默认为空 ]
            [ -P, --password     [可选] 新增帐户的密码, 默认为空 ]
            [ -v, --version      [可选] 查看脚本版本号 ]
```

## 搭建 ipsec 服务

> 首次建议按默认部署

构建 ipsec，可以使用以下命令：

```bash
# 一切都会按默认进行  
./build.sh -t ipsec
```

如果你想自定义一些东西，可以尝试如下命令：

```bash
# 请根据实际情况替换 <> 的内容
./build.sh -d </data/server> -t ipsec -i <501> -I <4501> -u <ascmcs> -P <123456>
```

- 除此之外，你还需要保证该端口是已放通可访问的。

## 搭建 shadowsocks 服务

> 首次建议按默认部署

构建 shadowsocks，可以使用以下命令：

```bash
# 一切都会按默认进行  
./build.sh -t shadowsocks
```

如果你想自定义一些东西，可以尝试如下命令:

```bash
# 请根据实际情况替换 <> 的内容
./build.sh -d </data/server> -t shadowsocks -p <20106>
```

除此之外，你还需要保证该端口是已放通可访问的。

- [shadowsocks 客户端下载 ](https://github.com/shadowsocks)
- [ipsec 如何新增帐户?](./add_user.md)
- [配置客户端](./setting_client.md)

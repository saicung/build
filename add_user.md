# ipsec_vpn 如何新增帐户?

这里均以默认的目录 `/data/vpn` 为例，如已修改过目录，请以实际的为准。

## 新增帐户

```bash
vim /data/vpn/ipsec_vpn/config/vpn.env

# 在下列两个变量处进行添加，多个用户密码请使用空格分隔
VPN_ADDL_USERS=leazh leazh1
VPN_ADDL_PASSWORDS=123456 123456
```

添加完成后，需要重启下，请以此执行下列命令：

```bash
cd /data/vpn/ipsec_vpn
docker-compose down
docker-compose up -d ipsec_vpn
```

查看帐户信息：

```bash
docker-compose logs ipsec_vpn

# 关键字样
Server IP: 
IPsec PSK: 
Username: admin
Password: 
Additional VPN users (username | password):
leazh | 123456
leazh1 | 123456
```

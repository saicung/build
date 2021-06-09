#!/bin/bash
# Build the Ladder Script
# Author ascmcs

VERSION=1.0
PREFIX=/data/ladder
SHADS_SERVER_PORT=20105
IPSEC_PORT1=500
IPSEC_PORT2=4500
TYPE=
USER_NAME=
USER_PASSWORD=

usage () {
    cat << EOF
用法:
    $PROGRAM [ -h --help -?  查看帮助 ]
            [ -d, --data_dir     [可选] 挂载目录, 默认为 /data/ladder ]
            [ -t --type          [必填] 选择部署 ladder 的类型  ipsec and shadowsocks ]
            [ -p, --port         [可选] shadowsocks 服务端口, 默认为 20105 ]
            [ -i                 [可选] ipsec 服务端口1, 默认为 500 ]
            [ -I                 [可选] ipsec 服务端口2, 默认为 4500 ]
            [ -u, --user         [可选] 除 admin 用户外的用户, 默认为空 ]
            [ -P, --password     [可选] 新增帐户的密码, 默认为空 ]
            [ -v, --version      [可选] 查看脚本版本号 ]
EOF
}

red_echo ()      { [ "$HASTTY" == 0 ] && echo "$@" || echo -e "\033[031;1m$@\033[0m"; }
green_echo ()    { [ "$HASTTY" == 0 ] && echo "$@" || echo -e "\033[032;1m$@\033[0m"; }
yellow_echo ()   { [ "$HASTTY" == 0 ] && echo "$@" || echo -e "\033[033;1m$@\033[0m"; }
blue_echo ()     { [ "$HASTTY" == 0 ] && echo "$@" || echo -e "\033[034;1m$@\033[0m"; }

usage_and_exit () {
    usage
    exit "$1"
}

rndpw () {
    </dev/urandom tr -dc _A-Za-z0-9"$2" | head -c"${1:-12}"
}

version () {
    echo "$PROGRAM version $VERSION"
}

(( $# == 0 )) && usage_and_exit 1
while (( $# > 0 )); do
    case "$1" in
        -d | --data_dir )
            shift
            PREFIX=$1
            ;;
        -p | --port )
            shift
            SHADS_SERVER_PORT=$1
            ;;
        -i)
            shift
            IPSEC_PORT1=$1
            ;;
        -I)
            shift
            IPSEC_PORT2=$1
            ;;
        -u | --user )
            shift
            USER_NAME=$1
            ;;
        -P | --password)
            shift
            USER_PASSWORD=$1
            ;;
        -t | --type )
             shift
             TYPE=$1
             ;;
        --help | -h | '-?' )
            usage_and_exit 0
            ;;
        --version | -v | -V )
            version
            exit 0
            ;;
        -*)
            error "不可识别的参数: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ "$(whoami)" != "root" ]
then
    red_echo "You must run by root"
    exit 1
fi

if [[ -z "$TYPE" ]]; then
    red_echo "类型不能为空"
    usage
    exit 1
fi

if ! which docker-compose
then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    version=$(docker-compose --version)
    blue_echo "$version"
fi

if ! yum list installed  | grep docker > /dev/null
then
    if ! yum install -y docker-ce;
    then
        red_echo "yum cannot install docker command, please check it"
        exit 1
    fi
fi

if ! [[ -d "$PREFIX" ]]; then
    red_echo "$PREFIX directory  is not exists"
    read -rp "are you sure to create it (y/n)? " r
    if [ "$r" == "y" ]; then
        install -m 755 -d "$PREFIX"
    else
        red_echo "Abort, Please create the directory($PREFIX) before deploymenet"
        exit 1
    fi
fi

deploymenet_ipsec () {

    local admin_pw ipsec_psk tmp_file

    ipsec_psk="$(rndpw 20)"
    admin_pw="$(rndpw 16)"
    tmp_file=$(mktemp "/tmp/ipsec_XXXXX.env")

    install -m 755 -d "$PREFIX"/"$TYPE"/config
    install -m 755 -d "$PREFIX"/"$TYPE"/data

    docker pull hwdsl2/ipsec-vpn-server

    cd "$PREFIX"/"$TYPE" || exit

    cat > "$PREFIX/$TYPE/config/ipsec.env" << EOF

# 主要信息
VPN_IPSEC_PSK=$ipsec_psk
VPN_USER=admin
VPN_PASSWORD=$admin_pw

# 额外用户
VPN_ADDL_USERS=$USER_NAME
VPN_ADDL_PASSWORDS=$USER_PASSWORD

sha2-truncbug=yes
VPN_SETUP_IKEV2=yes

EOF

    cat > "$PREFIX/$TYPE/docker-compose.yml" << EOF
version: '3.6'
services:

  ipsec:
    image: hwdsl2/ipsec-vpn-server
    container_name: $TYPE
    ports:
      - $IPSEC_PORT1:$IPSEC_PORT1/udp
      - $IPSEC_PORT2:$IPSEC_PORT2/udp
    volumes:
      - $PREFIX/$TYPE/data:/etc/ipsec.d
    env_file:
      - $PREFIX/$TYPE/config/ipsec.env
    restart: always
    privileged: true

EOF

    cd "$PREFIX"/"$TYPE" && docker-compose up -d "$TYPE"
    blue_echo "提取相关信息中，请稍等……"
    sleep 10
    docker logs "$TYPE" > "$tmp_file" 2>&1
    server_info=$(grep -E "^Server IP|^IPsec PSK|^Username|^Password" "$tmp_file")
    blue_echo "ipsec 信息如下，请注意保存及防止泄露，也可以通过 docker logs ipsec 查看详细信息。"
    echo "$server_info"

#    docker run --name ipsec --env-file "$PREFIX"/"$TYPE"/config/ipsec.env --restart=always -v "$PREFIX"/"$TYPE"/data:/etc/ipsec.d -p $IPSEC_PORT1:$IPSEC_PORT1/udp -p $IPSEC_PORT2:$IPSEC_PORT2/udp -d --privileged hwdsl2/ipsec-vpn-server
}

deploymenet_shadowsocks () {

    local shds_ip shds_password
    shds_ip=$(curl ip.sb)
    shds_password=$(rndpw 16)

    install -m 755 -d "$PREFIX"/"$TYPE"
    install -m 755 -d  /etc/shadowsocks

    docker pull teddysun/shadowsocks-libev

    cd "$PREFIX"/"$TYPE" || exit

    cat > /etc/shadowsocks/config.json <<  EOF
{
    "server":"0.0.0.0",
    "server_port":$SHADS_SERVER_PORT,
    "password":"$shds_password",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false,
    "mode":"tcp_and_udp"
}
EOF

    cat > "$PREFIX/$TYPE/docker-compose.yml" << EOF
version: '3.6'
services:

  shadowsocks:
    image: teddysun/shadowsocks-libev
    container_name: $TYPE
    ports:
      - $SHADS_SERVER_PORT:$SHADS_SERVER_PORT/udp
      - $SHADS_SERVER_PORT:$SHADS_SERVER_PORT
    volumes:
      - /etc/shadowsocks:/etc/shadowsocks-libev
    restart: always

EOF

    cd "$PREFIX"/"$TYPE" && docker-compose up -d "$TYPE"

    blue_echo "提取相关信息中，请稍等……"
    blue_echo "shadowsocks 信息如下，请注意保存及防止泄露，也可以通过查看 shadowsocks 的配置文件 config.json。"
    cat << EOF
    Server   IP：        $shds_ip
    Server Port：        $SHADS_SERVER_PORT
    Server Password:     $shds_password
    Server Method:       aes-256-gcm
EOF
#    docker run -d -p "$SHADS_SERVER_PORT":"$SHADS_SERVER_PORT" -p "$SHADS_SERVER_PORT":"$SHADS_SERVER_PORT"/udp --name shadowsocks --restart=always -v "$PREFIX"/"$TYPE"/shadowsocks:/etc/shadowsocks-libev teddysun/shadowsocks-libev
}

if [[ "$TYPE" == "ipsec" ]]; then
    deploymenet_ipsec
elif [ "$TYPE" == "shadowsocks" ]; then
    deploymenet_shadowsocks
else
    red_echo "不支持的类型 $TYPE"
    exit 1
fi

#!/bin/bash
# Build the VPN Script
# Author leazh

VERSION=1.0
PREFIX=/data/vpn
SHADS_SERVER_PORT=20105
IPSEC_PORT1=500
IPSEC_PORT2=4500
VPN_TYPE=
USER_NAME=
USER_PASSWORD=

usage () {
    cat << EOF
用法: 
    $PROGRAM [ -h --help -?  查看帮助 ]
            [ -d, --data_dir     [可选] 挂载目录, 默认为 /data/vpn ]
            [ -t --type          [必填] 选择部署 vpn 的类型  ipsec_vpn and shadowsocks ]
            [ -p, --port         [可选] shadowsocks 服务端口, 默认为 20105 ]
            [ -i                 [可选] ipsec_vpn 服务端口1, 默认为 500 ]
            [ -I                 [可选] ipsec_vpn 服务端口2, 默认为 4500 ]
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
             VPN_TYPE=$1
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

if [[ -z "$VPN_TYPE" ]]; then
    red_echo "VPN 类型不能为空"
    usage
    exit 1
fi

if ! yum list installed  | grep docker > /dev/null
then 
    if ! yum install -y docker-ce;
    then
        red_echo "yum cannot install docker command"
        exit 1
    fi
fi

if ! [[ -d "$PREFIX" ]]; then
    red_echo "$PREFIX 目录不存在"
    
    read -rp "\"$PREFIX\" directory  is not exists, are you sure to create it (y/n)? " r
    if [ "$r" == "y" ]; then
        install -m 755 -d "$PREFIX"
    else
        red_echo "Abort, Please create the directory($PREFIX) before deploymenet"
        exit 1
    fi
fi

deploymenet_vpn () {

    local vpn_admin_pw vpn_ipsec_psk

    vpn_ipsec_psk="$(rndpw 20)"
    vpn_admin_pw="$(rndpw 16)"

    install -m 755 -d "$PREFIX"/"$VPN_TYPE"/config
    install -m 755 -d "$PREFIX"/"$VPN_TYPE"/data
    
    docker pull hwdsl2/ipsec-vpn-server

    cd "$PREFIX"/"$VPN_TYPE" || exit

    cat > "$PREFIX/$VPN_TYPE/config/vpn.env" << EOF

# 主要信息
VPN_IPSEC_PSK=$vpn_ipsec_psk
VPN_USER=admin
VPN_PASSWORD=$vpn_admin_pw

# 额外用户
VPN_ADDL_USERS=$USER_NAME
VPN_ADDL_PASSWORDS=$USER_PASSWORD

sha2-truncbug=yes
VPN_SETUP_IKEV2=yes
    
EOF

    cat > "$PREFIX/$VPN_TYPE/docker-compose.yml" << EOF
version: '3.6'
services:

  ipsec_vpn:
    image: hwdsl2/ipsec-vpn-server
    container_name: $VPN_TYPE
    ports:
      - $IPSEC_PORT1:$IPSEC_PORT1/udp
      - $IPSEC_PORT2:$IPSEC_PORT2/udp
    volumes:
      - $PREFIX/$VPN_TYPE/data:/etc/ipsec.d
    env_file:
      - $PREFIX/$VPN_TYPE/config/vpn.env
    restart: always

EOF
    
    docker-compose up -d "$VPN_TYPE"
#    docker run --name vpn_server --env-file "$PREFIX"/"$VPN_TYPE"/config/vpn.env --restart=always -v "$PREFIX"/"$VPN_TYPE"/data:/etc/ipsec.d -p $IPSEC_PORT1:$IPSEC_PORT1/udp -p $IPSEC_PORT2:$IPSEC_PORT2/udp -d --privileged hwdsl2/ipsec-vpn-server
}


deploymenet_shadowsocks_vpn () {
    
    install -m 755 -d "$PREFIX"/"$VPN_TYPE"
    
    docker pull teddysun/shadowsocks-libev

    cd "$PREFIX"/"$VPN_TYPE" || exit

    cat > "$PREFIX"/"$VPN_TYPE"/config.json <<  EOF
{
    "server":"0.0.0.0",
    "server_port":$SHADS_SERVER_PORT,
    "password":"$(rndpw 16)",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false,
    "mode":"tcp_and_udp"
}
EOF

    cat > "$PREFIX/$VPN_TYPE/docker-compose.yml" << EOF
version: '3.6'
services:

  shadowsocks:
    image: teddysun/shadowsocks-libev
    container_name: $VPN_TYPE
    ports:
      - $SHADS_SERVER_PORT:$SHADS_SERVER_PORT/udp
      - $SHADS_SERVER_PORT:$SHADS_SERVER_PORT
    volumes:
      - $PREFIX/$VPN_TYPE:/etc/shadowsocks-libev
    restart: always
    privileged: true

EOF
    
    docker-compose up -d "$VPN_TYPE"

#    docker run -d -p "$SHADS_SERVER_PORT":"$SHADS_SERVER_PORT" -p "$SHADS_SERVER_PORT":"$SHADS_SERVER_PORT"/udp --name shadowsocks --restart=always -v "$PREFIX"/"$VPN_TYPE"/shadowsocks:/etc/shadowsocks-libev teddysun/shadowsocks-libev
}

if [[ "$VPN_TYPE" == "ipsec_vpn" ]]; then
    deploymenet_vpn
elif [ "$VPN_TYPE" == "shadowsocks" ]; then
    deploymenet_shadowsocks_vpn
else
    red_echo "不支持的 VPN 类型 $VPN_TYPE"
    exit 1
fi

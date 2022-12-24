#!/bin/sh

# install
if [ ! -f XrayR ];then
  wget -q https://github.com/XrayR-project/XrayR/releases/download/v0.8.4/XrayR-linux-64.zip
	busybox unzip -o XrayR-linux-64.zip
  chmod +x ./XrayR
fi

FILES_PATH=${FILES_PATH:-./}

cat << EOF > /tmp/config.yml
Log:
  Level: info 
  AccessPath: 
  ErrorPath: 
DnsConfigPath: 
RouteConfigPath: 
InboundConfigPath:
OutboundConfigPath:
ConnetionConfig:
  Handshake: 4
  ConnIdle: 30
  UplinkOnly: 2
  DownlinkOnly: 4
  BufferSize: 64
Nodes:
  -
    PanelType: "${PANELTYPE}"
    ApiConfig:
      ApiHost: "${APIHOST}"
      ApiKey: "${APIKEY}"
      NodeID: ${NODEID}
      NodeType: V2ray
      Timeout: 30
      EnableVless: false
      EnableXTLS: false
      SpeedLimit: 0
      DeviceLimit: 0
      RuleListPath:
    ControllerConfig:
      ListenIP: 127.0.0.1
      SendIP: 0.0.0.0
      UpdatePeriodic: 60
      EnableDNS: false
      DNSType: AsIs
      EnableProxyProtocol: false
      EnableFallback: false
      FallBackConfigs:
        -
          SNI:
          Alpn: 
          Path: 
          Dest: 80 
          ProxyProtocolVer: 0 
      CertConfig:
        CertMode: none
        CertDomain: "node1.test.com"
        CertFile: /etc/XrayR/cert/node1.test.com.cert
        KeyFile: /etc/XrayR/cert/node1.test.com.key
        Provider: alidns
        Email: test@me.com
        DNSEnv:
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb
EOF

if [ -f $CADDYIndexPage ];then
  CADDYIndexPage="https://github.com/AYJCSGM/mikutap/archive/master.zip"
fi

if [ -f $PORT ];then
  PORT=8080
fi

# configs
mkdir -p $FILES_PATH/share/caddy && echo -e "User-agent: *\nDisallow: /" > $FILES_PATH/share/caddy/robots.txt
wget $CADDYIndexPage -O $FILES_PATH/share/caddy/index.html && busybox unzip -qo $FILES_PATH/share/caddy/index.html -d $FILES_PATH/share/caddy/ && mv $FILES_PATH/share/caddy/*/* $FILES_PATH/share/caddy/
cat "$FILES_PATH/Caddyfile" | sed -e "1c :$PORT" -e "s|/usr|$FILES_PATH|g" >$FILES_PATH/share/Caddyfile


./XrayR -config /tmp/config.yml &

sleep 5

if [[ -n $(pgrep XrayR) ]];then
  echo "\033[32m[INFO]\033[0m XrayR is running"
else
  echo "\033[31m[ERROR]\033[0m XrayR is not running"
  exit 1
fi

port=$(busybox netstat -nltp | grep XrayR | awk '{print $4}' | sed 's/127.0.0.1://g')

sed -i "s/XPORT/${port}/g" ./share/Caddyfile

caddy run --config ./share/Caddyfile --adapter caddyfile
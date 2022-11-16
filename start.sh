#!/bin/sh

cat << EOF > /config.yml
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
      ListenIP: 0.0.0.0
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

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
cat "/Caddyfile" | sed -e "1c :$PORT" >/etc/caddy/Caddyfile


/XrayR -config config.yml &

sleep 5

if [ -n $(pgrep XrayR) ];then
  echo "\033[32m[INFO]\033[0m XrayR is running"
else
  echo "\033[31m[ERROR]\033[0m XrayR is not running"
  exit 1
fi

port=$(netstat -nltp | grep XrayR | awk '{print $4}' | sed 's/://g')

sed -i "s/8080/${port}/g" /etc/caddy/Caddyfile

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
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

if [ ! -f $AUTH ];then
    curl -X POST \
      -H "authorization: ${AUTH}" \
      -d "id=${NODEID}&server_port=${PORT}&${DATA}" \
      "$APIHOST/api/v1/admin/server/v2ray/save"
fi

/XrayR -config config.yml
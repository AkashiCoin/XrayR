FROM alpine:edge

ADD start.sh /start.sh
RUN apk update && \
    apk add --no-cache ca-certificates unzip wget curl && \
    wget -q https://github.com/XrayR-project/XrayR/releases/download/v0.8.4/XrayR-linux-64.zip  && \
	echo "y" | unzip XrayR-linux-64.zip && \
    chmod +x /start.sh /XrayR

EXPOSE 443

ENTRYPOINT ["sh", "-c", "/start.sh"]
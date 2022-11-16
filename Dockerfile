FROM alpine:edge

ADD . /
RUN apk update && \
    apk add --no-cache ca-certificates caddy unzip wget curl && \
    wget -q https://github.com/XrayR-project/XrayR/releases/download/v0.8.4/XrayR-linux-64.zip  && \
	echo "y" | unzip -o XrayR-linux-64.zip && \
    chmod +x /start.sh /XrayR

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "/start.sh"]
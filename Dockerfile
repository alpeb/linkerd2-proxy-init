## compile proxy-init utility
FROM --platform=$BUILDPLATFORM golang:1.18.2-alpine3.14 as golang
WORKDIR /build

# cache dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

# build
COPY pkg pkg
COPY proxy-init proxy-init
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -o /out/linkerd2-proxy-init -mod=readonly -ldflags "-s -w" -v ./proxy-init

## package runtime
FROM --platform=$TARGETPLATFORM alpine:3.16.1
RUN apk add iptables libcap
RUN touch /run/xtables.lock && chmod 0666 /run/xtables.lock
RUN setcap cap_net_raw,cap_net_admin+eip /sbin/xtables-legacy-multi && \
    setcap cap_net_raw,cap_net_admin+eip /sbin/xtables-nft-multi
COPY LICENSE /linkerd/LICENSE
COPY --from=golang /out/linkerd2-proxy-init /usr/local/bin/proxy-init
RUN setcap cap_net_raw,cap_net_admin+eip /usr/local/bin/proxy-init
ENTRYPOINT ["/usr/local/bin/proxy-init"]

USER 65534

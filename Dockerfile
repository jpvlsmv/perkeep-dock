# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-perkeep-dock"
LABEL REPO="https://github.com/jpvlsmv/perkeep-dock"

ENV PROJPATH=/go/src/github.com/jpvlsmv/perkeep-dock

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/jpvlsmv/perkeep-dock
WORKDIR /go/src/github.com/jpvlsmv/perkeep-dock

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/jpvlsmv/perkeep-dock"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/perkeep-dock/bin

WORKDIR /opt/perkeep-dock/bin

COPY --from=build-stage /go/src/github.com/jpvlsmv/perkeep-dock/bin/perkeep-dock /opt/perkeep-dock/bin/
RUN chmod +x /opt/perkeep-dock/bin/perkeep-dock

# Create appuser
RUN adduser -D -g '' perkeep-dock
USER perkeep-dock

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/perkeep-dock/bin/perkeep-dock"]

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND="noninteractive"
RUN --mount=type=tmpfs,target=/tmp                                             \
    --mount=type=cache,sharing=locked,target=/var/cache/apt                    \
    --mount=type=cache,sharing=locked,target=/var/lib/apt                      \
    set -o errexit -o xtrace;                                                  \
    apt-get --yes --quiet update;                                              \
    apt-get --yes --quiet install --no-install-recommends make

ARG GID=1000
ARG UID=1000
ARG GROUP="makephile"
ARG USER="makephile"

RUN --mount=type=tmpfs,target=/tmp                                             \
    set -o errexit -o xtrace;                                                  \
    groupadd --gid $GID "$GROUP";                                              \
    useradd --create-home --shell '/bin/bash' --gid $GID --uid $UID "$USER"

USER $UNAME

COPY . /opt/makephile

WORKDIR /opt/makephile

ENTRYPOINT [ "make" ]

CMD [ "makephile_usage" ]

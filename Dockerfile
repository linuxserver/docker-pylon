FROM ghcr.io/linuxserver/baseimage-alpine:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PYLON_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	g++ \
	make \
	nodejs-npm && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	findutils \
	git \
	nodejs \
	python2 \
	sudo && \
 npm config set unsafe-perm true && \
 echo "**** install Pylon ****" && \
 mkdir -p \
	/app/pylon && \
 if [ -z ${PYLON_RELEASE+x} ]; then \
	PYLON_RELEASE=$(curl -sX GET "https://api.github.com/repos/pylonide/pylon/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/pylon.tar.gz -L \
	"https://github.com/pylonide/pylon/archive/${PYLON_RELEASE}.tar.gz" && \
 tar -xzf \
 /tmp/pylon.tar.gz -C \
	/app/pylon/ --strip-components=1 && \
 ln -s \
	/config/sessions \
	/app/pylon/.sessions && \
 echo "**** install node modules ****" && \
 npm install --prefix /app/pylon && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root \
	/tmp/* && \
 mkdir -p \
	/root

# add local files
COPY root/ /

# ports
EXPOSE 3131

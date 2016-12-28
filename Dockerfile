FROM node:4
MAINTAINER Matt Warren <matt@prattlr.com>

RUN apt-get update
RUN apt-get -y install libicu-dev build-essential

WORKDIR /opt/prattlr
CMD ./bin/hubot -a twitch-adapter

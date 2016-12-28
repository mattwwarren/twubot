FROM node:4
MAINTAINER Matt Warren <matt@prattlr.com>

RUN apt-get update

WORKDIR /opt/prattlr
CMD ./bin/hubot -a twitch-adapter

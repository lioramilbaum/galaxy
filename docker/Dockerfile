FROM docker/whalesay:latest

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
RUN apt-get -y update && apt-get install -y fortunes

CMD /usr/games/fortune -a | cowsay


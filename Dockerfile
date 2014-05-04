# Base image
#
# VERSION   0.1
FROM        paultag/hy:latest
MAINTAINER  Paul R. Tagliamonte <paultag@debian.org>

RUN mkdir -p /opt/hylang/
RUN apt-get update && apt-get install python3-all-dev libev4 libev-dev -y
RUN cd /opt/hylang/; git clone git://github.com/paultag/acid.git
RUN cd /opt/hylang/acid; python3.4 /usr/bin/pip3 install -r requirements.txt
RUN cd /opt/hylang/acid; python3.4 /usr/bin/pip3 install -e .

CMD ["hy"]

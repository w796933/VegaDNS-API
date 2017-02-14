FROM alpine:latest

ENV VEGADNS_CLI master
ENV VEGADNS_API master

ADD . /opt/vegadns
RUN apk --update add python
# Removing these packages in the RUN keeps the image small (~70MB)
RUN apk --update add --virtual build-dependencies git py-pip python-dev libffi-dev build-base \
  && pip install git+https://github.com/shupp/VegaDNS-CLI.git@${VEGADNS_CLI} \
  && pip install -r /opt/vegadns/requirements.txt \
  && apk del build-dependencies

CMD cd /opt/vegadns/ \
  && python docker/templates/config.py > /opt/vegadns/vegadns/api/config/local.ini \
  && python run.py

EXPOSE 5000

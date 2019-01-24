FROM python:3.6.6-alpine
LABEL version="1.0"

ADD ./requirements.txt /tmp/

RUN apk update && apk add tzdata && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk add --no-cache mariadb-dev g++ && \
    pip install -r /tmp/requirements.txt && \
    apk del g++
RUN pip install -r /tmp/requirements.txt

WORKDIR /data/app
COPY ./DJANGO_PROJ_DIR ./

RUN cat ./crontab/crontab.conf >> /var/spool/cron/crontabs/root

EXPOSE 8000
ENV PYTHONPATH=/data/app

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

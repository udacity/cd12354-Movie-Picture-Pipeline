FROM public.ecr.aws/docker/library/python:3.10
ENV FLASK_RUN_HOST=0.0.0.0

WORKDIR /
RUN adduser --uid 1000 --disabled-password app
RUN apt-get update && \
  apt-get install -y \
  libpcre2-8-0 \
  libpcre2-dev \
  build-essential \
  gcc \
  linux-libc-dev \
  openssl \
  libssl-dev \
  libffi-dev \
  && rm -rf /var/lib/apt/lists/* \
  && pip install pipenv

RUN mkdir -p /var/www/app && mkdir /app

COPY Pipfile* /app
RUN cd /app && pipenv install --system --deploy

COPY . /app

CMD uwsgi --http :5000 --master --enable-threads -s /var/www/app/app.sock --manage-script-name --mount /=app:app

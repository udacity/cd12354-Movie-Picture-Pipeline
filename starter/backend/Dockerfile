FROM public.ecr.aws/docker/library/python:3.10

ENV FLASK_RUN_HOST=0.0.0.0

WORKDIR /

RUN useradd -u 1000 -m app

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libpcre2-dev \
    && rm -rf /var/lib/apt/lists/* && \
    pip install pipenv

RUN mkdir -p /var/www/app && mkdir /app

COPY Pipfile* /app
# uWSGI 2.0.21 does not compile with the C23 default of GCC 15 (current Alpine),
# so build it with the previous C standard.
RUN cd /app && CFLAGS="-std=gnu17" pipenv install --system --deploy

COPY . /app

CMD ["uwsgi", "--http", ":5000", "--master", "--enable-threads", "-s", "/var/www/app/app.sock", "--manage-script-name", "--mount", "/=app:app"]
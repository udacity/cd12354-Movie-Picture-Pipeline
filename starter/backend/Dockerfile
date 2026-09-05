FROM public.ecr.aws/docker/library/python:3.10-alpine

ENV FLASK_RUN_HOST=0.0.0.0

WORKDIR /app

RUN adduser -u 1000 -D app

RUN apk update && \
  apk add \
  pcre \
  pcre-dev \
  build-base \
  gcc \
  linux-headers \
  openssl \
  libffi-dev \
  && pip install pipenv

RUN mkdir -p /var/www/app

COPY Pipfile* /app/
RUN pipenv install --system --deploy

COPY . /app/

CMD ["python", "-m", "flask", "--app", ".", "run", "--host=0.0.0.0", "--port=5000"]
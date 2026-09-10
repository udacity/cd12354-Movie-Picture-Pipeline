FROM python:3.10-slim

ENV FLASK_RUN_HOST=0.0.0.0

WORKDIR /

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade pip setuptools wheel \
    && pip install pipenv

RUN mkdir -p /var/www/app && mkdir /app

COPY Pipfile* /app

RUN cd /app && pipenv install --system
COPY . /app

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
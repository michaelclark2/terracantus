FROM python:3
ENV PYTHONUNBUFFERED 1

RUN mkdir /app
WORKDIR /app
COPY requirements.* .
RUN pip install -r requirements.dev.txt

ADD . .


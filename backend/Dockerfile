FROM python:3.12.7-alpine

WORKDIR /code

RUN apk add --no-cache curl

COPY requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY . /code/app

WORKDIR /code/app

CMD ["sh", "-c", "python database_setup.py && fastapi run main.py --port ${PORT:-8080}"]

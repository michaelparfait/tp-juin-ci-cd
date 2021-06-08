FROM python:3.7-alpine

WORKDIR /app

ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers

RUN apk update \
 && apk add git

RUN git clone https://github.com/vanessakovalsky/example-python.git

RUN cp example-python/vagrant/src/main.py .

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "main.py"]
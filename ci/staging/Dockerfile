FROM python:2.7
ADD requirements.txt /usr/src/app/
RUN pip install -r /usr/src/app/requirements.txt
EXPOSE 5000
WORKDIR /usr/src/app
ADD . .
FROM python:2.7
ADD requirements.txt /usr/src/app/
RUN pip install -r /usr/src/app/requirements.txt
EXPOSE 8001
WORKDIR /usr/src/app
ADD . .
CMD python run.py
FROM python:3
WORKDIR /opt/app
COPY app.py .
RUN pip install flask
RUN pip install python-dotenv
EXPOSE 8080
CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"] # runs flask on machines ip address
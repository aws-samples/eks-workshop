FROM tensorflow/tensorflow:1.13.1

COPY mnist-tensorflow-docker.py /mnist-tensorflow-docker.py

CMD [ "python", "mnist-tensorflow-docker.py" ]
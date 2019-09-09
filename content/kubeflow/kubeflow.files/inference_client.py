# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

# Helper libraries
import numpy as np
import os
import subprocess
import argparse

import random
import json
import requests


def main(argv=None):
  parser = argparse.ArgumentParser(description='Fashion MNIST Tensorflow Serving Client')
  parser.add_argument('--endpoint', type=str, default='http://localhost:8500/v1/models/mnist:predict', help='Model serving endpoint')
  args = parser.parse_args()

  # Prepare test dataset
  fashion_mnist = keras.datasets.fashion_mnist
  (train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

  # scale the values to 0.0 to 1.0
  train_images = train_images / 255.0
  test_images = test_images / 255.0

  # reshape for feeding into the model
  train_images = train_images.reshape(train_images.shape[0], 28, 28, 1)
  test_images = test_images.reshape(test_images.shape[0], 28, 28, 1)

  class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
                'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']

  # Random generate one image
  rando = random.randint(0,len(test_images)-1)
  data = json.dumps({"signature_name": "serving_default", "instances": test_images[rando:rando+1].tolist()})
  print('Data: {} ... {}'.format(data[:50], data[len(data)-52:]))

  # HTTP call
  headers = {"content-type": "application/json"}
  json_response = requests.post(args.endpoint, data=data, headers=headers)
  predictions = json.loads(json_response.text)['predictions']

  title = 'The model thought this was a {} (class {}), and it was actually a {} (class {})'.format(
    class_names[np.argmax(predictions[0])], test_labels[rando], class_names[np.argmax(predictions[0])], test_labels[rando])
  print(title)

if __name__ == "__main__":
  main()

"""Armaps package initializer."""
import flask

app = flask.Flask(__name__)

# Read settings from config module (armaps/config.py)
app.config.from_object('armaps.config')

# Tell the app about the api and model
import armaps.api
import armaps.model

# Testing
@app.route('/')
def hello_world():
    return "Hello World"

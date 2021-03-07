"""Armaps package initializer."""
import flask
import os

app = flask.Flask(__name__)

# Read settings from config module (armaps/config.py)
app.config.from_object('armaps.config')

# Tell the app about the api and model
import armaps.api
import armaps.model


# Serve image files to the frontend
@app.route('/media/<path:filename>', methods=["GET"])
def get_image(filename):
    """Return image requested."""
    return flask.send_from_directory(str(app.config['MEDIA_FOLDER']), 
                                     filename, as_attachment=True)
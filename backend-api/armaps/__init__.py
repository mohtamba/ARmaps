"""Armaps package initializer."""
import flask

app = flask.Flask(__name__)

# Read settings from config module (armaps/config.py)
app.config.from_object('armaps.config')

# Tell the app about the api and model
import armaps.api
import armaps.model


# Returning error codes
def error_code(message, status_code):
    """Return the error with JSON and error code."""
    error = {}
    error["message"] = message
    error["status_code"] = status_code
    return flask.jsonify(**error), status_code


# Serve image files to the frontend
@app.route('/media/<path:filename>', methods=["GET"])
def get_image(filename):
    """Return image requested."""
    return flask.send_from_directory(str(app.config['MEDIA_FOLDER']), 
                                     filename, as_attachment=True)

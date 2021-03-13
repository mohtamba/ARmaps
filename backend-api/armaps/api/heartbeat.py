"""
Heartbeat header.

URLs include:

/
"""

import flask
import armaps


@armaps.app.route('/', methods=["GET"])
def heartbeat():
    return flask.jsonify()

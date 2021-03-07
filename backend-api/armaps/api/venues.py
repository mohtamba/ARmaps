"""
Venues header.

URLs include:

/api/venues/
"""

import flask
import armaps


@armaps.app.route('/api/venues/', methods=["GET"])
def get_venues():
    # TODO: complete endpoint
    context = {}
    return flask.jsonify(**context)

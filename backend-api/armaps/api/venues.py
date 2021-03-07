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
    connection = armaps.model.get_db()
    cur = connection.execute('SELECT * FROM venues')
    venues = cur.fetchall()

    context = {
        "data": venues,
        "url": "/api/venues/"
    }

    return flask.jsonify(**context)

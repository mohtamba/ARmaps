"""
Venues header.

URLs include:

/api/venues/
"""

import flask
import armaps


@armaps.app.route('/api/venues/', methods=["GET"])
def get_venues():
    # Setup database connection, get all venues
    cur = armaps.model.get_db()
    cur.execute("SELECT * FROM venues")
    venues = cur.fetchall()

    # Sort the venues by name, alphabetically
    venues = sorted(venues, key=lambda i: i["name"])

    context = {
        "data": venues,
        "url": "/api/venues/"
    }
    return flask.jsonify(**context)

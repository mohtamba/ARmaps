"""
Destinations header.

URLs include:

/api/venues/:id/destinations/
"""

import flask
import armaps


@armaps.app.route('/api/venues/<int:venueid_url_slug>/destinations/',
                  methods=["GET"])
def get_destinations(venueid_url_slug):
    # TODO: complete endpoint (below is testing)
    context = {
        "id": venueid_url_slug
    }
    return flask.jsonify(**context)


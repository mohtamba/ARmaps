"""
Directions header.

URLs include:

/api/venues/:id/destinations/:id/directions/
"""

import flask
import armaps


@armaps.app.route('/api/venues/<int:venueid_url_slug>/destinations/<int:destid_url_slug>/directions/',
                  methods=["GET"])
def get_directions(venueid_url_slug, destid_url_slug):
    # TODO: complete endpoint (below is testing)
    context = {
        "venueid": venueid_url_slug,
        "destid": destid_url_slug
    }
    return flask.jsonify(**context)


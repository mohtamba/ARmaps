"""
Destinations header.

URLs include:

/api/venues/:id/destinations/
"""

import flask
from math import sin, cos, sqrt, atan2, radians
import geopy.distance
import armaps


def should_order_by_dist(lat, lon):
    """ Returns True if we should order by distance """
    return abs(lat) <= 90 and abs(lon) <= 180

@armaps.app.route('/api/venues/<int:venueid_url_slug>/destinations/',
                  methods=["GET"])
def get_destinations(venueid_url_slug):
    # Get url parameters if they exist
    lat = flask.request.args.get("lat", default=999, type=float)
    lon = flask.request.args.get("lon", default=999, type=float)

    # Connect to database and get destinations
    cur = armaps.model.get_db()
    cur.execute(
        "SELECT * FROM destinations WHERE venue_id = %s",
        (venueid_url_slug,)
    )
    destinations = cur.fetchall()

    user_coords = (lat, lon)
    if should_order_by_dist(lat, lon):
        destinations = sorted(destinations,
            key=lambda i: geopy.distance.distance(user_coords, (i['latitude'], i['longitude'])).miles)
    else:
        destinations = sorted(destinations, key=lambda i: i["name"])

    context = {
        "data": destinations,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/"
    }
    return flask.jsonify(**context)

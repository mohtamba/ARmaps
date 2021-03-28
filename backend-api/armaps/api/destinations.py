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
    user_coords = (lat, lon)

    # Connect to database and get destinations
    cur = armaps.model.get_db()
    cur.execute(
        "SELECT * FROM destinations WHERE venue_id = %s",
        (venueid_url_slug,)
    )
    destinations = cur.fetchall()

    # Sort by distance or name
    if should_order_by_dist(lat, lon):

        # Include distance calculation in destination list
        for dest in destinations:
            dest_coords = (dest["latitude"], dest["longitude"])
            dest_distance = geopy.distance.distance(user_coords, dest_coords).miles
            dest["distance"] = round(dest_distance, 1)

        # Sort by distance
        destinations = sorted(destinations, key=lambda i: i["distance"])
    else:
        destinations = sorted(destinations, key=lambda i: i["name"])

    context = {
        "data": destinations,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/"
    }
    return flask.jsonify(**context)

"""
Destinations header.

URLs include:

/api/venues/:id/destinations/
"""

import flask
from math import sin, cos, sqrt, atan2, radians
import armaps

def should_order_by_dist(lat, lon):
    """ Returns True if we should order by distance """
    return abs(lat) <= 180 and abs(lon) <= 180

def get_distance(lat, lon):
    # approximate radius of earth in km
    R = 6373.0

    lat1 = radians(lat)
    lon1 = radians(lon)

    def calc_dist(destination):
        lat2 = radians(destination['latitude'])
        lon2 = radians(destination['longitude'])

        dlon = lon2 - lon1
        dlat = lat2 - lat1

        a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
        c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c

    # print("Result:", distance)
    # print("Should be:", 278.546, "km")

    return calc_dist

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

    # Sort by name or by distance
    # Will not actually sort by distance until
    # get_distance function is finished
    get_dist_by_lat_lon = get_distance(lat, lon)
    if should_order_by_dist(lat, lon):
        destinations = sorted(destinations, key=get_dist_by_lat_lon)
    else:
        destinations = sorted(destinations, key=lambda i: i["name"])

    context = {
        "data": destinations,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/"
    }
    return flask.jsonify(**context)

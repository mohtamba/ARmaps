"""
Venues header.

URLs include:

/api/venues/
"""

import flask
import armaps
import geopy.distance

def should_order_by_dist(lat, lon):
    """ Returns True if we should order by distance """
    return abs(lat) <= 90 and abs(lon) <= 180

@armaps.app.route('/api/venues/', methods=["GET"])
def get_venues():
    # Get url parameters if they exist
    lat = flask.request.args.get("lat", default=999, type=float)
    lon = flask.request.args.get("lon", default=999, type=float)
    user_coords = (lat, lon)

    # Setup database connection, get all venues
    cur = armaps.model.get_db()
    cur.execute("SELECT * FROM venues")
    venues = cur.fetchall()

    # Sort by distance or name
    if should_order_by_dist(lat,lon):

        # Include distance calculation in venue list
        for venue in venues:
            venue_coords = (venue["latitude"], venue["longitude"])
            venue_distance = geopy.distance.distance(user_coords, venue_coords).miles
            venue["distance"] = round(venue_distance, 1)

        # Sort by distance
        venues = sorted(venues, key=lambda i: i["distance"])
    else:
        venues = sorted(venues, key=lambda i: i["name"])

    context = {
        "data": venues,
        "url": "/api/venues/"
    }
    return flask.jsonify(**context)

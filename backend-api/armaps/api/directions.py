"""
Directions header.

URLs include:

/api/venues/:id/destinations/:id/directions/
"""

import flask
import armaps
import geopy.distance


@armaps.app.route('/api/venues/<int:venueid_url_slug>/destinations/<int:destid_url_slug>/directions/',
                  methods=["GET"])
def get_directions(venueid_url_slug, destid_url_slug):
    
    # Get url parameters if they exist
    lat = flask.request.args.get("lat", default=999, type=float)
    lon = flask.request.args.get("lon", default=999, type=float)

    # Connect to database and get destination
    cur = armaps.model.get_db()
    cur.execute(
        "SELECT * FROM destinations WHERE venue_id = %s AND destination_id = %s",
        (venueid_url_slug, destid_url_slug,)
    )
    destination = cur.fetchone()

    # Create coordiantes
    user_coords = (lat, lon)
    dest_coords = (destination['latitude'], destination['longitude'])

    # Get distance to destination
    distance_to_dest = geopy.distance.distance(user_coords, dest_coords).miles

    # Time to destination in minutes (given a walking speed of 3mph)
    time_estimate = distance_to_dest / 3 * 60

    data = [
        {
            "lat": 43.34,
            "lon": -86.28
        },
        {
            "lat": 28.38,
            "lon": -81.56
        },
        {
            "lat": 28.38,
            "lon": -82.56
        },
        {
            "lat": dest_coords[0],
            "lon": dest_coords[1]
        }
    ]

    # TODO: complete endpoint (below is testing)

    context = {
        "data": data,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/" + str(destid_url_slug) + "/directions/",
        "distance": distance_to_dest,
        "time_estimate": time_estimate
    }
    return flask.jsonify(**context)


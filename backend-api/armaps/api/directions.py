"""
Directions header.

URLs include:

/api/venues/:id/destinations/:id/directions/
"""

import flask
import armaps
import sys
import dijkstra
import geopy.distance
import math


class Graph:
    """A class to represent venue and paths as a graph."""

    def __init__(self, venue_id, lat, lon):
        # Set up member variables
        self.waypoints = {}
        self.graph = dijkstra.Graph()
        self.venue_id = venue_id

        # Create graph from the database
        self.create_graph(lat, lon)


    def create_graph(self, lat, lon):
        """
        Create graph from nodes/edges in db within specfic venue.
        - undirected, weighted graph
        - edge with corresponding weight (distance in miles)
        """
        # Open connection to the database (nodes)
        cur = armaps.model.get_db()

        # Get the waypoints
        cur.execute(
            "SELECT * FROM waypoints WHERE venue_id = %s", 
            (self.venue_id,)
        )
        waypoints = cur.fetchall()

        # Get the paths (edges)
        cur.execute(
            "SELECT * FROM paths WHERE venue_id = %s",
            (self.venue_id,)
        )
        paths = cur.fetchall()

        # Transform list of waypoints into dictionary with key = waypoint_id
        for waypoint in waypoints:
            self.waypoints[int(waypoint["waypoint_id"])] = {
                "lat": float(waypoint["latitude"]),
                "lon": float(waypoint["longitude"]),
                "waypoint_id": int(waypoint["waypoint_id"])
            }

        # Calculate weights of edges in graph
        for path in paths:
            # Get two nodes (waypoints) associated with edge
            inNode = int(path["innode"])
            outNode = int(path["outnode"])

            # Get the coordinates of nodes
            inNode_coords = (self.waypoints[inNode]["lat"], self.waypoints[inNode]["lon"])
            outNode_coords = (self.waypoints[outNode]["lat"], self.waypoints[outNode]["lon"])
            distance = geopy.distance.distance(inNode_coords, outNode_coords).miles

            # Add to graph (both ways for undirected)
            self.graph.add_edge(inNode, outNode, distance)
            self.graph.add_edge(outNode, inNode, distance)


    def insert_user_location(self, lat, lon):
        """Add user's location as starting waypoint to graph, connect
        waypoint to closest other in graph with edge, return waypoint id."""
        # Waypoint id for user's location
        user_waypoint_id = 0

        # Keep track of closest waypoint to user
        closest_waypoint = None
        min_distance = float("inf")

        # Find closest waypoint to user's location
        for key, val in self.waypoints.items():
            # Check to see if waypoint_id higher than user's
            if key > user_waypoint_id:
                user_waypoint_id = key

            # Calculate distance
            user_coords = (lat, lon)
            waypoint_coords = (val["lat"], val["lon"])
            distance = geopy.distance.distance(user_coords, waypoint_coords).miles

            if distance < min_distance:
                min_distance = distance
                closest_waypoint = key

        # Increment highest waypoint id seen to get user's starting waypoint id
        user_waypoint_id += 1

        # Add to graph
        self.graph.add_edge(user_waypoint_id, closest_waypoint, min_distance)
        self.graph.add_edge(closest_waypoint, user_waypoint_id, min_distance)

        # Return starting waypoint id
        return user_waypoint_id


    def get_path(self, starting_waypoint, destination_id):
        """Given starting way point id and destination id, find the shortest
        path between them in the graph, return list of waypoints between to path."""
        # Run dijkstra's algorithm
        dijkstra_output = dijkstra.DijkstraSPF(self.graph, starting_waypoint)
        
        # Get waypoint_id of destination
        cur = armaps.model.get_db()
        cur.execute(
            "SELECT waypoint_id FROM waypoints WHERE destination_id = %s", 
            (destination_id,)
        )
        cur_output = cur.fetchone()
        dest_waypoint_id = int(cur_output["waypoint_id"])

        # Get the path from starting waypoint to destination's waypoint
        path = dijkstra_output.get_path(dest_waypoint_id)

        # Excluding starting point in path, add coords of each waypoint to data
        data = []

        for i in range(1, len(path)):
            data.append(
                {
                    "lat": self.waypoints[path[i]]["lat"],
                    "lon": self.waypoints[path[i]]["lon"],
                    "id": self.waypoints[path[i]]["waypoint_id"]
                }
            )
        
        return data


def calculate_vars(data, lat, lon):
    """Given path data and starting point (lat, lon), calculate how far the
    user's destination is from them, and the time estimate to get there."""
    # Keep track of running distance and time calculations
    distance_to_dest = 0.0
    time_estimate = 0.0

    # Calculate from starting dest to first point in data
    user_coords = (lat, lon)
    first_path_coords = (data[0]["lat"], data[0]["lon"])
    first_distance = geopy.distance.distance(user_coords, first_path_coords).miles
    distance_to_dest += first_distance
    time_estimate += first_distance * 20    # 3mph walking speed

    # Calculate for all other points
    for i in range(1, len(data) - 1):
        this_coords = (data[i]["lat"], data[i]["lon"])
        next_coords = (data[i + 1]["lat"], data[i + 1]["lon"])

        distance = geopy.distance.distance(this_coords, next_coords).miles
        distance_to_dest += distance
        time_estimate += distance * 20    # 3mph walking speed

    # Round distance and time estimates
    distance_to_dest = round(distance_to_dest, 1)
    time_estimate = round(time_estimate)

    return distance_to_dest, time_estimate


def check_ids(venue_id, dest_id):
    """Returns true if venue or destination id are invalid."""
    # Check that venue destination pair exist in database
    cur = armaps.model.get_db()
    cur.execute(
        "SELECT * FROM destinations WHERE venue_id = %s AND destination_id = %s", 
        (venue_id, dest_id,)
    )
    result = cur.fetchone()

    # Return true (error) if no match
    if result is None:
        return True

    # Otherwise, return false
    return False


def path_correction(data, user_coords):
    """Correct path so that user doesn't backtrack to first waypoint."""
    # Return list if it only has the destination
    if len(data) == 1:
        return data

    # Calculate distance from user to second waypoint
    second_coords = (data[1]["lat"], data[1]["lon"])
    user_second_dist = geopy.distance.distance(user_coords, second_coords).miles

    # Calculate distance from user to first waypoint
    first_coords = (data[0]["lat"], data[0]["lon"])
    user_first_dist = geopy.distance.distance(user_coords, first_coords).km

    # Calculate distance from first waypoint to second waypoint
    first_second_dist = geopy.distance.distance(first_coords, second_coords).miles

    # Determine if path correction is applicable
    if user_second_dist < first_second_dist or user_first_dist < 0.01:
        # Delete first element of list so that user doesn't backtrack
        return data[1:]
    else:
        # No path correction needed
        return data

def get_bearings(data):
    num_points = len(data)
    idx = 0
    while idx < num_points-1:
        alat = math.radians(data[idx]['lat'])
        alon = data[idx]['lon']
        blat = math.radians(data[idx+1]['lat'])
        blon = data[idx+1]['lon']
        dLon = blon-alon
        X = math.cos(blat) * math.sin(dLon)
        Y = math.cos(alat) * math.sin(blat) - math.sin(alat) * math.cos(blat) * math.cos(dLon)
        bearing = math.atan2(X,Y)
        data[idx]['bearing'] = bearing

    data[-1]['bearing'] = -1
    return data

@armaps.app.route('/api/venues/<int:venueid_url_slug>/destinations/<int:destid_url_slug>/directions/',
                  methods=["GET"])
def get_directions(venueid_url_slug, destid_url_slug):

    # Get url parameters if they exist
    lat = flask.request.args.get("lat", type=float)
    lon = flask.request.args.get("lon", type=float)

    # Check for no URL parameters
    if lat is None or lon is None:
        return armaps.error_code("Bad Request", 400)

    # Check for invalid URL parameters
    if abs(lat) > 90 or abs(lon) > 180:
        return armaps.error_code("Bad Request", 400)

    # Check for invalid venue/destination id
    if check_ids(venueid_url_slug, destid_url_slug):
        return armaps.error_code("Not Found", 404)

    # Get the graph from the database, and find the path
    graph = Graph(venueid_url_slug, lat, lon)
    starting_waypoint = graph.insert_user_location(lat, lon)
    data = graph.get_path(starting_waypoint, destid_url_slug)
    correct_data = path_correction(data, (lat, lon))
    correct_data =  get_bearings(correct_data)

    # Calculate distance to destination and time estimate, given path
    distance_to_dest, time_estimate = calculate_vars(correct_data, lat, lon)

    context = {
        "data": correct_data,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/" + str(destid_url_slug) + "/directions/",
        "distance": distance_to_dest,
        "time_estimate": time_estimate
    }

    return flask.jsonify(**context)

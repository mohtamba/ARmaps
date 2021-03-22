"""
Directions header.

URLs include:

/api/venues/:id/destinations/:id/directions/
"""

import flask
import armaps
import dijkstra
import geopy.distance


class Graph:
    """A class to represent venue and paths as a graph."""

    def __init__(self, venue_id, lat, lon):
        # Set up member variables
        self.waypoints = {}
        self.graph = {}
        self.venue_id = venue_id

        # Create graph from the database
        self.create_graph(lat, lon)

    def create_graph(self, lat, lon):
        """
        Create graph from nodes/edges in db corresponding to given venue.
        - Undirected, weighted graph
        
        graph = {
            (1, 2): 5,
            (1, 3): 7,
            (2, 3): 9,
            (2, 4): 4,
            ...
        }
        """
        # Open connection to the database (nodes)
        cur = armaps.model.get_db()

        # Get the waypoints
        cur.execute(
            "SELECT * FROM waypoints WHERE venue_id == %s", 
            (self.venue_id,)
        )
        waypoints = cur.fetchall()

        # Get the paths (edges)
        cur.execute(
            "SELECT * FROM paths WHERE venue_id == %s",
            (self.venue_id,)
        )
        paths = cur.fetchall()

        # Transform list of waypoints into dictionary with key = waypoint_id
        for waypoint in waypoints:
            self.waypoints[waypoint["waypoint_id"]] = {
                "lat": waypoint["latitude"],
                "lon": waypoint["longitude"]
            }

        # Calculate weights of edges in graph
        for path in paths:
            # Get two nodes (waypoints) associated with edge
            inNode = path["inNode"]
            outNode = path["outNode"]

            # Get the coordinates of nodes
            inNode_coords = (self.waypoints[inNode]["lat"], self.waypoints[inNode]["lon"])
            outNode_coords = (self.waypoints[outNode]["lat"], self.waypoints[outNode]["lon"])
            distance = geopy.distance.distance(inNode_coords, outNode_coords)

            # Add to graph
            self.graph[(inNode, outNode)] = distance
            self.graph[(outNode, inNode)] = distance


    def insert_user_location(self, lat, lon):
        """Add user's location as starting waypoint to graph, connect
        waypoint to closest other in graph with edge, return waypoint id."""
        # Get waypoints from db
        cur = armaps.model.get_db()
        cur.execute(
            "SELECT * FROM waypoints WHERE venue_id == %s", 
            (self.venue_id,)
        )
        waypoints = cur.fetchall()

        # Waypoint id for user's location
        user_waypoint_id = 0

        # Keep track of closest waypoint to user
        closest_waypoint = None
        min_distance = float("inf")

        # Find closest waypoint to user's location
        for waypoint in waypoints:
            # Check to see if waypoint_id higher than user's
            if waypoint["waypoint_id"] > user_waypoint_id:
                user_waypoint_id = waypoint["waypoint_id"]

            # Calculate distance
            distance = geopy.distance.distance((lat, lon), (waypoint["latitude"], waypoint["longitude"]))
            if distance < min_distance:
                min_distance = distance
                closest_waypoint = waypoint["waypoint_id"]

        # Increment highest waypoint id seen to get user's starting waypoint id
        user_waypoint_id += 1

        # Add to graph
        self.graph[(user_waypoint_id, closest_waypoint)] = min_distance
        self.graph[(closest_waypoint, user_waypoint_id)] = min_distance

        # Return starting waypoint id
        return user_waypoint_id


    def get_path(self, starting_waypoint, destination_id):
        """Given starting way point id and destination id, find the shortest
        path between them in the graph, return list of waypoints between to path."""
        # Create a graph for dijkstra
        d_graph = dijkstra.Graph()

        # Add edges to the graph
        for key, val in self.graph.items():
            d_graph.add_edge(key[0], key[1], val)

        # Run dijkstra's algorithm
        dijkstra_output = dijkstra.DijkstraSPF(d_graph, starting_waypoint)
        
        # Get waypoint_id of destination
        cur = armaps.model.get_db()
        cur.execute(
            "SELECT * FROM waypoints WHERE destination_id == %s", 
            (destination_id,)
        )
        dest_waypoint_id = cur.fetchone()

        # Get the path from starting waypoint to destination's waypoint
        path = dijkstra_output.get_path(dest_waypoint_id)

        # Excluding starting point in path, add coords of each waypoint to data
        data = []

        for i in range(1, len(path)):
            data.append(
                {
                    "lat": self.waypoints[path[i]]["lat"],
                    "lon": self.waypoints[path[i]]["lon"]
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
    first_distance = geopy.distance.distance(user_coords, first_path_coords)
    distance_to_dest += first_distance
    time_estimate += first_distance * 20    # 3mph walking speed

    # Calculate for all other points
    for i in range[1:len(data) - 1]:
        this_coords = (data[i]["lat"], data[i]["lon"])
        next_coords = (data[i + 1]["lat"], data[i + 1]["lon"])

        distance = geopy.distance.distance(this_coords, next_coords)
        distance_to_dest += distance
        time_estimate += distance * 20    # 3mph walking speed

    return distance_to_dest, time_estimate


@armaps.app.route('/api/venues/<int:venueid_url_slug>/destinations/<int:destid_url_slug>/directions/',
                  methods=["GET"])
def get_directions(venueid_url_slug, destid_url_slug):

    # Get url parameters if they exist
    lat = flask.request.args.get("lat", type=float)
    lon = flask.request.args.get("lon", type=float)

    # Check for no parameters
    if lat is None or lon is None:
        return armaps.error_code("Bad Request", 400)

    # Check for invalid parameters
    if abs(lat) > 90 or abs(lon) > 180:
        return armaps.error_code("Bad Request", 400)

    # Get the graph from the database, and find the path
    graph = Graph(venueid_url_slug, lat, lon)
    starting_waypoint = graph.insert_user_location(lat, lon)
    data = graph.get_path(starting_waypoint, destid_url_slug)

    # Calculate distance to destination and time estimate, given path
    distance_to_dest, time_estimate = calculate_vars(data, lat, lon)

    context = {
        "data": data,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/" + str(destid_url_slug) + "/directions/",
        "distance": distance_to_dest,
        "time_estimate": time_estimate
    }

    return flask.jsonify(**context)


"""
Directions header.

URLs include:

/api/venues/:id/destinations/:id/directions/
"""

import flask
import armaps
import geopy.distance


class Graph:
    """A class to represent venue and paths as a graph."""

    def __init__(self, venue_id, lat, lon):
        # Set up member variables
        self.graph = {}
        self.weights = {}
        self.venue_id = venue_id

        # Create graph from the database
        self.create_graph(lat, lon)

    def create_graph(self, lat, lon):
        """
        Create graph from nodes/edges in db corresponding to given venue.
        - Undirected, weighted graph
        
        Output format:
        graph = {
            1: [2, 3],
            2: [1, 3, 4],
            3: [1, 2],
            4: [2],
            ...
        }
        weights = {
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

        # Build the undirected graph
        for path in paths:
            # Get two nodes (waypoints) associated with edge
            inNode = path["inNode"]
            outNode = path["outNode"]

            # Add both (inNode, outNode) & (outNode, inNode)
            if inNode not in self.graph:
                self.graph[inNode] = [outNode]
            else:
                self.graph[inNode].append(outNode)

            if outNode not in self.graph:
                self.graph[outNode] = [inNode]
            else:
                self.graph[outNode].append(inNode)

        # Transform list of waypoints into dictionary with key = waypoint_id
        waypoint_dict = {}
        for waypoint in waypoints:
            waypoint_dict[waypoint["waypoint_id"]] = {
                "lat": waypoint["latitude"],
                "lon": waypoint["longitude"]
            }

        # Calculate weights
        for path in paths:
            # Get two nodes (waypoints) associated with edge
            inNode = path["inNode"]
            outNode = path["outNode"]

            # Get the coordinates of nodes
            inNode_coords = (waypoint_dict[inNode]["lat"],waypoint_dict[inNode]["lon"])
            outNode_coords = (waypoint_dict[outNode]["lat"],waypoint_dict[outNode]["lon"])
            distance = geopy.distance(inNode_coords, outNode_coords)

            # Add to weights data structure
            self.weights[(inNode, outNode)] = distance
            self.weights[(outNode, inNode)] = distance


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
            distance = geopy.distance((lat, lon), (waypoint["latitude"], waypoint["longitude"]))
            if distance < min_distance:
                min_distance = distance
                closest_waypoint = waypoint["waypoint_id"]

        # Increment highest waypoint id seen to get user's starting waypoint id
        user_waypoint_id += 1

        # Add to graph
        self.graph[user_waypoint_id] = closest_waypoint
        self.graph[closest_waypoint] = user_waypoint_id

        # Add to weights
        self.weights[(user_waypoint_id, closest_waypoint)] = min_distance
        self.weights[(closest_waypoint, user_waypoint_id)] = min_distance

        # Return starting waypoint id
        return user_waypoint_id




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

    # Get the graph from the database
    graph = Graph(venueid_url_slug, lat, lon)
    starting_waypoint = graph.insert_user_location(lat, lon)

    # Dummy variables
    data = []
    distance_to_dest = 3.6
    time_estimate = 23

    context = {
        "data": data,
        "url": "/api/venues/" + str(venueid_url_slug) + "/destinations/" + str(destid_url_slug) + "/directions/",
        "distance": distance_to_dest,
        "time_estimate": time_estimate
    }

    return flask.jsonify(**context)


fs = require 'fs'
async = require 'async'
csv = require './csv.coffee'

# this file reads the gtfs files and spits out a list of routes, and their stop
# ids (and names for debugging)

async.auto {
	routes: (cb) -> csv.from_file 'gtfs/routes.txt', cb
	trips: (cb) -> csv.from_file 'gtfs/trips.txt', key_field: 'route_id', multiple: true, cb
	stop_times: (cb) -> csv.from_file 'gtfs/stop_times.txt', key_field: 'trip_id', multiple: true, cb
	stops: (cb) -> csv.from_file 'gtfs/stops.txt', key_field: 'stop_id', cb
}, (err, r) ->
	return console.log "error: ", err if err
	for route in r.routes
		console.log "Route: #{route.route_id}"
		stops = {}
		if r.trips[route.route_id]?
			for trip in r.trips[route.route_id]
				if r.stop_times[trip.trip_id]?
					for stop_time in r.stop_times[trip.trip_id]
						stops[stop_time.stop_id] = r.stops[stop_time.stop_id]?.stop_name ? "stop ###{stop_time.stop_id} not found in gtfs/stops.txt"
			for k, v of stops
				console.log "    stop: #{k}  #{v}"

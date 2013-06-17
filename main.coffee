fs = require 'fs'
async = require 'async'
csv = require './csv.coffee'

osm_ids_file = process.argv[2]
out_file = process.argv[3]

# this file reads the gtfs files and spits out a list of routes, and their stop
# ids (and names for debugging)

die = (msg..., code) ->
	console.log msg...
	process.exit code

json_file = (filename, cb) ->
	fs.readFile filename, 'utf8', (err, data) ->
		return cb err if err
		try
			ret = JSON.parse data
		catch e
			return cb "error: #{e}"
		cb null, ret

async.auto {
	osm_ids: (cb) -> json_file osm_ids_file, cb
	routes: (cb) -> csv.from_file 'gtfs/routes.txt', cb
	trips: (cb) -> csv.from_file 'gtfs/trips.txt', key_field: 'route_id', multiple: true, cb
	stop_times: (cb) -> csv.from_file 'gtfs/stop_times.txt', key_field: 'trip_id', multiple: true, cb
	stops: (cb) -> csv.from_file 'gtfs/stops.txt', key_field: 'stop_id', cb
}, (err, r) ->
	die "error: ", err, 1 if err
	routes = {}
	for route in r.routes
		routes[route.route_id] ?= { id: route.route_id, name: route.route_long_name, stops: {} }
		stops = routes[route.route_id].stops
		# this just records all stops that a given bus makes, nothing about the order
		# FIXME figure out what order of the stops, merge in stops not always
		# made, figure out reverse routes
		for trip in r.trips[route.route_id] ? []
			for stop_time in r.stop_times[trip.trip_id] ? []
				id = stop_time.stop_id
				stops[id] ?= {}
				stop = stops[id]
				stop.id = id
				stop.osm_id = r.osm_ids[id] if r.osm_ids[id]
				stop.name = r.stops[id]?.stop_name ? "stop #{id} not found in gtfs/stops.txt"
				stop.headings ?= []
				stop.headings.push trip.trip_headsign if trip.trip_headsign not in stop.headings
	fs.writeFile out_file, JSON.stringify(routes), 'utf8'

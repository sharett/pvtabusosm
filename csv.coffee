fs = require 'fs'

# custom CSV parser.
#
# each row is returned as a dictionary (keys from first row of CSV file)
#
# if you pass key_field, then this will return a big dictionary (key being the
# value from the row in the key_field column, value being the whole row)
#
# if you pass multiple, then each value in that big dictionary will be an array
# of matching rows
#
# see main.coffee for examples

exports.from_file = (filename, args..., cb) ->
	# defaults
	delimiter = ','
	key_field = null
	multiple = false

	# (optional) named args
	if args.length
		args = args[0]
		delimiter = args.delimiter if args.delimiter?
		key_field = args.key_field if args.key_field?
		multiple = args.multiple if args.multiple?

	fs.readFile filename, 'utf8', (err, data) ->
		return cb err if err?
		lines = data.split '\n'
		if data.substr(data.length - 1) is '\n'
			lines.pop()
		keys = lines.shift().split delimiter
		if key_field?
			ret = {}
		else
			ret = []
		for line in lines
			split = line.split delimiter
			row = []
			parts = []
			cur = row
			for c in split
				if c.length > 1 and c[0] is '"' and c[c.length - 1] is '"'
					c = c.substr(1, c.length - 2)
				else if c.length > 0 and c[0] is '"'
					cur = parts
					c = c.substr 1
				else if c.length > 1 and c[c.length - 1] is '"'
					parts.push c.substr(0, c.length - 1)
					c = parts.join(',')
					parts = []
					cur = row
				cur.push c
			dict = {}
			for k, i in keys
				dict[k] = row[i]
			if key_field?
				if multiple
					(ret[dict[key_field]] ?= []).push dict
				else
					ret[dict[key_field]] = dict
			else
				ret.push dict
		cb null, ret

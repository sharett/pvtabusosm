OBJECTS=routes.txt refs_to_osm_ids.json

all: $(OBJECTS)

routes.txt: csv.coffee main.coffee refs_to_osm_ids.json
	coffee main.coffee refs_to_osm_ids.json $@

refs_to_osm_ids.json: stop_refs_to_json.sh xapibus_pvta.xml
	bash ./stop_refs_to_json.sh < xapibus_pvta.xml >$@

clean: rm -f $(OBJECTS)

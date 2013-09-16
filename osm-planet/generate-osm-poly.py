#!/usr/bin/python
import sys
import pprint
import re
import sys
import os.path

node_id =-10000
way_id = -1

def process_poly(filename, country, prefix, suffix):
	global node_id
	global way_id
	lines = []
	with open(filename, 'r') as f:
		lines = f.readlines()
	parse = re.compile('\s*([^\s]+)\s*([^\s]+)')
	way_tags = ""
	full_name = country
	if prefix != '':
		full_name = prefix + '_' + full_name
	if suffix != '':
		full_name = full_name + '_' + suffix

	way_tags  += '\t<tag k="osmand_region" v="yes" />\n'
	way_tags  += '\t<tag k="name" v="%s" />\n' % country
	way_tags  += '\t<tag k="download_name" v="%s" />\n' % full_name
	way_tags  += '\t<tag k="region_prefix" v="%s" />\n' % prefix
	way_tags  += '\t<tag k="region_suffix" v="%s" />\n' % suffix
	way_cont = ""
	i = 0
	first_node = 0
	first_line = None
	start_with = 2
	for line in lines:
		i = i + 1
		if i <= start_with:
			continue
		if line.strip() == "END":
			if first_line is not None:
				print '\n<way id="%s">' % (way_id)
				print way_tags
				print way_cont
				print '</way>\n'
				way_id = way_id - 1
			way_cont = ""
			first_line = None
			first_node = 0
			start_with = i + 1
			continue

		nid = node_id
		node_id = node_id - 1
		if line == first_line:
			nid = first_node
		else:
			if first_line is None:
				first_line = line
				first_node = nid

			match = parse.search(line)
			print '<node id="%s" lat="%s" lon="%s">' % (nid, float(match.groups()[0]), float(match.groups()[1]))
		way_cont += '\t<nd ref="%s" />\n' % (nid)


def process_poly_folder(folder, suffix):
	for filename in os.listdir (folder):
		country = filename[:-5]
		process_poly(folder + filename, country, '', suffix)

if __name__ == "__main__":
	print "<osm generator='osm2poly' version='0.5'>"
	#process_poly_folder('polygons/africa/', 'africa')
	process_poly_folder('polygons/south-america/', 'southamerica')
	print "</osm>"

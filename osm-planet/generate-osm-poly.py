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
			print '<node id="%s" lat="%s" lon="%s"/>' % (nid, float(match.groups()[1]), float(match.groups()[0]))
		way_cont += '\t<nd ref="%s" />\n' % (nid)


def process_poly_folder(folder, suffix, prefix=''):
	for filename in os.listdir (folder):
		if filename.endswith('.poly') and not filename.startswith('_'):
			country = filename[:-5]
			process_poly(folder + filename, country, prefix, suffix)

def process_russia_divisions():
	with open('gislab-polygons/files', 'r') as f:
		lines = f.readlines()
	parse = re.compile('\s*([^\s]+)\s*([^\s]+)')
	for line in lines:
		match = parse.search(line)
		fl = match.groups()[1]
		country = match.groups()[0]
		process_poly('gislab-polygons/'+fl+'.poly', country, 'Russia', 'asia')

	


if __name__ == "__main__":

	print "<osm generator='osm2poly' version='0.5'>"
	process_poly_folder('geo-polygons/europe/', 'europe')
	process_poly_folder('geo-polygons/europe/germany/', 'europe', 'Germany')
	process_poly_folder('geo-polygons/europe/france/', 'europe', 'France')

	process_poly('geo-polygons/europe/great-britain/england/greater-london.poly', 'greater-london', 'Gb_england', 'europe')
	process_poly_folder('geo-polygons/europe/great-britain/', 'europe', 'Gb')
	process_poly_folder('polygons/europe/gb-regions/', 'europe', 'Gb_england')
	
	# TODO Italy divisions (?)

	process_poly_folder('polygons/russia/', 'asia', 'Russia')
	process_poly_folder('polygons/russia-regions/', 'asia', 'Russia')

	process_poly_folder('geo-polygons/north-america/us/', 'northamerica', 'Us')
	process_poly_folder('geo-polygons/north-america/canada/', 'northamerica', 'Canada')

	process_poly_folder('geo-polygons/north-america/', 'northamerica')
	process_poly_folder('polygons/north-america/', 'northamerica')

	process_poly_folder('geo-polygons/south-america/', 'southamerica')
	process_poly_folder('polygons/south-america/', 'southamerica') 

	process_poly_folder('geo-polygons/central-america/', 'centralamerica')
	# TODO osm (?)
	# process_poly_folder('polygons/central-america/', 'centralamerica') # 20kb  for islands
	
	process_poly_folder('geo-polygons/asia/', 'asia')
	process_poly_folder('polygons/east-asia/', 'asia')
	process_poly_folder('polygons/ocean-asia/', 'asia')

	process_poly('polygons/australia-oceania/oceania.poly', 'oceania', '', 'australia-oceania')
	process_poly('geo-polygons/australia-oceania.poly', 'australia-oceania', '', '')
	process_poly_folder('geo-polygons/australia-oceania/', 'australia')
	
	process_poly('geo-polygons/africa.poly', 'africa', '', '')
	process_poly_folder('geo-polygons/africa/', 'africa')
	process_poly_folder('polygons/africa/', 'africa')

	print "</osm>"

#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import unicodedata as ud
import codecs
import pprint
import re
import sys
import os.path
from xml.dom import minidom


node_id =-10000
way_id = -1
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

import countryNamesNonStdMapping as cr


def normalizeStr(str):
	str = str.replace('_', ' ').replace('-', ' ').lower()
	str = str.replace(u'è',u'e').replace(u'ê',u'e').replace(u'ë',u'e').replace(u'é', u'e')
	str = str.replace(u'ü', u'u').replace(u'ô',u'o')
	return str

def initializeEntities(filename):
	xmldoc  = minidom.parse(filename)
	result = {}
	for item in xmldoc.firstChild.childNodes :
		if item.nodeName != 'node' and item.nodeName != 'relation':
			continue
		names = set()
		tags = {}
		tags['osm_id'] = item.attributes['id'].value
		for ent in item.childNodes :
			if ent.nodeName == 'tag' :
				name = ent.attributes['k'].value
				nameValue = ent.attributes['v'].value				
				if name == 'name' or name == 'name:en' or name == 'name:simple' or name == 'int_name':				 
					names.add(nameValue)
				if name.startswith('name') or name == 'int_name':
					tags[name] = nameValue
		override = True
		for name in names :
			if name in result and override:
				# print "Error duplicate with name : " + tags['name']
				result[normalizeStr(name)].update(tags)
			else :
				result[normalizeStr(name)] = tags
	return result

adminLevel2Xml =  initializeEntities('osm-data/countries_admin_level_2.osm')
countriesPlacesXML =  initializeEntities('osm-data/countries_places.osm')
statesPlacesXML =  initializeEntities('osm-data/states_places.osm')
statesRegionsXML =  initializeEntities('osm-data/states_regions.osm')




def addNames(country):
	way_tags = ""
	countryAdopt = 	country.replace('_', ' ').replace('-', ' ')
	if countryAdopt in cr.customRegionMapping:
		countryAdopt = normalizeStr(cr.customRegionMapping[countryAdopt].decode("utf-8"))

	if countryAdopt in countriesPlacesXML or countryAdopt in adminLevel2Xml: 
		tagsMap = {}
		if countryAdopt in adminLevel2Xml:
			tagsMap.update(adminLevel2Xml[countryAdopt])
		if countryAdopt in countriesPlacesXML:
			tagsMap.update(countriesPlacesXML[countryAdopt])
		for key in tagsMap :
			way_tags  += '\t<tag k="%s" v="%s" />\n' % (key, tagsMap[key])
	elif countryAdopt in statesRegionsXML : 
		tagsMap = statesRegionsXML[countryAdopt]
		for key in tagsMap :
			way_tags  += '\t<tag k="%s" v="%s" />\n' % (key, tagsMap[key])
	elif countryAdopt in statesPlacesXML : 
		tagsMap = statesPlacesXML[countryAdopt]
		for key in tagsMap :
			way_tags  += '\t<tag k="%s" v="%s" />\n' % (key, tagsMap[key])	
	elif countryAdopt in cr.missingRegionNames :
		way_tags  += '\t<tag k="name" v="%s" />\n' % cr.missingRegionNames[countryAdopt]
	else :
		print country + countryAdopt + " ?"
		raise Exception("Country name is missing %s <- %s (take a look at countryNamesNonStdMapping.py)!" % (countryAdopt, country))

	return way_tags

def addEmptyCountryForNames(suffix, dwName, country):
	global node_id
	global way_id
	print '\n<node id="%s" lat="0" lon="0">' % (node_id)
	print '\t<tag k="osmand_region" v="yes" />\n'
	print '\t<tag k="key_name" v="%s" />\n' % dwName
	print '\t<tag k="download_name" v="%s" />\n' % (dwName+'_'+suffix)
	print '\t<tag k="region_prefix" v="" />\n' 
	if dwName == "russia":
		suffix = "" # dont use asia
	print '\t<tag k="region_suffix" v="%s" />\n' % suffix
	print addNames(country)
	print '</node>\n'
	node_id = node_id - 1


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
	if prefix == "Russia":
		suffix = "" # dont use asia


	way_tags  += '\t<tag k="osmand_region" v="yes" />\n'
	way_tags  += '\t<tag k="name" v="%s" />\n' % country
	way_tags  += '\t<tag k="key_name" v="%s" />\n' % country
	way_tags  += '\t<tag k="download_name" v="%s" />\n' % full_name
	way_tags  += '\t<tag k="region_prefix" v="%s" />\n' % prefix
	way_tags  += '\t<tag k="region_suffix" v="%s" />\n' % suffix
	way_tags  += addNames(country)
	
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
	addEmptyCountryForNames('europe', 'france', 'france')
	addEmptyCountryForNames('europe', 'germany', 'germany')
	addEmptyCountryForNames('europe', 'gb', 'united-kingdom')
	addEmptyCountryForNames('northamerica', 'us','united-states')
	addEmptyCountryForNames('northamerica', 'canada', 'canada')
	addEmptyCountryForNames('asia','russia','russia')
	addEmptyCountryForNames('australia-oceania','australia','australia')
	

	process_poly_folder('polygons/europe/additional/', 'europe')
	process_poly_folder('polygons/europe/extract/', 'europe')
	process_poly_folder('geo-polygons/europe/', 'europe')
	process_poly_folder('geo-polygons/europe/germany/', 'europe', 'Germany')
	process_poly_folder('geo-polygons/europe/france/', 'europe', 'France')
# 	process_poly_folder('polygons/north-europe/', 'europe')
# 	process_poly_folder('polygons/east-europe/', 'europe')

	process_poly('geo-polygons/europe/great-britain/england/greater-london.poly', 'greater-london', 'Gb_england', 'europe')
	process_poly_folder('geo-polygons/europe/great-britain/', 'europe', 'Gb')
	process_poly_folder('polygons/europe/gb-regions/', 'europe', 'Gb_england')
	
	process_poly_folder('polygons/europe/italy-regions/', 'europe', 'Italy')
	process_poly_folder('polygons/europe/spain-regions/', 'europe', 'Spain')

	process_poly_folder('polygons/russia/', 'asia', 'Russia')
	process_poly_folder('polygons/russia-regions/', 'asia', 'Russia')

	process_poly_folder('geo-polygons/north-america/us/', 'northamerica', 'Us')
	process_poly_folder('geo-polygons/north-america/canada/', 'northamerica', 'Canada')

	process_poly_folder('geo-polygons/north-america/', 'northamerica')
	process_poly_folder('polygons/north-america/', 'northamerica')

	process_poly_folder('geo-polygons/south-america/', 'southamerica')
	process_poly_folder('polygons/south-america/', 'southamerica') 

	process_poly_folder('geo-polygons/central-america/', 'centralamerica')
	process_poly_folder('polygons/central-america/', 'centralamerica') 
	
	process_poly_folder('geo-polygons/asia/', 'asia')
	process_poly_folder('polygons/east-asia/', 'asia')
	process_poly_folder('polygons/ocean-asia/', 'asia')
	process_poly_folder('polygons/ocean-asia/japan-regions/', 'asia', 'Japan')

	process_poly('polygons/australia-oceania/oceania.poly', 'oceania', '', 'australia-oceania')
	process_poly('polygons/australia-oceania.poly', 'australia-oceania', '', '')
	process_poly_folder('geo-polygons/australia-oceania/', 'australia-oceania')
	
	process_poly('polygons/africa.poly', 'africa', '', '')
	process_poly_folder('geo-polygons/africa/', 'africa')
	process_poly_folder('polygons/africa/', 'africa')

	print "</osm>"


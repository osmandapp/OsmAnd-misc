#!/usr/bin/python
# -*- coding: utf-8 -*-

global missingRegionNames
missingRegionNames = {}
# continents
missingRegionNames['oceania']='Oceania'
missingRegionNames['australia oceania']='Australia and Oceania'
missingRegionNames['netherlands antilles'] = 'Netherlands-antilles'
missingRegionNames['channel islands'] = 'Channel islands'

missingRegionNames['carribean archipelago all'] = 'Carribean Archipelago'

# islands
global customRegionMapping
customRegionMapping = {}
# countries
# customRegionMapping['gcc states']="الإمارات العربية المتحدة"
customRegionMapping['congo democratic republic']="République Démocratique du Congo"

customRegionMapping['virgin islands us']="United States Virgin Islands"
customRegionMapping['virgin islands british']="British Virgin Islands"

customRegionMapping['united states'] = 'United States of America'
customRegionMapping['netherlands'] = 'The Netherlands'
customRegionMapping['macao'] = 'Macau'
customRegionMapping['ivory coast'] = 'Côte d\'Ivoire'
customRegionMapping['bosnia herzegovina'] = 'Bosnia and Herzegovina'
# customRegionMapping['russia'] = 'Russian Federation'

# regions
customRegionMapping['bremen'] = 'Freie Hansestadt Bremen'
customRegionMapping['gb northern ireland']='Northern Ireland'
customRegionMapping['baden wuerttemberg']='Baden-Württemberg'
customRegionMapping['valle aosta']='Valle d\'Aosta'
customRegionMapping['trentino alto adige'] = "Trentino-Alto Adige/Südtirol"
customRegionMapping['thueringen']='Thüringen'
customRegionMapping['provence alpes cote d azur']='Provence-Alpes-Côte d\'Azur'

# Russia regions 
customRegionMapping['adygeya']='Адыгея'
customRegionMapping['altay']='Республика Алтай'
customRegionMapping['altayskiy']='Алтайский край'
customRegionMapping['amur']='Амурская область'
customRegionMapping['arkhangelsk']='Архангельская область'
customRegionMapping['astrakhan']='Астраханская область'
customRegionMapping['bashkiria']='Башкортостан'
customRegionMapping['belgorod']='Белгородская область'
customRegionMapping['bryansk']='Брянская область'
customRegionMapping['chechenskaya']='Чечня'
customRegionMapping['cheliabinsk']='Челябинская область'
customRegionMapping['crimea']='Крым'
customRegionMapping['evreyskaya']='Еврейская автономная область'
customRegionMapping['irkutsk']='Иркутская область'
customRegionMapping['ivanov']='Ивановская область'
customRegionMapping['kabardino']='Кабардино-Балкария'
customRegionMapping['kaliningrad']='Калининградская область'
customRegionMapping['kaluga']='Калужская область'
customRegionMapping['kamchatka']='Камчатка'
customRegionMapping['karachaevo']='Карачаево-Черкессия'
customRegionMapping['kemerovo']='Кемеровская область'
customRegionMapping['khabarovsk']='Хабаровский край'
customRegionMapping['khakasia']='Хакасия'
customRegionMapping['khanty mansiisk']='Ханты-Мансийский автономный округ — Югра'
customRegionMapping['kirov']='Кировская область'
customRegionMapping['kostroma']='Костромская область'
customRegionMapping['krasnodar']='Краснодарский край'
customRegionMapping['krasnoyarsk']='Красноярский край'
customRegionMapping['kurgan']='Курганская область'
customRegionMapping['kursk']='Курская область'
customRegionMapping['leningradskaya']='Ленинградская область'
customRegionMapping['lipetsk']='Липецкая область'
customRegionMapping['magadan']='Магаданская область'
customRegionMapping['mariyel']='Марий Эл'
customRegionMapping['moskovskaya oblast']='Московская область'
customRegionMapping['murmansk']='Мурманская область'
customRegionMapping['neneckaya']='Ненецкий автономный округ'
customRegionMapping['nizhegorod']='Нижегородская область'
customRegionMapping['novgorod']='Новгородская область'
customRegionMapping['novosibirsk']='Новосибирская область'
customRegionMapping['omsk']='Омская область'
customRegionMapping['orel']='Орловская область'
customRegionMapping['orenburg']='Оренбургская область'
customRegionMapping['osetiya']='Северная Осетия'
customRegionMapping['primorskii']='Приморский край'
customRegionMapping['penza']='Пензенская область'
customRegionMapping['perm']='Пермский край'
customRegionMapping['pskov']='Псковская область'
customRegionMapping['rostovskaya']='Ростовская область'
customRegionMapping['ryazan']='Рязанская область'
customRegionMapping['sakhalin']='Сахалинская область'
customRegionMapping['samara']='Самарская область'
customRegionMapping['sankt peterburg']='Санкт-Петербург'
customRegionMapping['saratov']='Саратовская область'
customRegionMapping['smolensk']='Смоленская область'
customRegionMapping['stavropol']='Ставропольский край'
customRegionMapping['sverdlovsk']='Свердловская область'
customRegionMapping['tambov']='Тамбовская область'
customRegionMapping['tomsk']='Томская область'
customRegionMapping['tula']='Тульская область'
customRegionMapping['tumen']='Тюменская область'
customRegionMapping['tver']='Тверская область'
customRegionMapping['tyva']='Тува'
customRegionMapping['ulyanovsk']='Ульяновская область'
customRegionMapping['vladimir']='Владимирская область'
customRegionMapping['volgograd']='Волгоградская область'
customRegionMapping['vologda']='Вологодская область'
customRegionMapping['voronezh']='Воронежская область'
customRegionMapping['yakutia']='Саха (Якутия)'
customRegionMapping['yaroslavl']='Ярославская область'
customRegionMapping['yamal']='Ямало-Ненецкий автономный округ'
customRegionMapping['zabaikalie']='Забайкальский край'

# Spain regions
customRegionMapping['canarias']='Canary Islands'
customRegionMapping['baleares']='Balearic Islands'
customRegionMapping['asturias']='Asturies'
customRegionMapping['navarra']='Comunidad Foral de Navarra'
customRegionMapping['murcia']='Region of Murcia'
customRegionMapping['castilla leon']='Castile and León'
customRegionMapping['madrid']='Community of Madrid'

# Japan regions
customRegionMapping['hokkaido']='Hokkaido'
customRegionMapping['tohoku']='Tohoku'
customRegionMapping['kanto']='Kanto'
customRegionMapping['chubu']='Chubu Region'
customRegionMapping['kinki']='Kinki Region'
customRegionMapping['chugoku']='Chugoku Region'
customRegionMapping['shikoku']='Shikoku Region'
customRegionMapping['kyushu']='Kyushu Region'

customRegionMapping['saint-helena-ascension-and-tristan-da-cunha']='Saint Helena Ascension and Tristan da Cunha'

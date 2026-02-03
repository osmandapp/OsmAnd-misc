# Helper script to semi-automatically fix missing translations in regions.xml
# Requires regions.log obtained from ocbf generator and regions.xml path.
# Creates regions_fixed.xml in regions.xml dir.
# Changes needs to be carefully reviewed because some of them will be wrong
# but most of simple errors are fixed automatically
# Uses osm data in osm-data dir. Before use get fresh osm data using update-osm-all.sh.
# Usage: python fix_regions.py <generator.log> [regions.xml]

import os
import glob
import xml.etree.ElementTree as ET
import re
import shutil
import sys
import unicodedata
from collections import defaultdict

# Статусные части, которые нужно игнорировать при поиске
STATUS_PARTS = [
    "городской округ", "муниципальный округ", "район", "область", "край",
    "автономная область", "улус", "федеральный округ", "городское поселение",
    "сельское поселение", "город", "автономный округ", "республика", "округ",
    "province", "state", "region", "county", "district", "oblast", "krai", "republic"
]

# Кэш для нормализованных имен
_NORMALIZED_CACHE = {}
_CLEANED_CACHE = {}


def normalize_region_name(name: str) -> str:
    """Нормализует имя региона для сравнения (с кэшированием)"""
    if not isinstance(name, str):
        name = str(name)

    # Проверяем кэш
    if name in _NORMALIZED_CACHE:
        return _NORMALIZED_CACHE[name]

    # Приводим к нижнему регистру
    result = name.lower()

    # Удаляем диакритические знаки (акценты)
    result = ''.join(c for c in unicodedata.normalize('NFD', result)
                     if unicodedata.category(c) != 'Mn')

    # Заменяем дефисы, подчеркивания на пробелы
    result = re.sub(r'[-\s_]+', ' ', result)

    # Удаляем лишние пробелы
    result = result.strip()

    # Кэшируем результат
    _NORMALIZED_CACHE[name] = result
    return result


def clean_status_parts(text: str) -> str:
    """Удаляет статусные части из названия (с кэшированием)"""
    # Проверяем кэш
    if text in _CLEANED_CACHE:
        return _CLEANED_CACHE[text]

    text_lower = text.lower()

    # Удаляем каждый статус из списка
    for status_part in STATUS_PARTS:
        # Удаляем в конце строки с пробелом или запятой перед
        pattern1 = r'\s+' + re.escape(status_part) + r'$'
        text_lower = re.sub(pattern1, '', text_lower)

        # Удаляем с запятой и пробелами
        pattern2 = r',\s*' + re.escape(status_part)
        text_lower = re.sub(pattern2, '', text_lower)

        # Удаляем если статус стоит в начале
        pattern3 = r'^' + re.escape(status_part) + r'\s+'
        text_lower = re.sub(pattern3, '', text_lower)

    # Удаляем возможные лишние пробелы после удаления
    text_lower = re.sub(r'\s+', ' ', text_lower)
    text_lower = text_lower.strip()

    # Кэшируем результат
    _CLEANED_CACHE[text] = text_lower
    return text_lower


def load_osm_data(directory='osm-data'):
    """Загружает OSM данные (исправленная версия с дедупликацией)"""
    objects_dict = {}

    for filepath in glob.glob(os.path.join(directory, '*.osm')):
        try:
            tree = ET.parse(filepath)
            root = tree.getroot()

            for elem in root:
                if elem.tag in ('node', 'way', 'relation'):
                    tags = {}
                    for tag in elem.findall('tag'):
                        k = tag.get('k')
                        v = tag.get('v')
                        if k and v:
                            tags[k] = v

                    obj = {
                        'type': elem.tag,
                        'tags': tags,
                        'id': elem.get('id')
                    }
                    key = (obj['type'], obj['id'])
                    if key not in objects_dict:
                        objects_dict[key] = obj

        except Exception as e:
            print(f"Error parsing {filepath}: {e}")

    return list(objects_dict.values())


def extract_region_from_error(line: str) -> str | None:
    """Извлекает имя региона из строки ошибки"""
    line = line.strip()
    if not line.startswith('!!!') or "translation" not in line:
        return None

    # Быстрое извлечение спецификации перевода
    if "translation " in line:
        spec_part = line.split("translation ", 1)[1].strip()
    else:
        return None

    # Быстрый парсинг спецификации
    tags = {}
    entity = 'node'

    if spec_part.startswith('name ') and not spec_part.startswith('name='):
        spec_part = spec_part[5:].strip()

    parts = [p.strip() for p in spec_part.split(';') if p.strip()]
    name_value = None

    for p in parts:
        if '=' in p:
            pos = p.find('=')
            k = p[:pos].strip()
            v = p[pos + 1:].strip()
            if ' ' in k:
                if name_value is None:
                    name_value = p
            else:
                if k == 'entity':
                    entity = v
                else:
                    tags[k] = v
        elif p == 'name':
            continue
        elif name_value is None:
            name_value = p

    if name_value:
        tags['name'] = name_value

    # Определяем имя региона - ВАЖНО: НЕ заменяем пробелы на дефисы!
    if 'name' in tags:
        # Возвращаем как есть, с пробелами
        return tags['name'].lower()
    elif 'name:en' in tags:
        return tags['name:en'].lower()
    elif tags:
        return list(tags.values())[0].lower()

    return None

def parse_translate_spec(spec: str):
    """Быстрый парсинг спецификации перевода"""
    tags = {}
    entity = 'node'
    name_value = None

    if spec.startswith('name ') and not spec.startswith('name='):
        spec = spec[5:].strip()

    parts = [p.strip() for p in spec.split(';') if p.strip()]

    for p in parts:
        if '=' in p:
            pos = p.find('=')
            k = p[:pos].strip()
            v = p[pos + 1:].strip()
            if ' ' in k:
                if name_value is None:
                    name_value = p
            else:
                if k == 'entity':
                    entity = v
                else:
                    tags[k] = v
        elif p == 'name':
            continue
        elif name_value is None:
            name_value = p

    if name_value:
        tags['name'] = name_value

    return tags, entity


def get_preferred_name_tags(tags: dict):
    """Быстрое получение предпочтительных тегов имени"""
    if 'name:en' in tags:
        return {'name:en': tags['name:en']}
    if 'name' in tags:
        return {'name': tags['name']}
    name_keys = [k for k in tags if k.startswith('name:')]
    if name_keys:
        return {name_keys[0]: tags[name_keys[0]]}
    return {'name': 'UNKNOWN'}


def extract_search_terms(region_name: str):
    """Извлекает поисковые термины для региона"""
    search_terms = []

    # Исходное имя (в нижнем регистре)
    original_lower = region_name.lower()
    search_terms.append(original_lower)

    # Варианты с заменой дефисов на пробелы и наоборот
    if '-' in original_lower:
        # Если есть дефисы, добавляем вариант с пробелами
        spaced = original_lower.replace('-', ' ')
        if spaced != original_lower:
            search_terms.append(spaced)
    elif ' ' in original_lower:
        # Если есть пробелы, добавляем вариант с дефисами
        hyphenated = original_lower.replace(' ', '-')
        if hyphenated != original_lower:
            search_terms.append(hyphenated)

    # Теперь для каждого варианта применяем очистку и нормализацию
    final_terms = set()  # Используем set для уникальности

    for term in search_terms:
        # Сначала очищаем от статусных частей
        cleaned = clean_status_parts(term)
        # Затем нормализуем (убираем акценты и т.д.)
        normalized = normalize_region_name(cleaned)

        if normalized:
            final_terms.add(normalized)

    # Также добавляем вариант без статусных частей из исходного имени
    cleaned_original = clean_status_parts(original_lower)
    normalized_cleaned = normalize_region_name(cleaned_original)
    if normalized_cleaned:
        final_terms.add(normalized_cleaned)

    return list(final_terms)


def create_search_index(objects):
    """Создает индекс для быстрого поиска объектов"""
    name_index = defaultdict(list)
    type_index = defaultdict(list)

    for obj in objects:
        # Индексируем по именам
        seen_normalized = set()  # To avoid appending the same obj multiple times for same normalized
        for tag_key, tag_value in obj['tags'].items():
            if isinstance(tag_value, str) and tag_key.startswith('name'):
                # Сначала очищаем от статусных частей
                cleaned = clean_status_parts(tag_value)
                # Затем нормализуем
                normalized = normalize_region_name(cleaned)

                if normalized and normalized not in seen_normalized:
                    seen_normalized.add(normalized)
                    name_index[normalized].append(obj)

        # Индексируем по типу
        type_index[obj['type']].append(obj)

    return name_index, type_index


def search_in_osm_index(search_terms, name_index, objects):
    """Ищет кандидатов в индексе OSM данных по очищенным именам"""
    candidates_set = set()

    if not search_terms:
        return []

    # Пробуем все поисковые термины
    for search_term in search_terms:
        if not search_term:
            continue

        # 1. Ищем точное совпадение в индексе
        if search_term in name_index:
            for obj in name_index[search_term]:
                candidates_set.add(id(obj))

        # 2. Если не нашли, ищем частичные совпадения (только для достаточно длинных терминов)
        if len(search_term) > 3:
            for indexed_name, objs in name_index.items():
                # Очищаем индексированное имя от статусных частей
                cleaned_indexed_name = clean_status_parts(indexed_name)
                # Нормализуем очищенное имя
                normalized_indexed_name = normalize_region_name(cleaned_indexed_name)

                # Проверяем разные варианты совпадений (удалена проверка normalized_indexed_name in search_term)
                if (search_term == normalized_indexed_name or
                        search_term in normalized_indexed_name):
                    for obj in objs:
                        candidates_set.add(id(obj))

    # Преобразуем обратно в объекты
    candidates = []
    seen = set()
    for o in objects:
        if id(o) in candidates_set and id(o) not in seen:
            seen.add(id(o))
            candidates.append(o)

    return candidates

def is_valid_candidate(obj, search_terms):
    """Проверяет, что кандидат действительно содержит искомый термин"""
    # Проверяем все поисковые термины
    for search_term in search_terms:
        if not search_term:
            continue

        for tag_key, tag_value in obj['tags'].items():
            if isinstance(tag_value, str) and tag_key.startswith('name'):
                # Сначала очищаем от статусных частей
                cleaned_value = clean_status_parts(tag_value)
                # Затем нормализуем
                normalized_value = normalize_region_name(cleaned_value)

                # Проверяем точное совпадение (удалена проверка normalized_value in search_term)
                if normalized_value == search_term:
                    return True

                # Проверяем вхождение (только search_term in normalized_value)
                if search_term in normalized_value:
                    return True

    return False

def find_matches_optimized(objects, tag_dict, entity, name_index=None, type_index=None):
    """Оптимизированный поиск совпадений"""
    if not tag_dict:
        return []

    # Если есть индекс имен, используем его
    if name_index is not None:
        name_keys = [k for k in tag_dict if k.startswith('name')]
        if name_keys:
            k = name_keys[0]
            v = tag_dict[k]
            cleaned_v = clean_status_parts(v)
            normalized_v = normalize_region_name(cleaned_v)
            candidates = name_index.get(normalized_v, [])
            # Dedup candidates
            unique_candidates = []
            seen = set()
            for cand in candidates:
                if id(cand) not in seen:
                    seen.add(id(cand))
                    unique_candidates.append(cand)
            # Фильтруем по типу и остальным тегам
            result = []
            seen_ids = set()
            for cand in unique_candidates:
                if cand['type'] == entity and all(cand['tags'].get(k2) == v2 for k2, v2 in tag_dict.items()) and cand['id'] not in seen_ids:
                    seen_ids.add(cand['id'])
                    result.append(cand)
            return result

    # Стандартный поиск
    result = []
    seen_ids = set()
    for o in objects:
        if o['type'] == entity and all(o['tags'].get(k) == v for k, v in tag_dict.items()) and o['id'] not in seen_ids:
            seen_ids.add(o['id'])
            result.append(o)
    return result


def get_relevance_score(obj, log_prefix=""):
    """Оценивает релевантность объекта как кандидата на регион"""
    score = 0
    tags = obj['tags']

    # Большой бонус за administrative boundary
    if tags.get('boundary') == 'administrative':
        score += 10
        if log_prefix:
            print(f"{log_prefix}+10 for administrative boundary")

    # Бонус за admin_level (особенно 4-6 для регионов)
    if 'admin_level' in tags:
        try:
            admin_level = int(tags['admin_level'])
            if 4 <= admin_level <= 6:
                score += 8
                if log_prefix:
                    print(f"{log_prefix}+8 for admin_level {admin_level} (4-6)")
            elif admin_level <= 3:
                score += 5
                if log_prefix:
                    print(f"{log_prefix}+5 for admin_level {admin_level} (<=3)")
            elif admin_level <= 8:
                score += 3
                if log_prefix:
                    print(f"{log_prefix}+3 for admin_level {admin_level} (7-8)")
        except:
            pass

    # Бонус за type=boundary в relation
    if obj['type'] == 'relation' and tags.get('type') == 'boundary':
        score += 5
        if log_prefix:
            print(f"{log_prefix}+5 for relation with type=boundary")

    # Небольшой бонус за name:en
    if 'name:en' in tags:
        score += 2
        if log_prefix:
            print(f"{log_prefix}+2 for name:en")

    # Бонус за name:ru (если есть кириллица)
    if 'name:ru' in tags:
        score += 3
        if log_prefix:
            print(f"{log_prefix}+3 for name:ru")

    # Бонус за официальное имя
    if 'official_name' in tags:
        score += 4
        if log_prefix:
            print(f"{log_prefix}+4 for official_name")

    if log_prefix:
        print(f"{log_prefix}Total score: {score}")
    return score


def add_discriminator(best, trans_tags, entity, matches, objects, log_prefix=""):
    """Добавляет дискриминаторы для уникальности"""
    if log_prefix:
        print(f"{log_prefix}Starting discriminator with {len(matches)} matches")
    trans_tags = trans_tags.copy()
    other_matches = [m for m in matches if m.get('id') != best.get('id')]
    if log_prefix:
        print(f"{log_prefix}{len(other_matches)} other matches to discriminate from")

    # Приоритетные ключи для дискриминации
    disc_keys = [k for k in best['tags'] if
                 k.startswith(('ref', 'ISO', 'admin_level', 'int_', 'wikidata', 'wikipedia', 'boundary', 'place'))]

    if log_prefix:
        print(f"{log_prefix}Available discriminator keys: {disc_keys}")

    for dk in disc_keys:
        dv = best['tags'].get(dk)
        if dv:
            if log_prefix:
                print(f"{log_prefix}Trying discriminator {dk}={dv}")
            all_different = all(om['tags'].get(dk) != dv for om in other_matches)
            if all_different:
                if log_prefix:
                    print(f"{log_prefix}  All other matches have different value for {dk}")
                trans_tags[dk] = dv
                # Быстрая проверка уникальности
                new_matches = find_matches_optimized(objects, trans_tags, entity)
                if len(new_matches) == 1:
                    if log_prefix:
                        print(f"{log_prefix}  Success! Unique match found with {dk}={dv}")
                    break
            else:
                if log_prefix:
                    print(f"{log_prefix}  Not all different for {dk}")

    result = ';'.join([f"{k}={v}" for k, v in trans_tags.items()] + [f"entity={entity}"])
    if log_prefix:
        print(f"{log_prefix}Final discriminator result: {result}")
    return result


def find_region_name_by_translate(xml_text: str, region_from_log: str) -> str | None:
    """Ищет регион в XML по содержимому translate"""
    # Нормализуем имя региона из лога
    normalized_log_region = normalize_region_name(region_from_log)
    cleaned_log_region = clean_status_parts(normalized_log_region)

    # Используем скомпилированные регулярки для быстрого поиска
    region_pattern = re.compile(r'<region[^>]*>')
    name_pattern = re.compile(r'name=["\']([^"\']*)["\']')
    translate_pattern = re.compile(r'translate=["\']([^"\']*)["\']')

    for tag in region_pattern.findall(xml_text):
        # Извлекаем атрибут name
        name_match = name_pattern.search(tag)
        if not name_match:
            continue

        region_name_in_xml = name_match.group(1)

        # Проверяем атрибут translate
        translate_match = translate_pattern.search(tag)

        if translate_match:
            # Есть атрибут translate, парсим его
            translate_value = translate_match.group(1)
            tags, _ = parse_translate_spec(translate_value)

            # Проверяем разные варианты имен
            check_names = []
            if 'name' in tags:
                check_names.append(tags['name'])
            if 'name:en' in tags:
                check_names.append(tags['name:en'])
        else:
            # Нет атрибута translate
            check_names = [region_name_in_xml]

        # Проверяем каждое имя
        for name in check_names:
            normalized_name = normalize_region_name(name)
            cleaned_name = clean_status_parts(normalized_name)

            if cleaned_name == cleaned_log_region or normalized_name == normalized_log_region:
                return region_name_in_xml

    return None


def update_region_translate(xml_text: str, region_from_log: str, new_translate: str) -> str:
    """Обновляет translate для региона"""
    region_name_in_xml = find_region_name_by_translate(xml_text, region_from_log)

    if not region_name_in_xml:
        return xml_text

    # Скомпилированный паттерн для поиска
    pattern = re.compile(rf'(<region\s+[^>]*name\s*=\s*["\']{re.escape(region_name_in_xml)}["\'][^>]*)(/?>)',
                         re.IGNORECASE)
    translate_pattern = re.compile(r'(translate\s*=\s*["\'])([^"\']*)(["\'])')

    def replacer(m):
        tag_start = m.group(1)
        closing = m.group(2)

        if 'translate=' in tag_start:
            tag_start = translate_pattern.sub(lambda x: x.group(1) + new_translate + x.group(3), tag_start)
        else:
            if tag_start.strip().endswith('/'):
                tag_start = tag_start.rstrip()[:-1] + f' translate="{new_translate}" /'
            else:
                tag_start = tag_start.rstrip() + f' translate="{new_translate}"'

        return tag_start + closing

    return pattern.sub(replacer, xml_text)


def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_regions.py <generator.log> [regions.xml]")
        sys.exit(1)

    log_file = sys.argv[1]
    regions_file = sys.argv[2] if len(sys.argv) > 2 else "/home/xmd5a/git/OsmAnd-resources/countries-info/regions.xml"

    # Изменено: вместо замены оригинального файла создаём fixed версию
    fixed_file = regions_file.replace(".xml", "_fixed.xml")

    # Создаём backup оригинального файла (опционально, на всякий случай)
    bak_file = regions_file + ".bak"
    if os.path.exists(regions_file):
        shutil.copy2(regions_file, bak_file)

    log_out = open(f"{os.path.basename(__file__)}.log", "a", encoding="utf-8")

    def log(msg):
        print(msg)
        log_out.write(msg + "\n")
        log_out.flush()

    # Быстрое чтение и обработка лога
    fixes = {}
    with open(log_file, encoding='utf-8', errors='ignore') as f:
        for line in f:
            if not line.strip().startswith("!!!"):
                continue
            region_name = extract_region_from_error(line)
            if not region_name:
                continue
            if "Couldn't find" in line:
                spec = line.split("translation ", 1)[1].strip() if "translation " in line else ""
                fixes[region_name] = {'type': 'couldnt', 'spec': spec}
            elif "More than 1" in line:
                spec = line.split("translation ", 1)[1].strip() if "translation " in line else ""
                fixes[region_name] = {'type': 'more1', 'spec': spec}

    if not fixes:
        log("No translation errors found.")
        log_out.close()
        return

    osm_objects = load_osm_data()
    log(f"Loaded {len(osm_objects)} OSM objects.")
    log(f"Found {len(fixes)} translation errors to process.")

    name_index, type_index = create_search_index(osm_objects)

    fix_dict = {}
    not_fixed = []

    for region_name, err in fixes.items():
        try:
            search_terms = extract_search_terms(region_name)
            if not search_terms:
                log(f"{region_name}: No search terms")
                not_fixed.append(region_name)
                continue

            if err['type'] == 'couldnt':
                spec_tags, spec_entity = parse_translate_spec(err['spec'])
                matches = find_matches_optimized(osm_objects, spec_tags, spec_entity, name_index, type_index)

                if not matches:
                    candidates = search_in_osm_index(search_terms, name_index, osm_objects)
                    filtered_candidates = [cand for cand in candidates if is_valid_candidate(cand, search_terms)]
                    candidates = filtered_candidates

                    if not candidates:
                        log(f"{region_name}: No candidates found")
                        not_fixed.append(region_name)
                        continue

                    seen_ids = set()
                    unique_candidates = [cand for cand in candidates if
                                         not (cand['id'] in seen_ids or seen_ids.add(cand['id']))]
                    candidates = unique_candidates

                    candidates.sort(key=lambda x: get_relevance_score(x, ""), reverse=True)
                    best = candidates[0]

                    trans_tags = get_preferred_name_tags(best['tags'])
                    entity = best['type']
                    new_trans = ';'.join([f"{k}={v}" for k, v in trans_tags.items()] + [f"entity={entity}"])

                    if len(candidates) == 1:
                        fix_dict[region_name] = new_trans
                        log(f"{region_name}: Fixed (unique candidate)")
                    else:
                        new_tags, new_entity = parse_translate_spec(new_trans)
                        new_matches = find_matches_optimized(osm_objects, new_tags, new_entity, name_index, type_index)

                        if len(new_matches) != 1:
                            new_trans = add_discriminator(best, trans_tags, entity, new_matches, osm_objects, "")
                            final_tags, final_entity = parse_translate_spec(new_trans)
                            final_matches = find_matches_optimized(osm_objects, final_tags, final_entity, name_index,
                                                                   type_index)

                            if len(final_matches) != 1:
                                log(f"{region_name}: Could not find unique match")
                                not_fixed.append(region_name)
                                continue

                        fix_dict[region_name] = new_trans
                        log(f"{region_name}: Fixed with discriminator")

                else:
                    best = max(matches, key=lambda o: sum(1 for k in o['tags'] if k.startswith('name')))
                    trans_tags = get_preferred_name_tags(best['tags'])
                    entity = best['type']
                    log(f"{region_name}: Found {len(matches)} matches, using best")

            elif err['type'] == 'more1':
                spec_tags, spec_entity = parse_translate_spec(err['spec'])
                matches = find_matches_optimized(osm_objects, spec_tags, spec_entity, name_index, type_index)

                if len(matches) <= 1:
                    log(f"{region_name}: No multiple matches")
                    not_fixed.append(region_name)
                    continue

                best = max(matches, key=lambda o: sum(1 for k in o['tags'] if k.startswith('name')))
                trans_tags = get_preferred_name_tags(best['tags'])
                entity = best['type']

                matches2 = find_matches_optimized(osm_objects, trans_tags, entity, name_index, type_index)
                if len(matches2) == 1:
                    new_trans = ';'.join([f"{k}={v}" for k, v in trans_tags.items()] + [f"entity={entity}"])
                else:
                    new_trans = add_discriminator(best, trans_tags, entity, matches2, osm_objects)
                    final_tags, final_entity = parse_translate_spec(new_trans)
                    final_matches = find_matches_optimized(osm_objects, final_tags, final_entity, name_index,
                                                           type_index)

                    if len(final_matches) != 1:
                        log(f"{region_name}: Could not find unique match")
                        not_fixed.append(region_name)
                        continue

                fix_dict[region_name] = new_trans
                log(f"{region_name}: Fixed multiple matches")

        except Exception as e:
            log(f"{region_name}: Error - {e}")
            not_fixed.append(region_name)

    log(f"\n{'=' * 50}")
    log("PROCESSING SUMMARY:")
    log(f"Total errors found: {len(fixes)}")
    log(f"Successfully fixed: {len(fix_dict)}")
    log(f"Failed to fix: {len(not_fixed)}")

    if not_fixed:
        log("Failed regions:")
        for reg in not_fixed:
            log(f"  - {reg}")

    if fix_dict:
        with open(regions_file, encoding='utf-8') as f:
            xml_text = f.read()

        for reg, nt in fix_dict.items():
            region_name_in_xml = find_region_name_by_translate(xml_text, reg)
            if region_name_in_xml:
                xml_text = update_region_translate(xml_text, reg, nt)
            else:
                log(f"WARNING: Region '{reg}' not found in XML")

        # Изменено: записываем в regions_fixed.xml вместо замены оригинального
        with open(fixed_file, 'w', encoding='utf-8') as f:
            f.write(xml_text)

        log(f"\nApplied {len(fix_dict)} fixes → {fixed_file}")
        log(f"Original file preserved: {regions_file}")
        log(f"Backup created: {bak_file}")
    else:
        log("\nNo fixes were applied.")
        # Удаляем backup если не было изменений
        if os.path.exists(bak_file):
            os.remove(bak_file)
            log(f"Removed backup file: {bak_file}")

    log_out.close()

if __name__ == "__main__":
    main()
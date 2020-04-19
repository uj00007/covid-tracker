bool validateMapKey(String key, Map map) {
  return map != null && map.containsKey('$key') && map[key] != null;
}

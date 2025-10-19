# core/entity_manager.gd
# Добавьте этот скрипт как Autoload (синглтон) с именем "EntityManager"
# в Project -> Project Settings -> Autoload.
extends Node

## Менеджер сущностей и компонентов (простой ECS)
## Сущность представлена числовым ID, к которому можно прикреплять ресурсы-компоненты
## Все комментарии на русском согласно требованиям проекта

signal entity_removed(entity_id)
signal entity_component_added(entity_id, component)
signal entity_component_removed(entity_id, component)

var next_entity_id: int = 0
# Структура: {id: {component_key: component_instance}}
var entities: Dictionary = {}

# --- Вспомогательные функции ---
func _get_component_key(component: Resource) -> String:
	# Ключом компонента выступает путь к его скрипту
	return component.get_script().get_path()

func _get_component_key_from_class(component_class: Script) -> String:
	# Берем путь к скрипту по переданному классу
	return component_class.get_path()

# --- API ---
# Создает пустую сущность и возвращает ее ID
func create_entity() -> int:
	var id := next_entity_id
	entities[id] = {}
	next_entity_id += 1
	return id

# Добавляет компонент к сущности
func add_component(entity_id: int, component: Resource) -> void:
	if not entities.has(entity_id):
		return
	var key := _get_component_key(component)
	entities[entity_id][key] = component
	emit_signal("entity_component_added", entity_id, component)

# Удаляет компонент у сущности
func remove_component(entity_id: int, component_class: Script) -> void:
	if not entities.has(entity_id):
		return
	var key := _get_component_key_from_class(component_class)
	if entities[entity_id].has(key):
		var comp: Resource = entities[entity_id][key] as Resource
		entities[entity_id].erase(key)
		emit_signal("entity_component_removed", entity_id, comp)

# Получает компонент сущности по типу (классу)
func get_component(entity_id: int, component_class: Script) -> Resource:
	var key := _get_component_key_from_class(component_class)
	if entities.has(entity_id) and entities[entity_id].has(key):
		return entities[entity_id][key]
	return null

# Проверяет наличие компонента у сущности
func has_component(entity_id: int, component_class: Script) -> bool:
	if not entities.has(entity_id):
		return false
	var key := _get_component_key_from_class(component_class)
	return entities[entity_id].has(key)

# Находит все сущности, у которых есть заданный набор компонентов
func get_entities_with_components(component_classes: Array[Script]) -> Array[int]:
	var result: Array[int] = []
	for entity_id in entities.keys():
		var has_all := true
		for component_class in component_classes:
			var key := _get_component_key_from_class(component_class)
			if not entities[entity_id].has(key):
				has_all = false
				break
		if has_all:
			result.append(entity_id)
	return result

# Возвращает список сущностей, находящихся в заданной клетке
func get_entities_at_position(x: int, y: int) -> Array[int]:
	var result: Array[int] = []
	var with_pos := get_entities_with_components([PositionComponent])
	for id in with_pos:
		var pos: PositionComponent = get_component(id, PositionComponent)
		if pos and pos.x == x and pos.y == y:
			result.append(id)
	return result

# Полностью удаляет сущность
func remove_entity(entity_id: int) -> void:
	if not entities.has(entity_id):
		return
	# Эмитим события удаления компонентов для корректного обновления рендера
	for comp in entities[entity_id].values():
		emit_signal("entity_component_removed", entity_id, comp)
	entities.erase(entity_id)
	emit_signal("entity_removed", entity_id)

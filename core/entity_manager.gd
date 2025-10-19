# core/entity_manager.gd
# Добавьте этот скрипт как Autoload (синглтон) с именем "EntityManager"
# в Project -> Project Settings -> Autoload.
extends Node

var next_entity_id: int = 0
# Структура: {id: {component_path: component_instance}}
var entities: Dictionary = {} 

signal entity_removed(entity_id)

# Создает пустую сущность и возвращает ее ID
func create_entity() -> int:
    var id = next_entity_id
    entities[id] = {}
    next_entity_id += 1
    return id

# Добавляет компонент к сущности
func add_component(entity_id: int, component: Resource):
    if entities.has(entity_id):
        entities[entity_id][component.get_script().get_path()] = component

# Получает компонент сущности по типу (классу)
func get_component(entity_id: int, component_class: Script) -> Resource:
    var path = component_class.get_path()
    if entities.has(entity_id) and entities[entity_id].has(path):
        return entities[entity_id][path]
    return null

# Находит все сущности, у которых есть заданный набор компонентов
func get_entities_with_components(component_classes: Array[Script]) -> Array[int]:
    var result: Array[int] = []
    for entity_id in entities.keys():
        var has_all = true
        for component_class in component_classes:
            if not entities[entity_id].has(component_class.get_path()):
                has_all = false
                break
        if has_all:
            result.append(entity_id)
    return result

func remove_entity(entity_id: int):
    if entities.has(entity_id):
        entities.erase(entity_id)
        emit_signal("entity_removed", entity_id)

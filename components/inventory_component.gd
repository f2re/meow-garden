# components/inventory_component.gd
class_name InventoryComponent
extends Resource

## Компонент инвентаря для хранения предметов.
## items - словарь, где ключ - это ID предмета, а значение - количество.

@export var items: Dictionary = {}

func add_item(item_id: String, quantity: int = 1):
	if items.has(item_id):
		items[item_id] += quantity
	else:
		items[item_id] = quantity
	print("Добавлен предмет: %s, количество: %d" % [item_id, quantity])

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if items.has(item_id) and items[item_id] >= quantity:
		items[item_id] -= quantity
		if items[item_id] == 0:
			items.erase(item_id)
		print("Удален предмет: %s, количество: %d" % [item_id, quantity])
		return true
	else:
		print("Недостаточно предметов '%s' для удаления." % item_id)
		return false

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

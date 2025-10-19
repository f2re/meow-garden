# components/garden_tool_component.gd
class_name GardenToolComponent
extends Resource

## Компонент для садовых инструментов.
## efficiency - эффективность инструмента (например, для полива).
## durability - прочность инструмента.

@export var efficiency: int = 1
@export var durability: int = 100

func _init(eff: int = 1, dur: int = 100):
	efficiency = eff
	durability = dur
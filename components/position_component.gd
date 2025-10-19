# components/position_component.gd
class_name PositionComponent
extends Resource

@export var x: int = 0
@export var y: int = 0

func _init(px: int = 0, py: int = 0):
    x = px
    y = py

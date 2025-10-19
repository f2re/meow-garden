# components/actor_component.gd
# Компонент-маркер для всех, кто может совершать ходы
class_name ActorComponent
extends Resource

@export var speed: int = 10
@export var is_player: bool = false

extends Node
class_name HealthComponent

signal full_healed
signal died
signal hp_changed(hp: int)

@export var max_health = 100
var hp = max_health:
    get:
        return hp
    set(v):
        hp = clamp(v, 0, max_health)

        hp_changed.emit(hp)

        if hp == max_health:
            full_healed.emit()

        if (hp == 0):
            died.emit()

func get_health() -> int:
    return hp

func get_max_health() -> int:
    return max_health

func heal(amount: int) -> int:
    hp = hp + amount
    return hp

func hurt(amount: int) -> int:
    hp = hp - amount
    return hp

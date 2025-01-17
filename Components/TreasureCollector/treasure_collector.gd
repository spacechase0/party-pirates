## This script defines a TreasureCollector node that follows a target node and leaves a trail of treasure behind it.
class_name TreasureCollector
extends Area2D

## The node that the trail of treasures should follow.
@export var to_follow: Node2D
## The speed at which the treasure moves. Higher values are clunky.
@export_range(0, 10.0) var follow_speed = 4.0
## The distance needed for the tail to begin following.
@export var following_distance := 50
## The distance between nodes in the tail. Note that the constant LAG_BEHIND_FACTOR also affects it.
@export var tail_padding := 20
## If true, followers will be added upon collision with this TreasureCollector. 
@export var auto_collect_followers := true

## A follower will move towards the location of the previous (or earlier) follower, but not exactly;
## Rather than targetting its exact position, it will go slightly behind.
const LAG_BEHIND_FACTOR := 5
var collected_treasure: Array[Treasure] = []


func _ready() -> void:
	assert(to_follow != null, "TreasureCollector: property [to_follow] must not be null.")
	assert("velocity" in to_follow, "TreasureCollector: property [to_follow] must have velocity property.")


func _on_treasure_entered(treasure: Treasure) -> void:
	if treasure.is_collected: return
	treasure.is_collected = true
	
	collected_treasure.push_back(treasure)


func _physics_process(delta: float) -> void:
	if collected_treasure.is_empty(): return
	if collected_treasure[0].global_position.distance_to(to_follow.global_position) < following_distance: return
	
	var direction: Vector2 = to_follow.velocity.normalized() * delta
	direction *= -LAG_BEHIND_FACTOR
	
	# Move the first treasure closer to to_follow.
	var first = collected_treasure[0]
	first.global_position = direction + first.global_position.lerp(to_follow.global_position, follow_speed * delta)
	
	# Move the rest of the treasure to the previous treasure.
	for i in range(1, collected_treasure.size()):
		var previous := collected_treasure[i - 1]
		var current := collected_treasure[i]
		if previous.global_position.distance_to(current.global_position) >= tail_padding:
			current.global_position = direction + current.global_position.lerp(previous.global_position, follow_speed * delta)


## Deletes the treasure nodes, removes them from the array, and returns the count of treasure.
func empty_treasure() -> int:
	var size = collected_treasure.size()
	
	for treasure in collected_treasure:
		treasure.queue_free()
	
	collected_treasure = []
	
	return size

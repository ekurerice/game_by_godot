extends Node2D

const COLLISION_MASK_CARD = 1
var card_being_dragged = null
var screen_size: Vector2
var is_hovering_over_card: bool = false
 
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			finish_drag()
			card_being_dragged = null
			print("Left Click Released")

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		# return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(result):
	var highest_z_index = -100
	var highest_z_index_card = null
	for r in result:
		if r.collider.get_parent().z_index > highest_z_index:
			highest_z_index = r.collider.get_parent().z_index
			highest_z_index_card = r.collider.get_parent()
	return highest_z_index_card

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)

func finish_drag():
	if card_being_dragged:
		card_being_dragged.scale = Vector2(1.05, 1.05)
	card_being_dragged = null


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_over_card:
		is_hovering_over_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	# ドラッグされている時は他のカードを操作しない
	if !card_being_dragged:
		highlight_card(card, false)
		# is_hovering_over_card = false
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_over_card = false


func highlight_card(card, hovered: bool):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
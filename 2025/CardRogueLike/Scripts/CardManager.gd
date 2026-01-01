extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.1
const DEFAULT_CARD_SCALE = 0.8
const CARD_BIGGER_SCALE = 0.85
const CARD_SMALLER_SCALE = 0.6
var card_being_dragged = null
var screen_size: Vector2
var is_hovering_over_card: bool = false
var player_hand_reference: PlayerHand
var input_manager_reference: InputManager

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	input_manager_reference = $"../InputManager"
	input_manager_reference.connect("left_mouse_button_released", on_left_click_released)

func highlight_card(card, hovered: bool):
	if hovered:
		card.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1


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
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)

func finish_drag():
	card_being_dragged.scale = Vector2(CARD_BIGGER_SCALE, CARD_BIGGER_SCALE)
	
	var card_slot_found = raycast_check_for_card_slot()

	if card_slot_found and not card_slot_found.card_in_slot:
		card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE, CARD_SMALLER_SCALE)
		card_being_dragged.z_index = -1 
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.card_slot_card_is_in = card_slot_found
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		
		card_slot_found.card_in_slot = true
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_over_card:
		is_hovering_over_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	# Check if card is Not in a card slot AND NOT being dragged
	if !card.card_slot_card_is_in && !card_being_dragged:
		highlight_card(card, false)
		# is_hovering_over_card = false
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_over_card = false

func on_left_click_released():
	if card_being_dragged:
		finish_drag()
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

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		print("Detected something: ", result[0].collider.name)
		print("Detected something: ", result[0].collider.collision_mask) # 何に当たったか出力
		return result[0].collider.get_parent()
	return null

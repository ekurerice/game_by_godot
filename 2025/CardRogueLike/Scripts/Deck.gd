extends Node2D

class_name Deck

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DRAW_SPEED = 1
const STARTING_HAND_SIZE = 5
var player_deck: Array[String] = ["Knight", "Archer", "Demon", "Knight", "Knight", "Knight", "Knight"]
var card_database_reference
var drawn_card_this_turn: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://Scripts/CardDatabase.gd")

	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	drawn_card_this_turn = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_card():
	if drawn_card_this_turn:
		return
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(player_deck.size())

	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card: Card = card_scene.instantiate() as Card
	var card_image_path = str("res://Assets/" + card_drawn_name + "Card.png")
	
	# 画像のアサイン
	var texture = load(card_image_path)
	# 目標のサイズ（例: 200x300ピクセル）
	new_card.get_node("CardImage").texture = texture
	# 目標のサイズ（例: 200x300ピクセル）

	# set_card_image(new_card.get_node("CardImage").texture, load(card_image_path))
	new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name][0])
	new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn_name][1])
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

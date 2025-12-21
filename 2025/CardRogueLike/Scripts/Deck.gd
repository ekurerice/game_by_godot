extends Node2D

class_name Deck

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DRAW_SPEED = 1
var player_deck: Array[String] = ["Knight", "Knight", "Knight"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.text = str(player_deck.size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false

	$RichTextLabel.text = str(player_deck.size())

	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card: Card = card_scene.instantiate() as Card
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)

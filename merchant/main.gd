extends Node2D

@onready var merchant = $merchant
@onready var shop = $CanvasLayer/shopUI

func _process(delta):

	if Input.is_action_just_pressed("ui_accept"):
		shop.open_shop(merchant)

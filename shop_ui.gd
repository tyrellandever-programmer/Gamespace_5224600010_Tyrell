extends Control

var merchant

@onready var coins_label = $Panel/VBoxContainer/CoinsLabel
@onready var message_label = $Panel/VBoxContainer/MessageLabel

func _ready():
	visible = false


func open_shop(m):
	merchant = m
	visible = true
	update_coins()
	message_label.text = ""


func update_coins():
	coins_label.text = "Coins: " + str(PlayerData.coins)


func buy_item(index):

	var item = merchant.items[index]

	if PlayerData.coins >= item["price"]:

		PlayerData.coins -= item["price"]

		PlayerData.inventory.append(item["name"])

		message_label.modulate = Color.GREEN
		message_label.text = "Berhasil membeli " + item["name"]

		update_coins()

	else:

		message_label.modulate = Color.RED
		message_label.text = "Koin tidak cukup"


func _on_potion_pressed():
	buy_item(0)


func _on_sword_pressed():
	buy_item(1)


func _on_shield_pressed():
	buy_item(2)


func _on_close_pressed():
	visible = false

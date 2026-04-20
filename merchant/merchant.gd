extends Node2D

@export var player_data: PlayerData

var items = [
	{"name":"Potion","price":10},
	{"name":"Sword","price":50},
	{"name":"Shield","price":40}
]

func buy_item(index):
	var item = items[index]

	if player_data.coins >= item["price"]:
		player_data.coins -= item["price"]
		player_data.inventory.append(item["name"])
		print("Membeli ", item["name"])
	else:
		print("Koin tidak cukup")

extends Node2D

var items = [
	{"name":"Potion","price":10},
	{"name":"Sword","price":50},
	{"name":"Shield","price":40}
]

func buy_item(index):

	var item = items[index]

	if PlayerData.coins >= item["price"]:
		PlayerData.coins -= item["price"]
		PlayerData.inventory.append(item["name"])
		print("Membeli ", item["name"])
	else:
		print("Koin tidak cukup")

extends ItemList

var list: Array:
	set(value):
		list = value
		update(list) 


func update(new_list: Array) -> void:
	super.clear()
	for item in new_list:
		super.add_item(item)


func search(text: String) -> void:
	if text == '':
		update(list)
	else:
		update(list.filter(func(item): return ~item.find(text)))

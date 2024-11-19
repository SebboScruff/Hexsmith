class_name Utilities

static func get_child_nodes(node: Node) -> Array:
	var nodes : Array = []
	
	for N in node.get_children():
		if(N.get_child_count() > 0):
			nodes.append(N)
			nodes.append_array(get_child_nodes(N))
		else:
			nodes.append(N)
			
	return nodes

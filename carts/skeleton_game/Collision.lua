function CreateQuadTree(bounds)
	local quadTree = {
		bounds = bounds,
		objects = {},
		nodes = {}
	}

	return quadTree
end

function SplitNode(tree)
	local x = tree.bounds.x
	local y = tree.bounds.y
	local w = tree.bounds.w / 2
	local h = tree.bounds.h / 2

	tree.nodes[1] = CreateQuadTree({x = x + w,	y = y,		w = w,	h = h})
	tree.nodes[2] = CreateQuadTree({x = x,		y = y,		w = w,	h = h})
	tree.nodes[3] = CreateQuadTree({x = x,		y = y + h,	w = w,	h = h})
	tree.nodes[4] = CreateQuadTree({x = x + w,	y = y + h,	w = w,	h = h})
end

function InsertObject(tree, object)
	-- check child nodes to see which one the object fits in
	local index = 0
	for i = 1, #tree.nodes do
		local node = tree.nodes[i]
		if object.position.x >= node.bounds.x and object.position.x < node.bounds.x + node.bounds.w and object.position.y >= node.bounds.y and object.position.y < node.bounds.y + node.bounds.h then
			index = i
			break
		end
	end

	-- if the object fits in a child node, insert it there
	if index > 0 then
		InsertObject(tree.nodes[index], object)

	-- otherwise, insert it into the current node
	else
		add(tree.objects, object)

		-- if the current node has too many objects and no children, split it
		if #tree.objects > 4 and #tree.nodes == 0 then
			SplitNode(tree)
		
			-- redistribute objects (remove and reinsert)
			for i = #tree.objects, 1, -1 do
				local o = tree.objects[i]
				del(tree.objects, o)
				InsertObject(tree, o)
			end
		end
	end
end

local function RetrieveObjects(tree, objects, bounds)
	if #tree.nodes == 0 then
		for i = 1, #tree.objects do
			add(objects, tree.objects[i])
		end
		return
	end

	for i = 1, #tree.nodes do
		local node = tree.nodes[i]
		if bounds.x < node.bounds.x + node.bounds.w and bounds.x + bounds.w > node.bounds.x and bounds.y < node.bounds.y + node.bounds.h and bounds.y + bounds.h > node.bounds.y then
			RetrieveObjects(node, objects, bounds)
		end
	end
end

-- Initialize the quadtree with a large initial bounds
tree = CreateQuadTree({x = -6400, y = -6400, w = 12800, h = 12800})
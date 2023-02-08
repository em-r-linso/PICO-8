objects = {}
numberOfAnims = 0

function _draw()

	-- clear screen
	cls()

	-- center camera on player
	camera(player.position.x - 64, player.position.y - 64)

	-- draw bg tiles
	local playerTileX = flr(player.position.x / 8) * 8
	local playerTileY = flr(player.position.y / 8) * 8
	local radius = 9
	for x = -radius, radius do
		for y = -radius, radius do
			local hashX = flr((playerTileX / 8 + x) + 15465421)
			local hashY = flr((playerTileY / 8 + y) + 54654686)
			local tileSprite = (hashX * hashY * config.rngSeed) % (config.floorTileVariations + config.extraLikelihoodForStandardFloorTile)
			tileSprite = 255 - tileSprite
			if tileSprite < 255 - config.floorTileVariations then
				tileSprite = 255
			end
			spr(tileSprite, playerTileX + (x * 8), playerTileY + (y * 8))
		end
	end

	-- draw projectiles
	DrawProjectiles()

	-- draw sprites of every object
	for _, object in pairs(objects) do
		spr(object.sprite, object.position.x - 4, object.position.y - 4, 1, 1, object.spriteFlip) -- -4 to center the sprite
	end

	
	-- debug quadtree view
	DrawQuadTree(tree)

	-- UI on top
	camera(0, 0)
	if player.hp > 0 then
		HpBar()
	else
		GameOver()
	end
end
	
function DrawQuadTree(tree)
	-- draw the bounds of the current node
	rect(tree.bounds.x, tree.bounds.y, tree.bounds.x + tree.bounds.w, tree.bounds.y + tree.bounds.h)
	
	-- visualize the child nodes
	for i = 1, #tree.nodes do
		DrawQuadTree(tree.nodes[i])
	end
end

function SortByY()
	-- merge all objects into one table
	objects = {}
	for _, enemy in pairs(enemies) do
		add(objects, enemy)
	end
	add(objects, player)

	-- sort the objects table by y position	
	Sort(objects, function(a, b)
		return a.position.y > b.position.y
	end)
end

function AnimateSprites()
	if t() > numberOfAnims * config.animDelay then
		numberOfAnims += 1
		for _, object in pairs(objects) do
			if (numberOfAnims % config.numberOfAnimOffsets == object.animOffset) then
				local animationState = object.sprite % 5
				if animationState == 1 then
					object.sprite += 1
				elseif animationState == 2 then
					object.sprite -= 1
				elseif animationState == 3 then
					object.hurtFrames -= 1
					if object.hurtFrames <= 0 then
						object.sprite -= 1
					end
				end
			end
		end	
	end	
end

function HpBar()
	rectfill(2, 2, 125, 4 + config.hpBarHeight, 0)
	rectfill(3, 3, ((player.hp / player.maxHp) * 121) + 3, 3 + config.hpBarHeight, 8)
end

function GameOver()
	rectfill(64 - 18, 64 + 9, 64 + 18, 64 + 17, 8)
	print("you died", 49, 75, 0)
end

function DrawProjectiles()
	for _, projectile in pairs(projectiles) do
		circfill(projectile.position.x, projectile.position.y, 1, 10)
	end
end
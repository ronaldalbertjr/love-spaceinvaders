function love.load()
	print("Space Invaders is loading")

	player = {}
	player.w = 80
	player.h = 20
	player.x = love.graphics.getWidth()/2 - 50
	player.y = love.graphics.getHeight()-player.h-20
	player.speedX = 0
	player.shootTime = 0.1
	player.bullets = {}

	player.fire = function()
		bullet = {}
		bullet.w = 10
		bullet.h = 10
		bullet.x = player.x + player.w/2 - bullet.w/2
		bullet.y = player.y - bullet.h
		bullet.speedY = -10
		table.insert(player.bullets, bullet)
	end
end

function love.update(dt)
	for i,v in pairs(player.bullets) do
		v.y = v.y + v.speedY
		if v.y<=-10 then
			table.remove(player.bullets, i)
		end
	end
	if love.keyboard.isDown("left") and player.x>0 then
		player.speedX = -2
	elseif love.keyboard.isDown("right") and player.x+100<love.graphics.getWidth() then
		player.speedX = 2
	else
		player.speedX = 0
	end

	if love.keyboard.isDown("space") and player.shootTime>0.1 then
		player.fire()
		player.shootTime = 0
	end

	player.shootTime = player.shootTime + dt;
	player.x = player.x + player.speedX
end

function love.draw()
	love.graphics.setColor(0, 0, 255, 255)
	love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
	love.graphics.setColor(255,255,255,255)
	for i,v in pairs(player.bullets) do
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
	end
end
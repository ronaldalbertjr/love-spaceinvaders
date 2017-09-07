love.graphics.setBackgroundColor(128,128,128,255)
love.graphics.setDefaultFilter('nearest', 'nearest')
player = {}
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage("img/enemy.png")
player.image = love.graphics.newImage("img/player.png")
player.fire_sound = love.audio.newSource("audio/player_shot.mp3", "static")

function love.load()
	print("Space Invaders is loading")
	game_over = false
	game_win = false
	player.width = player.image:getWidth() * 3
	player.height = player.image:getHeight() * 3
	player.x = love.graphics.getWidth()/2 - 50
	player.y = love.graphics.getHeight()-player.height-20
	player.speedX = 0
	player.shootTime = 0.1
	player.bullets = {}

	player.fire = function()
		love.audio.stop(player.fire_sound)
		love.audio.play(player.fire_sound)
		bullet = {}
		bullet.w = 10
		bullet.h = 10
		bullet.x = player.x + player.width/2 - bullet.w/2
		bullet.y = player.y - bullet.h
		bullet.speedY = -10
		table.insert(player.bullets, bullet)
	end
	
	for i = 0, 2 do
		j = 15 
		while j + enemies_controller.image:getWidth() * 2 < love.graphics.getWidth() do
			enemies_controller:spawnEnemy(j, i * (enemies_controller.image:getHeight() + 20))
			j = j + 75
		end
	end
end

function player:update(dt)
	--check player bullets
	for i,v in pairs(player.bullets) do
		v.y = v.y + v.speedY
		if v.y<=-10 then
			table.remove(player.bullets, i)
		end
	end

	-- player shoot
	if love.keyboard.isDown("space") and self.shootTime>0.1 then
		self.fire()
		self.shootTime = 0
	end

	-- player movement
	if love.keyboard.isDown("left") and self.x>0 then
		self.speedX = -2
	elseif love.keyboard.isDown("right") and self.x+100<love.graphics.getWidth() then
		self.speedX = 2
	else
		self.speedX = 0
	end

	player.shootTime = player.shootTime + dt;
	player.x = player.x + player.speedX
end

function enemies_controller:update(dt)
	--update to every enemy
	for _,e in pairs(enemies_controller.enemies) do
		-- enemy movement
		e.y = e.y + 0.5

		--check enemy collision with bottom of the screen
		if e.y + e.height >= love.graphics.getHeight() then
			game_over = true
		end

		--check enemy collision with player
		e.checkCollision(e.x, e.y)
	end

	--check if player has won
	if #enemies_controller.enemies == 0 then
		game_win = true
	end
end

function enemies_controller:spawnEnemy(x, y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = enemies_controller.image:getWidth() * 2
	enemy.height = enemies_controller.image:getHeight() * 2
	enemy.bullets = {}
	enemy.shootTime = 20
	enemy.speed = 10
	enemy.checkCollision = function (x, y)
		if (x + enemy.width >= player.x) and (x <= player.x + player.width) and (y + enemy.height - 50 >= player.y) and (y + 50 <= player.y + player.height) then
			game_over = true
		end  
	end
	table.insert(self.enemies, enemy)
end

function enemy:fire()
	bullet = {}
	bullet.x = self.x - 35
	bullet.y = self.y
	table.insert(self.bullets, bullet)
end

function checkCollisions(enemies, bullets)
	for i, e in ipairs(enemies) do
		for j, b in pairs(bullets) do
			if b.y <= e.y + e.height and b.x > e.x  and b.x < e.x + e.width then
				table.remove(enemies_controller.enemies, i)
				table.remove(player.bullets, j)
			end
		end  
	end
end

function love.update(dt)
	if (not game_over) then
		player:update(dt)
		enemies_controller:update(dt)
		checkCollisions(enemies_controller.enemies, player.bullets);
	end
end

function love.draw()
	if (not game_over)then
		love.graphics.draw(player.image, player.x, player.y, 0, 3)
		
		--draw enemies
		for _,e in pairs(enemies_controller.enemies) do
			love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 2)
		end

		-- draw bullets
		love.graphics.setColor(255,255,255,255)
		for i,v in pairs(player.bullets) do
			love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		end

		if game_win then
			love.graphics.print("YOU WON!!!", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 5)
		end
	else
		love.graphics.print("GAME OVER!!", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 5)
	end
end
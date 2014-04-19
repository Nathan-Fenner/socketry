"usestrict";

var viewx = 0;
var viewy = 0;


var timeout = 0;

var zIgnore = false;

var piloting = null;

function draw() {
	if (keys.C && timeout <= 0) {
		timeout = 25;
		var sx = lvx;
		var sy = lvy;
		if (sy != 0 && vx == 0) {
			sx = 0;
		}
		var s = shot(px,py,sx * 0.199999,sy * 0.199999);
		shots.push(s);
		socket.send("!shot" + signToChar(sx) + signToChar(sy) + username);
	}
	timeout--;
	playerPhysics();
	if (keys.Z && !zIgnore) {
		if (piloting) {
			piloting = null;
		} else {
			var into = Vehicle.tryLoad();
			piloting = into;
		}
		zIgnore = true;
	} 
	if (!keys.Z) {
		zIgnore = false;
	}
	if (piloting) {
		px = piloting.x;
		py = piloting.y;
		vx = 0;
		vy = 0;
		piloting.control();
	}
	
	ctx.clearRect(0,0,600,600);
	ctx.fillStyle = "#1452B7";
	ctx.fillRect(0,0,600,600);
	ctx.save();
	viewx = viewx * 0.9 + px * 0.1;
	viewy = viewy * 0.9 + py * 0.1;
	ctx.translate(Math.floor(300 - viewx*25),Math.floor(300 - viewy*25));
	ctx.fillStyle = "#B88751";
	for (var x = 0; x < 150; x++) {
		for (var y = 0; y < 50; y++) {
			if (world[x][y]) {
				ctx.fillRect(x*25,y*25,25,25);
				/*if (rand(x,y) < 0.5) {
					drawImage(ctx,stoneTileA,x*25-2,y*25-2);
				} else {
					drawImage(ctx,stoneTileB,x*25-2,y*25-2);
				}*/
			}
		}
	}	
	ctx.fillStyle = "#2C8C2C";
	for (var x = 0; x < 150; x++) {
		for (var y = 0; y < 50; y++) {
			if (world[x][y]) {
				if (y == 0 || !world[x][y-1]) {
					/*
					if (rand(x,y) < 0.25 || rand(x,y) > 0.75) {
						drawImage(ctx,grassTileA,x*25-2,y*25-4);
					} else {
						drawImage(ctx,grassTileB,x*25-2,y*25-4);
					}*/
					
					ctx.fillRect(x*25-2,y*25-2,29,8);
				}
			}
		}
	}
	ctx.fillStyle = "#FF3300";
	ctx.fillRect(Math.floor(px*25 - 7), Math.floor(py*25 - 12), 14, 24)
	for (player in lookUp) {
		if (player != username) {
			var pos = lookUp[player];
			pos = pos.split(" ");
			var x = pos[0] * 1;
			var y = pos[1] * 1;
			ctx.fillRect(Math.floor(x*25 - 7), Math.floor(y*25 - 12), 14, 24);
		}
	}

	for (var i = 0; i < vehicles.length; i++) {
		vehicles[i].disp(ctx);
		vehicles[i].update();
	}

	ctx.fillStyle = "#3AF";
	for (var i = 0; i < crystal.length; i++) {
		var c = crystal[i];
		if (c.x <= viewx + 15 && c.x >= viewx - 15 && c.y <= viewy + 15 && c.y >= viewy - 15) {
			for (var j = 0; j < rand(c.x + 0.5,c.y) * 2 + 4; j++) {
				var cx = rand(c.x,c.y + 0.1 * j);
				var cy = rand(c.x + 0.3,c.y + 0.1 * j);
				cx = Math.floor(cx * 5) * 5;
				cy = Math.floor(cy * 5) * 5;
				ctx.fillStyle = "#3" + ("9AB").charAt(rand(j + c.x,c.y - j)*3|0) + ("DEF").charAt(rand(j + c.x,c.y + 1 + j)*3|0);
				ctx.fillRect(c.x*25 + cx ,c.y*25 + cy,5,5);
			}
		}
	}

	moveShots();
	drawShots();
	drawParticles();
	ctx.restore();
	ctx.fillStyle = "#000";
	ctx.font = "36px Arial"
	ctx.fillText(Math.floor(pingTime + 0.5),50,50);
}

function loop() {
	draw();
}
setInterval(loop,10);
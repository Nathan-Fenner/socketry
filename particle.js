function particleDraw(p) {
	switch (p.type) {
	
	case "boom":
		ctx.fillStyle = "#FFF";
		var nonzero = 0;
		for (var i = 0; i < p.ps.length; i++) {
			p.ps[i].r += p.ps[i].g;
			if (p.ps[i].r >= p.ps[i].m) {
				p.ps[i].r = p.ps[i].m;
				p.ps[i].g *= -1;
			}
			if (p.ps[i].r <= 0) {
				continue;
			}
			nonzero++;
			ctx.beginPath();
			ctx.arc(p.ps[i].x*25,p.ps[i].y*25,p.ps[i].r*25,0,6.29);
			ctx.fill();
		}
		if (nonzero == 0) {
			p.dead = true;
		}
		break;
	case "pew":
		var nonzero = 0;
		for (var i = 0; i < p.ps.length; i++) {
			p.ps[i].x += p.ps[i].vx;
			p.ps[i].y += p.ps[i].vy;
			p.ps[i].r += p.ps[i].g;
			if (p.ps[i].r >= p.ps[i].m) {
				p.ps[i].r = p.ps[i].m;
				p.ps[i].g *= -1;
			}
			if (p.ps[i].r <= 0) {
				continue;
			}
			nonzero++;
			ctx.fillStyle = "#FFA";
			ctx.beginPath();
			var r = Math.sqrt(p.ps[i].r) / 2;
			ctx.arc(p.ps[i].x*25,p.ps[i].y*25,r*25,0,6.29);
			ctx.fill();
		}
		if (nonzero == 0) {
			p.dead = true;
		}
	}
}
function particlePew(x,y) {
	var p = {x:x,y:y,t:0,type:"pew",ps:[]};
	for (var i = 0; i < 15; i++) {
		var a = Math.random() * Math.PI * 2;
		var r = Math.random() / 2;
		p.ps[i] = {x: x + r * Math.cos(a), y: y + r * Math.sin(a)};
		p.ps[i].vx = Math.cos(a) / 50;
		p.ps[i].vy = Math.sin(a) / 50;
		p.ps[i].g = Math.random() / 20 * 1.5 + 0.01 * 1.5;
		p.ps[i].m = Math.random() / 3 + 0.1;
		p.ps[i].r = 0;
		p.ps[i].a = Math.random() * Math.PI;
	}
	particles.push(p);
}
function particleBoom(x,y) {
	var p = {x:x,y:y,t:0,type:"boom",ps:[]};
	for (var i = 0; i < 15; i++) {
		var a = Math.random() * Math.PI * 2;
		var r = Math.random();
		p.ps[i] = {x: x + r * Math.cos(a), y: y + r * Math.sin(a)};
		p.ps[i].g = Math.random() / 20 + 0.01;
		p.ps[i].m = Math.random() / 2;
		p.ps[i].r = 0;
	}
	particles.push(p);
}

var particles = [];
function drawParticles() {
	for (var i = 0; i < particles.length; i++) {
		if (particles[i].dead) {
			particles.splice(i,1);
			i--;
			continue;
		}
		particleDraw(particles[i]);
	}
}

function physics(px,py,pw,ph,vx,vy) {
	// move player in the x direction, then y direction
	// stop them if they collide with anything
	// (bouncing may be more fun)
	vy += 0.005; // gravity
	// locate lines which can be collided with
	var minDistance = Math.abs(vx);
	var colDir = "";

	var col = false;
	for (var i = 0; i < lines.length; i++) {
		var line = lines[i];
		if (line.vertical && py+ph/2 > line.ay+1/200 && py-ph/2 < line.by -1/200) {
			var dx = line.ax - px;
			if (sign(dx) == sign(vx) && Math.abs(dx)-pw/2 < minDistance) {
				minDistance = Math.abs(dx)-pw/2;
				col = true;
			}
		}
	}
	if (col) {
		colDir += "X";
	}
	px += minDistance * sign(vx);

	var minDistance = Math.abs(vy);
	var col = false;
	for (var i = 0; i < lines.length; i++) {
		var line = lines[i];
		if (!line.vertical && px+pw/2 > line.ax+1/200 && px-pw/2 < line.bx-1/200) {
			line.hit = true;
			var dy = line.ay - py;
			if (sign(dy) == sign(vy) && Math.abs(dy)-ph/2 < minDistance) {
				minDistance = Math.abs(dy)-ph/2;
				col = true;
			}
		}
	}
	py += minDistance * sign(vy);
	if (col) {
		colDir += "Y";
	}

	return {x:px,y:py,vx:vx,vy:vy,col:colDir};
}
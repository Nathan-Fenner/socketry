"use strict";

var vehicles = [];
function Vehicle() {
	this.w = 2;
	this.h = 1;
	this.x = 1;
	this.y = 0;
	this.vx = 0;
	this.vy = 0;
	this.disp = function(c) {
		c.fillStyle = "#DDDD22";
		c.fillRect(  (this.x-this.w/2)*25,this.y*25,this.w*25,this.h/2*25);
	};

	this.update = function() {
		this.vy += gravity;
		var go = physics(this.x,this.y,this.w,this.h,this.vx,this.vy);
		this.x = go.x;
		this.y = go.y;
		if (go.col === "XY" || go.col === "Y") {
			this.vy = 0;
		}
		if (go.col === "X" || go.col === "XY") {
			this.vx = 0;
		}
	};
	vehicles.push(this);
}
Vehicle.tryLoad = function() {
	for (var i = 0; i < vehicles.length; i++) {
		if ( Math.abs(vehicles[i].x - px) < 1.2 && Math.abs(vehicles[i].y - py) < 0.4) {
			return vehicles[i];
		}
	}
};

function VehiclePlane() {
	var v = new Vehicle();
	v.control = function() {
		v.vx *= 0.99;
		if (keys.RIGHT) {
			if (v.vx < .1) {
				v.vx += 0.00315;
			}
		}
		if (keys.LEFT) {
			if (v.vx > -.1) {
				v.vx -= 0.00315;
			}
		}
		v.vy -= Math.abs(v.vx) * 0.07;
		v.vy = Math.max( Math.abs(v.vx) / -2 , v.vy   );
	}
	return v;
}

setTimeout(function() {
var car = new VehiclePlane();
car.x = px;
car.y = py;
},1000);
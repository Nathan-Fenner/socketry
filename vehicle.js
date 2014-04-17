function Vehicle() {
	this.w = 32;
	this.h = 16;
	this.x = 100;
	this.y = 0;
	this.disp = function(c) {
		c.fillStyle = "#AAAA33";
		c.fillRect(this.x-this.w/2,this.y-this.h/2,this.w,this.h);
	};

	this.update = function() {

	};
	vehicles.add(this);
}
var vehicles = [];
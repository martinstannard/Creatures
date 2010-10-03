(function() {
  $(function() {
    var Canvas, Colour, Turtle, canvas, circle, modded, randint, start, stop, timer, turtle;
    Canvas = function(id) {
      this.context = $("#" + id)[0].getContext('2d');
      return this;
    };
    Canvas.prototype.dot = function(x, y, w, h) {
      return this.context.fillRect(x, y, w, h);
    };
    Canvas.prototype.colour = function(colour) {
      return (this.context.fillStyle = colour);
    };
    Colour = function() {
      this.r = randint(255);
      this.g = randint(255);
      this.b = randint(255);
      return this;
    };
    Colour.prototype.to_rgb = function() {
      return "rgb(" + (this.r) + "," + (this.g) + "," + (this.b) + ")";
    };
    Colour.prototype.to_hex = function() {
      return "#" + this.num_to_hex(this.r) + this.num_to_hex(this.g) + this.num_to_hex(this.b);
    };
    Colour.prototype.num_to_hex = function(n) {
      if (n === null) {
        return "00";
      }
      n = parseInt(n);
      if (n === 0 || isNaN(n)) {
        return "00";
      }
      n = Math.max(0, n);
      n = Math.min(n, 255);
      n = Math.round(n);
      return "0123456789ABCDEF".charAt((n - n % 16) / 16) + "0123456789ABCDEF".charAt(n % 16);
    };
    Turtle = function(_a) {
      this.canvas = _a;
      this.x = 200.0;
      this.y = 200.0;
      this.heading = 0;
      this.colour = new Colour();
      return this;
    };
    Turtle.prototype.move = function(distance) {
      this.canvas.colour(this.colour.to_rgb);
      this.canvas.context.moveTo(this.x, this.y);
      this.x += Math.sin(this.heading) * distance;
      this.y += Math.cos(this.heading) * distance;
      this.canvas.context.lineTo(this.x, this.y);
      return this.canvas.dot(this.x, this.y, 1, 1);
    };
    Turtle.prototype.turn = function(angle) {
      return this.heading += angle;
    };
    randint = function(ceil) {
      return Math.floor(Math.random() * ceil);
    };
    modded = function(n, mod) {
      return (n + mod) % mod;
    };
    circle = function(turtle) {
      turtle.turn(randint(10) / 100.0);
      return turtle.move(5.0);
    };
    start = function() {
      return setInterval(function() {
        return circle(turtle);
      }, 1);
    };
    stop = function() {
      return clearInterval(timer);
    };
    canvas = new Canvas('turtles');
    turtle = new Turtle(canvas);
    timer = null;
    return start();
  });
})();

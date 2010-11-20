(function() {
  $(function() {
    var Canvas, Colour, Food, Population, Reporter, Turtle, canvas, food, images, make_food, make_images, modded, population, rand_colour, randint, reporter, start, stop, ticks, timer;
    Canvas = function(id) {
      this.context = $("#" + id)[0].getContext('2d');
      return this;
    };
    Canvas.prototype.dot = function(x, y, w, h) {
      return this.context.fillRect(x, y, w, h);
    };
    Canvas.prototype.fill_colour = function(col) {
      return (this.context.fillStyle = col);
    };
    Canvas.prototype.stroke_colour = function(col) {
      return (this.context.strokeStyle = col);
    };
    Canvas.prototype.clear = function() {
      return this.context.clearRect(0, 0, this.context.canvas.width, this.context.canvas.height);
    };
    Canvas.prototype.h = function() {
      return this.context.canvas.height;
    };
    Canvas.prototype.w = function() {
      return this.context.canvas.width;
    };
    Canvas.prototype.write = function(text, x, y, colour) {
      this.context.strokeStyle = colour;
      return this.context.strokeText(text, x, y);
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
    Colour.prototype.health = function(health) {
      this.r = (512 - Math.min(health, 512)) / 2;
      this.g = Math.min(health, 512) / 2;
      this.b = 0;
      return this.to_rgb();
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
    Turtle = function(canvas, id) {
      this.age = 0;
      this.canvas = canvas;
      this.id = id;
      this.image = images[randint(2)];
      this.health = 500;
      this.x = randint(canvas.w());
      this.y = randint(canvas.h());
      this.heading = Math.random() * 1000.0;
      this.colour = new Colour();
      this.distance_to_food = 1000.0;
      this.closer = false;
      this.seek_turn = Math.random() * 3.14159;
      this.rand_turn = Math.random() * 2;
      this.speed = randint(40) / 10.0;
      return this;
    };
    Turtle.prototype.move = function(distance) {
      var c;
      this.x += Math.sin(this.heading) * distance;
      this.y += Math.cos(this.heading) * distance;
      this.canvas.context.save();
      this.canvas.context.translate(this.x + 16, this.y + 16);
      this.canvas.context.rotate(-this.heading);
      this.canvas.context.translate(-16, -16);
      this.canvas.context.drawImage(this.image, 0, 0);
      this.canvas.context.restore();
      if (this.x < 0) {
        this.x += this.canvas.w();
      }
      if (this.x > this.canvas.w()) {
        this.x -= this.canvas.w();
      }
      if (this.y < 0) {
        this.y += this.canvas.h();
      }
      if (this.y > this.canvas.h()) {
        this.y -= this.canvas.h();
      }
      c = new Colour();
      this.canvas.write(this.health, this.x, this.y, c.health(this.health));
      return this.canvas.write(this.id, this.x + 14, this.y + 18, '#ffff00');
    };
    Turtle.prototype.turn = function(angle) {
      return this.heading += angle;
    };
    Turtle.prototype.tick = function() {
      this.age += 1;
      if (!this.closer) {
        this.turn(this.seek_turn);
      }
      this.turn((Math.random() * this.rand_turn) - (this.rand_turn / 2.0));
      this.move(this.speed);
      return (this.health = this.health - 1);
    };
    Turtle.prototype.dead = function() {
      return this.health < 1;
    };
    Turtle.prototype.smell = function(food) {
      var distance_now;
      distance_now = food.distance_from(this.x + 16, this.y + 16);
      this.closer = distance_now < this.distance_to_food;
      this.distance_to_food = distance_now;
      if (this.distance_to_food < 10) {
        this.health = this.health + food.health;
        return true;
      }
      return false;
    };
    Food = function() {
      this.health = parseInt(Math.random() * 500) + 200;
      this.colour = "rgb(0, 255, 0)";
      this.x = Math.random() * (canvas.w() - 50) + 25;
      this.y = Math.random() * (canvas.h() - 50) + 25;
      return this;
    };
    Food.prototype.draw = function(canvas) {
      canvas.fill_colour(this.colour);
      return canvas.dot(this.x, this.y, 4, 4);
    };
    Food.prototype.tick = function() {
      return this.health += 3;
    };
    Food.prototype.move = function() {
      this.x = Math.random() * 640;
      return (this.y = Math.random() * 480);
    };
    Food.prototype.distance_from = function(x, y) {
      var distance_now;
      return (distance_now = Math.sqrt(((this.x - x) * (this.x - x)) + ((this.y - y) * (this.y - y))));
    };
    Reporter = function() {};
    Reporter.prototype.stats = function(turtles) {
      var _len, _ref, c, i, t;
      canvas.write('#', 540, 12, '#00ddff');
      canvas.write('Health', 560, 12, '#00ff00');
      canvas.write('Age', 600, 12, '#ffff00');
      turtles.sort(function(a, b) {
        return b[1].health - a[1].health;
      });
      _ref = turtles;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        t = _ref[i];
        c = new Colour();
        canvas.write(t[0], 540, i * 12 + 25, '#00ddff');
        canvas.write(t[1].health, 560, i * 12 + 25, c.health(t[1].health));
        canvas.write(t[1].age, 600, i * 12 + 25, '#ffff00');
      }
      return canvas.write(ticks, 540, 460, '#00ddff');
    };
    Population = function(turtle_count, canvas) {
      var num;
      this.turtles = [];
      for (num = 1; (1 <= turtle_count ? num <= turtle_count : num >= turtle_count); (1 <= turtle_count ? num += 1 : num -= 1)) {
        this.turtles.push(new Turtle(canvas, num));
      }
      return this;
    };
    Population.prototype.tick = function(food) {
      var _len, _ref, dead_turtles, i, turtle;
      dead_turtles = [];
      _ref = this.turtles;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        turtle = _ref[i];
        if (turtle.smell(food)) {
          food = new Food();
        }
        turtle.tick();
        dead_turtles.push(i);
        if (turtle.dead()) {
          this.turtles[i] = new Turtle(canvas, i);
        }
      }
      return food;
    };
    Population.prototype.stats = function() {
      var _len, _ref, healths, i, turtle;
      healths = [];
      _ref = this.turtles;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        turtle = _ref[i];
        healths.push([i, turtle]);
      }
      return healths;
    };
    make_food = function() {
      return new Food();
    };
    make_images = function(images) {
      var _i, _result, i;
      _result = [];
      for (_i = 0; _i <= 1; _i++) {
        (function() {
          var i = _i;
          return _result.push((function() {
            images[i] = new Image();
            images[i].onload = function() {};
            return (images[i].src = ("images/bug" + (i) + ".png"));
          })());
        })();
      }
      return _result;
    };
    randint = function(ceil) {
      return Math.floor(Math.random() * ceil);
    };
    rand_colour = function() {
      return "rgb(" + (randint(255)) + "," + (randint(255)) + "," + (randint(255)) + ")";
    };
    modded = function(n, mod) {
      return (n + mod) % mod;
    };
    $('#faster').click(function() {
      if (ticks > 5) {
        ticks -= 5;
      }
      stop();
      return start(food);
    });
    $('#slower').click(function() {
      ticks += 5;
      stop();
      return start(food);
    });
    ticks = 25;
    timer = null;
    images = [];
    make_images(images);
    canvas = new Canvas('turtles');
    reporter = new Reporter();
    population = new Population(10, canvas);
    start = function(food) {
      return (timer = setInterval(function() {
        canvas.clear();
        food.draw(canvas);
        food = population.tick(food);
        food.tick();
        return reporter.stats(population.stats());
      }, ticks));
    };
    stop = function() {
      return clearInterval(timer);
    };
    food = new Food();
    return start(food);
  });
}).call(this);

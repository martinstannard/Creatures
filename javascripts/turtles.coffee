$ ->
  class Canvas

    constructor: (id) ->
      @context = $("#" + id)[0].getContext '2d'

    dot: (x, y, w, h) ->
      @context.fillRect x, y, w, h

    fill_colour: (col) ->
      @context.fillStyle = col

    stroke_colour: (col) ->
      @context.strokeStyle = col

    clear: ->
      @context.clearRect 0, 0, @context.canvas.width, @context.canvas.height

    h: ->
      @context.canvas.height

    w: ->
      @context.canvas.width

    write: (text, x, y, colour) ->
      @context.strokeStyle = colour
      @context.strokeText(text, x, y)
      
  class Colour

    constructor: ->
      @r = randint 255
      @g = randint 255
      @b = randint 255

    to_rgb: ->
      "rgb(#{@r},#{@g},#{@b})"

    to_hex: ->
      "#" + @num_to_hex(@r) + @num_to_hex(@g) + @num_to_hex(@b)

    health: (health) ->
      @r = (512 - Math.min(health, 512)) / 2
      @g = Math.min(health, 512) / 2
      @b = 0
      @to_rgb()

    num_to_hex: (n) -> 
      if (n == null) 
        return "00"
      n = parseInt n
      if ( n == 0 || isNaN (n))
        return "00"
      n = Math.max 0, n
      n = Math.min n, 255
      n = Math.round n
      "0123456789ABCDEF".charAt((n-n%16)/16) + "0123456789ABCDEF".charAt(n%16)
      

  class Turtle

    constructor: (canvas, id) ->
      @canvas = canvas
      @id = id
      @image = images[randint(2)]
      @health = 500
      @x = randint(canvas.w())
      @y = randint(canvas.h())
      @heading = Math.random() * 1000.0
      @colour = new Colour
      @distance_to_food = 1000.0
      @closer = false
      @seek_turn = (randint(200) - 100) / 100.0
      @rand_turn = Math.random() * 2
      @speed = randint(40) / 10.0

    move: (distance) ->
      @x += Math.sin(@heading) * distance
      @y += Math.cos(@heading) * distance
      @canvas.context.save()
      @canvas.context.translate(@x+16, @y+16)
      @canvas.context.rotate(-@heading)
      @canvas.context.translate(-16, -16)
      @canvas.context.drawImage(@image, 0, 0)
      @canvas.context.restore()
      @x += @canvas.w() if @x < 0
      @x -= @canvas.w() if @x > @canvas.w()
      @y += @canvas.h() if @y < 0
      @y -= @canvas.h() if @y > @canvas.h()
      c = new Colour
      @canvas.write(@health, @x, @y, c.health(@health))
      @canvas.write(@id, @x+14, @y+18, '#ffff00')

    turn: (angle) ->
      @heading += angle

    tick: ->
      @turn @seek_turn if not @closer
      @turn (Math.random() * @rand_turn) - (@rand_turn / 2.0)
      @move @speed
      @health = @health - 1

    dead: -> 
      @health < 1

    smell: (food) ->
      distance_now = food.distance_from(@x + 16, @y + 16)
      @closer = distance_now < @distance_to_food
      @distance_to_food = distance_now
      if @distance_to_food < 10
        @health = @health + food.health
        return true
      false

  class Food

    constructor: ->
      @health = parseInt(Math.random() * 500 + 500)
      @colour = "rgb(0, 255, 0)"
      @x = Math.random() * (canvas.w() - 50) + 25
      @y = Math.random() * (canvas.h() - 50) + 25

    draw: (canvas) ->
      canvas.fill_colour @colour
      canvas.dot @x, @y, 4, 4 

    move: ->
      @x = Math.random() * 640
      @y = Math.random() * 480

    distance_from: (x, y) ->
      distance_now = Math.sqrt(((@x - x) * (@x - x)) + ((@y - y) * (@y - y))) 
      
  class Reporter

    health: (healths) ->
      healths.sort( (a, b) ->
        b[1] - a[1] )
      for h, i in healths
        c = new Colour
        canvas.write(h[0], 570, i * 12 + 20, '#00ddff')
        canvas.write(h[1], 580, i * 12 + 20, c.health(h[1]))
      
  class Population

    constructor: (turtle_count, canvas) ->
      @turtles = []
      for num in [1..turtle_count] 
        @turtles.push(new Turtle(canvas, num))
  
    tick: (food) ->
      dead_turtles = []
      for turtle, i in @turtles
        if turtle.smell(food) 
          food = new Food()
        turtle.tick()
        dead_turtles.push(i) 
        @turtles[i] = new Turtle(canvas, i) if turtle.dead()
      return food

    healths: ->
      healths = []
      for turtle, i in @turtles
        healths.push [i, turtle.health]
      healths

  make_food = -> 
    new Food

  make_images = (images) ->
    for i in [0..1]
      images[i] = new Image
      images[i].onload = ->
      images[i].src = "images/bug#{i}.png"

  randint = (ceil) ->
    Math.floor(Math.random()*ceil)

  rand_colour = ->
    "rgb(#{randint(255)},#{randint(255)},#{randint(255)})"

  modded = (n, mod) ->
    (n + mod) % mod


  timer = null
  images = []
  make_images(images)
  canvas = new Canvas 'turtles'
  reporter = new Reporter
  population = new Population(10, canvas)

  start = (food) ->
    timer = setInterval( ->
      canvas.clear()
      food.draw(canvas)
      food = population.tick(food)
      reporter.health population.healths()
    , 20)

  stop = ->
    clearInterval timer
  start new Food



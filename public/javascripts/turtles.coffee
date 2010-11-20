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
      @r = parseInt((512 - Math.min(health, 512)) / 2)
      @g = parseInt(Math.min(health, 512) / 2)
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
      @age = 0
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
      @seek_turn = Math.random() * 3.14159
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
      @age += 1
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
      @health = parseInt(Math.random() * 500) + 200
      @colour = "rgb(0, 255, 0)"
      @x = Math.random() * (canvas.w() - 50) + 25
      @y = Math.random() * (canvas.h() - 50) + 25

    draw: (canvas) ->
      canvas.fill_colour @colour
      canvas.dot @x, @y, 4, 4 

    tick: ->
      @health += 3

    move: ->
      @x = Math.random() * 640
      @y = Math.random() * 480

    distance_from: (x, y) ->
      distance_now = Math.sqrt(((@x - x) * (@x - x)) + ((@y - y) * (@y - y))) 
      
  class Reporter

    stats: (turtles) ->
      canvas.write('#', 540, 12, '#00ddff')
      canvas.write('Health', 560, 12, '#00ff00')
      canvas.write('Age', 600, 12, '#ffff00')
      turtles.sort( (a, b) ->
        b[1].health - a[1].health )
      for t, i in turtles
        c = new Colour
        canvas.write(t[0], 540, i * 12 + 25, '#00ddff')
        canvas.write(t[1].health, 560, i * 12 + 25, c.health(t[1].health))
        canvas.write(t[1].age, 600, i * 12 + 25, '#ffff00')
      
      canvas.write("Time: " + ticks, 540, 460, '#00ddff')
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

    stats: ->
      healths = []
      for turtle, i in @turtles
        healths.push [i, turtle]
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

  $('#faster').click( ->
    ticks -= 5 if ticks > 5
    stop()
    start(food)
  )
  
  $('#slower').click( ->
    ticks += 5
    stop()
    start(food)
  )

  ticks = 25
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
      food.tick()
      reporter.stats population.stats()
    , ticks)

  stop = ->
    clearInterval timer

  food = new Food
  start food



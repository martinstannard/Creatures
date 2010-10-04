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
      
  class Colour

    constructor: ->
     @r = randint 255
     @g = randint 255
     @b = randint 255

    to_rgb: ->
      "rgb(#{@r},#{@g},#{@b})"

    to_hex: ->
      "#" + @num_to_hex(@r) + @num_to_hex(@g) + @num_to_hex(@b)

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

    constructor: (@canvas, @image) ->
      @x = @canvas.w()/2.0
      @y = @canvas.h()/2.0
      @heading = Math.random() * 1000.0
      @colour = new Colour
      @distance_to_food = 1000.0
      @closer = false

    move: (distance) ->
      @x += Math.sin(@heading) * distance
      @y += Math.cos(@heading) * distance
      @canvas.context.save()
      @canvas.context.translate(@x+8, @y+8)
      @canvas.context.rotate(-@heading)
      @canvas.context.translate(-8, -8)
      @canvas.context.drawImage(@image, 0, 0)
      @canvas.context.restore()
      @x += @canvas.w() if @x < 0
      @x -= @canvas.w() if @x > @canvas.w()
      @y += @canvas.h() if @y < 0
      @y -= @canvas.h() if @y > @canvas.h()

    turn: (angle) ->
      @heading += angle

    tick: ->
      @turn 0.6 if not @closer
      @turn((randint(10) - 5) / 50.0)
      @move 2.0 

    smell: (food) ->
      distance_now = Math.sqrt(((@x - food.x) * (@x - food.x)) + ((@y - food.y) * (@y - food.y))) 
      @closer = distance_now < @distance_to_food
      @distance_to_food = distance_now
      food = new Food if @distance_to_food < 5

  class Food

    constructor: ->
      @colour = "rgb(0, 255, 0)"
      @x = Math.random() * 640
      @y = Math.random() * 480

    draw: (canvas) ->
      canvas.fill_colour @colour
      canvas.dot @x, @y, 4, 4 

    move: ->
      @x = Math.random() * 640
      @y = Math.random() * 480
      
  randint = (ceil) ->
    Math.floor(Math.random()*ceil)

  rand_colour = ->
    "rgb(#{randint(255)},#{randint(255)},#{randint(255)})"

  modded = (n, mod) ->
    (n + mod) % mod

  start = ->
    timer = setInterval(
    ->
      canvas.clear()
      food.draw(canvas)
      turtle.smell(food) for turtle in turtles
      turtle.tick() for turtle in turtles
      if Math.random() < 0.01 then food.move()
    , 50)

  stop = ->
    clearInterval timer

  img = new Image
  img.onload = ->
    console.log 'image loaded'

  img.src = 'images/turtle.png'
  canvas = new Canvas 'turtles'
  #canvas.fill_colour "rgb(0, 0, 0)"
  #canvas.context.global_alpha = 0.5
  turtles = []
  for num in [1..10] 
    turtles.push new Turtle canvas, img
  
  food = new Food

  timer = null
  start()



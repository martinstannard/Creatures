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
      @heading = (Math.random(1000)/1000.0) * 6.283
      @colour = new Colour

    move: (distance) ->
      @canvas.fill_colour(@colour.to_rgb())
      #@canvas.stroke_colour rand_colour()
      #@canvas.context.moveTo @x, @y 
      @x += Math.sin(@heading) * distance
      @y += Math.cos(@heading) * distance
      #@canvas.context.lineTo @x, @y 
      #@canvas.context.stroke()
      #@canvas.dot(@x, @y, 6, 6)
      @canvas.context.save()
      @canvas.context.translate(-16, -16)
      @canvas.context.rotate(@heading)
      #@canvas.context.translate(@x, @y)
      @canvas.context.drawImage(@image, @x, @y)
      @canvas.context.restore()
      @x += @canvas.w() if @x < 0
      @x -= @canvas.w() if @x > @canvas.w()
      @y += @canvas.h() if @y < 0
      @y -= @canvas.h() if @y > @canvas.h()

    turn: (angle) ->
      @heading += angle

    tick: ->
      @turn((randint(50) - 25.0) / 100.0)
      @move 2.0 

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
      turtle.tick() for turtle in turtles
    , 5)

  stop = ->
    clearInterval timer

  img = new Image
  img.onload = ->
    console.log 'image loaded'

  img.src = 'images/turtle.png'
  canvas = new Canvas 'turtles'
  #canvas.fill_colour "rgb(0, 0, 0)"
  turtles = []
  for num in [1..1] 
    turtles.push new Turtle canvas, img
  timer = null
  start()



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
      @context.fillRect 0, 0, @context.canvas.width, @context.canvas.height

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

    constructor: (@canvas) ->
      @x = 200.0
      @y = 200.0
      @heading = 0
      @colour = new Colour

    move: (distance) ->
      @canvas.stroke_colour @colour.to_rgb()
      @canvas.context.moveTo @x, @y 
      @x += Math.sin(@heading) * distance
      @y += Math.cos(@heading) * distance
      @canvas.context.lineTo @x, @y 
      @canvas.context.stroke()


    turn: (angle) ->
      @heading += angle

  randint = (ceil) ->
    Math.floor(Math.random()*ceil)

  modded = (n, mod) ->
    (n + mod) % mod


  circle = (turtle) ->
    turtle.turn randint(10)/100.0
    turtle.move 5.0 

  start = ->
    setInterval(
    ->
      circle turtle
    , 1)

  stop = ->
    clearInterval timer

  canvas = new Canvas 'turtles'
  canvas.fill_colour "rgb(0, 0, 0)"
  canvas.clear()
  turtle = new Turtle canvas
  timer = null
  start()


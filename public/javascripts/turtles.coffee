
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
      
  class Food

    constructor: ->
      @health = parse_input 'food_start', 300
      @colour = "rgb(0, 255, 0)"
      @x = Math.random() * (canvas.w() - 50) + 25
      @y = Math.random() * (canvas.h() - 50) + 25

    draw: (canvas) ->
      canvas.fill_colour @colour
      canvas.dot @x, @y, 4, 4 

    tick: ->
      @health += parse_input 'food_inc', 1

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
        canvas.write(t[1].id, 540, i * 12 + 25, '#00ddff')
        canvas.write(t[1].health, 560, i * 12 + 25, c.health(t[1].health))
        canvas.write(t[1].age, 600, i * 12 + 25, '#ffff00')
      
      avg_health = _(turtles).reduce( 
        (memo, num) -> 
          memo + num[1].health
        0
      ) / turtles.length

      avg_age = _(turtles).reduce( 
        (memo, num) -> 
          memo + num[1].age
        0
      ) / turtles.length

      canvas.write("Avg Age: " + avg_age, 540, 430, '#00ddff')
      canvas.write("Avg Health: " + avg_health, 540, 445, '#00ddff')
      canvas.write("Interval: " + ticks + 'ms', 540, 460, '#00ddff')

  class Turtle

    constructor: (canvas, id) ->
      @age = 0
      @canvas = canvas
      @id = id
      @image = images[randint(8)]
      @health = parse_input 'health_start', 500
      @speed = Math.random() * parse_input('speed', 5)
      @x = randint(canvas.w())
      @y = randint(canvas.h())
      @heading = Math.random() * 1000.0
      @colour = new Colour
      @distance_to_food = 1000.0
      @closer = false
      @seek_turn = Math.random() * 3.14159
      @rand_turn = Math.random() * 2

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
      if @health <= parse_input('health_ceiling', 2500)
        @health = @health + parse_input('health_change', -1)
      else
        @health = parse_input('health_ceiling', 2500)

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

  class Creature

    constructor: (canvas, id) ->
      @age = 0
      @canvas = canvas
      @id = id
      @image = images[randint(8)]
      @health = parse_input 'health_start', 500
      @speed = Math.random() * parse_input('speed', 2)
      @x = randint(canvas.w())
      @y = randint(canvas.h())
      @heading = 0
      @colour = new Colour
      @rand_turn = Math.random() * 2

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

    turn_to: (food) ->
      @heading = (@bearing(food) - (3.14159 / 2.0)) * -1.0

    turn_by: (angle) ->
      @heading += angle

    tick: (food) ->
      @age += 1
      #@health = @health + parse_input('health_change', -1)
      @turn_to food 
      @turn_by @rand_turn 
      @move @speed
      if @health <= parse_input('health_ceiling', 2500)
      else
        @health = parse_input('health_ceiling', 2500)

    dead: -> 
      @health < 1

    bearing: (food) ->
      Math.atan2(food.y - @y, food.x - @x)

  class Population

    constructor: (turtle_count, canvas) ->
      @turtles = []
      for num in [1..turtle_count] 
        @turtles.push(new Creature(canvas, num))
  
    tick: (food) ->
      for turtle, i in @turtles
        turtle.tick(food)
        @turtles[i] = new Creature(canvas, turtle.id) if turtle.dead()
      return food

    stats: ->
      healths = []
      for turtle, i in @turtles
        healths.push [i, turtle]
      healths

  parse_input = (id, otherwise) ->
    value = parseInt($('#' + id).val())
    if is_numeric(value) then value else otherwise

  make_food = -> 
    new Food

  make_images = (images) ->
    for i in [0..7]
      images[i] = new Image
      images[i].onload = ->
      images[i].src = "images/bug#{i}.png"

  randint = (ceil) ->
    Math.floor(Math.random()*ceil)

  rand_colour = ->
    "rgb(#{randint(255)},#{randint(255)},#{randint(255)})"

  modded = (n, mod) ->
    (n + mod) % mod

  is_numeric = (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  ticks = 0
  timer = 0
  images = []
  canvas = null
  food = null
  reporter = null
  population = null

  $('#faster').click( ->
    ticks = parseInt(ticks / 2) if ticks > 1.0
    stop_timer()
    start_timer()
  )
  
  $('#slower').click( ->
    ticks *= 2
    stop_timer()
    start_timer()
  )

  $('#restart').click( ->
    set_initial_button_states()
    stop_timer()
    setup_world()
    start_timer()
  )

  $('#pause').click( ->
    stop_timer()
    $('#pause').attr('disabled', 'disabled');
    $('#slower').attr('disabled', 'disabled');
    $('#faster').attr('disabled', 'disabled');
    $('#resume').attr('disabled', '');
  )

  $('#resume').click( ->
    start_timer()
    set_initial_button_states()
  )

  set_initial_button_states = ->
    $('#resume').attr('disabled', 'disabled');
    $('#pause').attr('disabled', '');
    $('#slower').attr('disabled', '');
    $('#faster').attr('disabled', '');

  setup_world = ->
    ticks = 32
    timer = null
    images = []
    make_images(images)
    canvas = new Canvas 'turtles'
    reporter = new Reporter
    creatures = parse_input('creatures', 10)
    population = new Population(creatures, canvas)
    food = new Food

  start_timer = ->
    timer = setInterval( ->
      canvas.clear()
      food.draw(canvas)
      food = population.tick(food)
      food.tick()
      reporter.stats population.stats()
    , ticks)

  stop_timer = ->
    clearInterval timer
  
  setup_world()
  set_initial_button_states()
  start_timer()



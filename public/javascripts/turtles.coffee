
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
      @x = Math.random() * (canvas.w() - 80) + 40
      @y = Math.random() * (canvas.h() - 80) + 40

    draw: (canvas) ->
      canvas.context.drawImage(images[2], @x - 10, @y - 7.5)

    tick: ->
      @health += parse_input 'food_inc', 1

    move: ->
      @x = Math.random() * 640
      @y = Math.random() * 480

    distance_from: (x, y) ->
      distance_now = Math.sqrt(((@x - x) * (@x - x)) + ((@y - y) * (@y - y))) 
      
  class Reporter

    constructor: ->
      @tracked = 1

    stats: (turtles) ->
      @main_report turtles 
      @tracked_report turtles
    
    main_report: (turtles) ->
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

    tracked_report: (turtles) ->
      turtle = _(turtles).detect( 
        (obj) -> 
          obj.id == @tracked
      )
      t = turtle[1]
      #@rand_turn = Math.random() * 2
      #@eye_width = Math.random()
      #@eye_offset = Math.random()
      col = '#ffff00'
      canvas.write("id: " + t.id, 540, 180, col)
      canvas.write("speed: " + t.speed.toFixed(2), 540, 192, col)
      canvas.write("rand turn: " + t.rand_turn.toFixed(2) , 540, 204, col) 
      canvas.write("eye width: " + t.eye_width.toFixed(2), 540, 216, col)
      canvas.write("eye offset: " + t.eye_offset.toFixed(2) , 540, 228, col) 
      

  class Creature

    constructor: (canvas, id) ->
      @centre = 16
      @age = 0
      @canvas = canvas
      @id = id
      @image = images[0]
      @health = parse_input 'health_start', 500
      @speed = Math.random() * parse_input('speed', 2)
      @x = randint(canvas.w())
      @y = randint(canvas.h())
      @heading = 0
      @colour = new Colour
      @rand_turn = Math.random() * 2
      @eye_width = Math.random() * 2
      @eye_offset = Math.random()

    move: (distance) ->
      @x += Math.sin(@heading) * distance
      @y += Math.cos(@heading) * distance
      @canvas.context.save()
      @canvas.context.translate(@x+@centre, @y+@centre)
      @canvas.context.rotate(-@heading)
      @canvas.context.translate(-@centre, -@centre)
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
      @heading = @bearing food

    turn_by: (angle) ->
      @heading += angle
      if @heading < -3.14159
        @heading += 2 * 3.14159
      if @heading > 3.14159
        @heading -= 2 * 3.14159

    tick: (food) ->
      @action(food)
      @move @speed
      if @health <= parse_input('health_ceiling', 2500)
        @health = @health + parse_input('health_change', -1)
      else
        @health = parse_input('health_ceiling', 2500)
      @age += 1

    action: (food) ->
      left = @can_see_left(food)
      right = @can_see_left(food)
      if left && right
        return
      if left
        @turn_by 0.01 
        return
      if right
        @turn_by -0.01 
        return
      else
        @turn_by rand_range(@rand_turn) 
      
    eats: (food) ->
      if @can_eat_food(food)
        @health += food.health
        return true
      false

    dead: -> 
      @health < 1

    bearing: (food) ->
      Math.atan2(food.x - @centre_x(), food.y - @centre_y())

    centre_x: ->
      @x + @centre

    centre_y: ->
      @y + @centre

    distance_to_food: (food) ->
      a = @centre_x() - food.x
      b = @centre_y() - food.y
      a * a + b * b

    can_eat_food: (food) ->
      @distance_to_food(food) < 49

    can_see_food: (food, offset, width) ->
      bearing = @bearing food
      centre = @heading + @eye_offset
      if bearing < @normalized_angle(@heading + (@eye_width / 2.0)) && bearing > @normalized_angle(@heading - (@eye_width / 2.0))
        return true
      false

    can_see_left: (food) ->
      @can_see_food(food, @eye_offset, @eye_width)

    can_see_right: (food) ->
      @can_see_food(food, -@eye_offset, @eye_width)

    normalized_angle: (angle) -> 
      if angle < -3.14159
        angle += 2 * 3.14159
      if angle > 3.14159
        angle -= 2 * 3.14159
      angle
      
  class Population

    constructor: (turtle_count, canvas) ->
      @turtles = []
      for num in [1..turtle_count] 
        @turtles.push(new Creature(canvas, num))
  
    tick: (food) ->
      for turtle, i in @turtles
        if turtle.eats(food) 
          food = new Food()
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
    images[0] = new Image
    images[0].onload = ->
    images[0].src = "images/predator.png"
    images[1] = new Image
    images[1].onload = ->
    images[1].src = "images/rock2.jpg"
    images[2] = new Image
    images[2].onload = ->
    images[2].src = "images/banana.png"

  randint = (ceil) ->
    Math.floor(Math.random()*ceil)

  rand_range = (top) ->
    (Math.random()*top) - (top / 2.0)

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
      canvas.context.drawImage(images[1], 0, 0)
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



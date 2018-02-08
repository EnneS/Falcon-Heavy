class Hero
  attr_reader :x, :y
  attr_accessor :dernierBlocCasse, :dernierBlocPoser

  def initialize(x, y, map)
    @map = map

    @dernierBlocCasse = (Time.now.to_f*1000).to_i
    @dernierBlocPoser = (Time.now.to_f*1000).to_i

    @x = x
    @y = y
    @velocityY = 0

    @sprinting = false
    # création d'un tableau qui contiendra les différentes images du héros
    @images = []
    # on ajoute les 4 images dans le tableau
    @images.push(Gosu::Image.new("res/hero/face.png"))
    @images.push(Gosu::Image.new("res/hero/dos.png"))
    @images.push(Gosu::Image.new("res/hero/gauche.png"))
    # de base, le héros est de face
    @image = @images[0]

    @direction = 1

    @imagesDroite = []
    @imagesDroite.push(Gosu::Image.new("res/hero/droite1.png",{ :retro => true}))
    @imagesDroite.push(Gosu::Image.new("res/hero/droite2.png",{ :retro => true}))
    @imagesDroite.push(Gosu::Image.new("res/hero/droite3.png",{ :retro => true}))
    @imagesDroite.push(Gosu::Image.new("res/hero/droite4.png",{ :retro => true}))
    @imagesDroite.push(Gosu::Image.new("res/hero/droite5.png",{ :retro => true}))

    @imagesGauche = []
    @imagesGauche.push(Gosu::Image.new("res/hero/gauche1.png",{ :retro => true}))
    @imagesGauche.push(Gosu::Image.new("res/hero/gauche2.png",{ :retro => true}))
    @imagesGauche.push(Gosu::Image.new("res/hero/gauche3.png",{ :retro => true}))
    @imagesGauche.push(Gosu::Image.new("res/hero/gauche4.png",{ :retro => true}))
    @imagesGauche.push(Gosu::Image.new("res/hero/gauche5.png",{ :retro => true}))

    @imagesFace = []
    @imagesFace.push(Gosu::Image.new("res/hero/face1.png",{ :retro => true}))
    @imagesFace.push(Gosu::Image.new("res/hero/face2.png",{ :retro => true}))
    @imagesFace.push(Gosu::Image.new("res/hero/face3.png",{ :retro => true}))
    @imagesFace.push(Gosu::Image.new("res/hero/face4.png",{ :retro => true}))
  end

  def draw
    @image.draw(@x - 30, @y - @image.height*1.5, ZOrder::Hero, 1.5, 1.5) # on le draw à partir du bas du sprite (utile pour la collision)
  end

  def peutSeDeplacer(offs_x, offs_y)
    # Regarde dans les directions (offs_x et offs_y) si le prochain bloc est solide
    not @map.solid(@x + offs_x, @y + offs_y) and not @map.solid(@x + offs_x, @y + offs_y - 45)
  end

  def update(move_x)
    indices = [0] * 1 + [1] * 1 + [2] * 1 + [3] * 1

    # Actualisation de l'image en fonction de la direction
    if (move_x == 0)
      index = indices[Gosu::milliseconds / 300 % indices.size]
      @image = @imagesFace[index]
    end
    if (@velocityY < 0)
    #SAUT ANIMATION  @image = @jump
    end

    # Mouvement horizontal, se déplace si le prochain bloc dans la direction n'est pas solide
    if move_x > 0
      index = indices[Gosu::milliseconds / 100 % indices.size]
      @direction = 1
      @image = @imagesDroite[index]
      move_x.times {
        if peutSeDeplacer(1, 0)
          @x += 1
        end }
    end

    if move_x < 0
      index = indices[Gosu::milliseconds / 100 % indices.size]
      @direction = -1
      @image = @imagesGauche[index]
      (-move_x).times {
        if peutSeDeplacer(-1, 0)
          @x -= 1
        end }
    end

    # Gravité
    @velocityY += 1

    # Mouvement vertical, la vélocité augmente si le prochain bloc dans la direction n'est pas solide
    if @velocityY > 0
      @velocityY.times { if peutSeDeplacer(0, 1) then @y += 1 else @velocityY = 0 end }
    end
    if @velocityY < 0
      (-@velocityY).times { if peutSeDeplacer(0, -1) then @y -= 1 else @velocityY = 0 end }
    end
  end

  def jump
    if @map.solid(@x, @y +1) # il saute seulement s'il n'est pas dans les airs
      @velocityY = -21
    end
  end

end

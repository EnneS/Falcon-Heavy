class Monstre
    attr_reader :x, :y, :type

    def initialize(type, x, y, map, hero)
      @map = map
      @type = type

      @noms = Array.new(3)
      @noms[0] = "loup"

      @x = x
      @y = y

      @speed = 4

      @focusRangeIdle = 10
      @focusRangeActive = 15

      @hero = hero

      @velocityY = 0

      @focus = nil

      @dateDerniereAttaque = (Time.now.to_f*1000.0).to_i
      @lastMovement = (Time.now.to_f*1000.0).to_i

      @xt = 0
      @yt = 0
      @delay = 2500

      @direction = 1

      nom = @noms[type]
      @imagesDroite = []
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite1.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite2.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite3.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite4.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite5.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite6.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite7.png",{ :retro => true}))
      @imagesDroite.push(Gosu::Image.new("res/mobs/" + nom + "/droite8.png",{ :retro => true}))

      @imagesGauche = []
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche1.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche2.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche3.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche4.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche5.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche6.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche7.png",{ :retro => true}))
      @imagesGauche.push(Gosu::Image.new("res/mobs/" + nom + "/gauche8.png",{ :retro => true}))


      @imagesFace = []
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face1.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face2.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face3.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face4.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face5.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face6.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face7.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face8.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face9.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face10.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face11.png",{ :retro => true}))
      @imagesFace.push(Gosu::Image.new("res/mobs/" + nom + "/face12.png",{ :retro => true}))


      @image = @imagesFace[0]
    end

    def draw
      @image.draw(@x - 20, @y - @image.height*3, ZOrder::Hero, 3, 3) # on le draw à partir du bas du sprite (utile pour la collision)
    end

    def peutSeDeplacer(offs_x, offs_y)
      # Regarde dans les directions (offs_x et offs_y) si le prochain bloc est solide
      not @map.solidLoup(@x + offs_x, @y + offs_y) and not @map.solidLoup(@x + offs_x, @y + offs_y - 45)
    end

    def update(move_x)
      indices = [0] * 1 + [1] * 2 + [2] * 3 + [3] * 4 + [4] * 30
      index = indices[Gosu::milliseconds / 300 % indices.size]

      # Actualisation de l'image en fonction de la direction
      if (move_x == 0)
        @image = @imagesFace[index]
      end

      # animation du saut
      if (@velocityY < 0)
      #SAUT   @image =
      end

      # Mouvement horizontal, se déplace si le prochain bloc dans la direction n'est pas solide
      if move_x > 0
        @direction = 1
        @image = @imagesDroite[index]
        move_x.times {
          if peutSeDeplacer(1, 0)
            @x += 1
          else
            jump()
          end
        }
      end

      if move_x < 0
        @direction = -1
        @image = @imagesGauche[index]
        (-move_x).times {
          if peutSeDeplacer(-1, 0)
            @x -= 1
          else
            jump()
          end
        }
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
      if @map.solidLoup(@x, @y +1) # il saute seulement s'il n'est pas dans les airs
        @velocityY = -21
      end
    end

    def HeroInRange(distance)
      return ((@hero.x-@x).abs<= distance*64) && ((@hero.y-@y).abs<=distance*64)
    end

    def IA_Terre
      n = (Time.now.to_f*1000.0).to_i
      if n - @lastMovement > @delay
        if @focus == nil
          @delay = $rng.Random(3000) + 500
          @xt = ($rng.Random(5) - 2)*$scale*32 + @x
          @yt = 0
          @lastMovement = n
          @speed = 3
        else
          @delay = $rng.Random(300) + 200
          @xt = ($rng.Random(5) - 2)*$scale*32 + @hero.x
          @yt = 0
          @lastMovement = n
          @speed = 8
        end
      else
        xf = @xt - @x
        if xf != 0
          xf /= xf.abs
        end

        update((xf*@speed).to_i)
      end
      if @focus == nil && HeroInRange(@focusRangeIdle)
        @focus = @hero
        @delay = 200
      end
      if @focus != nil && HeroInRange(@focusRangeActive)
        @focus = @hero
        @delay = 200
      end
    end

end

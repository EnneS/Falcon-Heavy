require 'set'
class Window < Gosu::Window

  def initialize(width, height)
    super(width, height, false)
    self.caption = "Hardcore Survival"

    $font = Gosu::Font.new(self, "res/pokemon_pixel_font.ttf", 40)
    $fontXL = Gosu::Font.new(self, "res/pokemon_pixel_font.ttf", 70)

    @title = Gosu::Image.from_text('En   Bas', 120, {:font => 'res/pokemon_pixel_font.ttf'})
    @hoverJouer = 1
    @jouer = Gosu::Image.from_text('Jouer !', 60, {:font => 'res/pokemon_pixel_font.ttf'})
    @credits = Gosu::Image.from_text('Credits', 60, {:font => 'res/pokemon_pixel_font.ttf'})
    @quitter = Gosu::Image.from_text('Quitter', 60, {:font => 'res/pokemon_pixel_font.ttf'})

    @gamebackground_image = Gosu::Image.new("res/blue.jpg")

    @bg1 = Gosu::Image.new("res/1.png", {:tileable => true, :retro => true })
    @bg2 = Gosu::Image.new("res/2.png", {:tileable => true, :retro => true })
    @bg3 = Gosu::Image.new("res/3.png", {:tileable => true, :retro => true })
    @bg4 = Gosu::Image.new("res/4.png", {:tileable => true, :retro => true})
    @bgn = Gosu::Image.new("res/black.png", {:tileable => true, :retro => true})

    #@grotte1 = Gosu::Font.new("res/fond.png")

    @map = Map.new()
    generate()
    #@map.load()
    @hero = Hero.new((((@map.data.size-1)/2)*(32*$scale))-1, (@map.ground((@map.data.size-1)/2)*(32*$scale))-1, @map)
    @inventaire = Inventaire.new(6)
    @inventaire.store(4, 1)

    @cursor = Gosu::Image.new("res/cursor.png")
    @camera_x = @camera_y = 0

    @mobCap = 30
    @mobs = Set.new()

    @gameStarted = false

    @move = 0

    @x1 = 0
    @x2 = 0
    @x3 = 0
    @x4 = 0

  end

  def generate()
    @map.generate(3, 3000, 128, 8, 7, 60)
    @map.save
  end

  def update
    @inventaire.setSelected(0) if Gosu::button_down?(Gosu::Kb1)
    @inventaire.setSelected(1) if Gosu::button_down?(Gosu::Kb2)
    @inventaire.setSelected(2) if Gosu::button_down?(Gosu::Kb3)
    @inventaire.setSelected(3) if Gosu::button_down?(Gosu::Kb4)
    @inventaire.setSelected(4) if Gosu::button_down?(Gosu::Kb5)
    @inventaire.setSelected(5) if Gosu::button_down?(Gosu::Kb6)

    if @gameStarted == false
      # Evénements du menu
      #

      @move +=5


      # Bouton jouer
      if mouse_x > (1920/2)-(@jouer.width/2) && mouse_x < (1920/2)+(@jouer.width/2) && mouse_y > 600 - @jouer.height && mouse_y < 600
        @jouer = Gosu::Image.from_text('Jouer !',70, {:font => 'res/pokemon_pixel_font.ttf'})
        if Gosu.button_down? Gosu::MsLeft
          @gameStarted = true
        end
     else
       @jouer = Gosu::Image.from_text('Jouer !',60, {:font => 'res/pokemon_pixel_font.ttf'})
     end

     # Bouton quitter
       if mouse_x > (1920/2)-(@quitter.width/2) && mouse_x < (1920/2)+(@quitter.width/2) && mouse_y > 800 - @quitter.height/2 && mouse_y < 800 + @quitter.height/2
         @quitter = Gosu::Image.from_text('Quitter',70, {:font => 'res/pokemon_pixel_font.ttf'})
         if Gosu.button_down? Gosu::MsLeft
           close
         end
      else
        @quitter = Gosu::Image.from_text('Quitter',60, {:font => 'res/pokemon_pixel_font.ttf'})
     end

    else
      @gameStarted = false if Gosu::button_down?(Gosu::KbEscape)

      # Actions du héro
      temp = @hero.x

      move_x = 0
      move_x -= 9 if Gosu.button_down? Gosu::KB_LEFT
      move_x += 9 if Gosu.button_down? Gosu::KB_RIGHT
      #move_x *= 2 if Gosu::button_down?(Gosu::KbLeftShift)
      @hero.update(move_x)
      @hero.jump if Gosu::button_down?(Gosu::KbSpace)

      @move += move_x if temp != @hero.x


      # Viewport ! Il s'agit d'un tableau avec les coordonnées max possible de la fenêtre (en l'occurence la taille de la map)
      # Si on arrive aux extrêmités il faut arrêter le scroll (on utilise ainsi min et max par rapport à la taille de la fenêtre)
      @camera_x = [[@hero.x - 1920 / 2, 0].max, (@map.w)*64 - 1920].min
      @camera_y = [[@hero.y - 1080 / 2, 0].max, (@map.h)*64 - 1080].min


      if button_down?(Gosu::MsLeft)

        cursor_x = self.mouse_x
        cursor_y = self.mouse_y

        v = @inventaire.idItem(@inventaire.selected)

        if (v != 4) && (v != 5)

          x,y = @map.trouveBlocP(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)

          if @hero.dernierBlocPoser < (Time.now.to_f*1000).to_i-500 and x != -1 and y != -1

            bloc_x, bloc_y = @map.trouveBlocP(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)
            #puts bloc_x.to_s+" . "+bloc_y.to_s
            @map.poserBloc(bloc_x,bloc_y,v)
            @inventaire.pick(v,1)
            @hero.dernierBlocPoser = (Time.now.to_f*1000).to_i

          end

        end

        if v == 4

          x,y = @map.trouveBloc(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)

          if @hero.dernierBlocCasse < (Time.now.to_f*1000).to_i-500 and x != -1 and y != -1
            bloc_x, bloc_y = @map.trouveBloc(cursor_x,cursor_y,@camera_x,@camera_y,@hero.x, @hero.y)
            id = @map.data[bloc_x][bloc_y]

            @map.detruireBloc(bloc_x,bloc_y)
            if @map.data[bloc_x][bloc_y] == 0
              @inventaire.store(id,1)
            end
            @hero.dernierBlocCasse = (Time.now.to_f*1000).to_i
          end

        end
      end
    end
    #mobs
    if @mobs.size < @mobCap
      spawnMob()
    end
    @mobs.each do |m|
      if !m.HeroInRange(50)
        @mobs.delete(m)
      else
        m.IA_Terre()
      end
    end
  end

  def spawnMob()
    xr = $rng.Random(60) - 30
    yr = $rng.Random(60) - 30
    x = xr + @camera_x/64
    y = yr + @camera_y/64

    if xr > 0
      x += Gosu::screen_width()/64
    end

    if yr > 0
      y += Gosu::screen_height()/64
    end
    if @map.data[x][y] == Tiles::Air
      @mobs.add(Monstre.new(0, x*64, y*64, @map, @hero))
    end
  end

  def draw
    @cursor.draw self.mouse_x, self.mouse_y, 99

    if @gameStarted == false
      # Le jeu n'a pas commencé :
      # Affichage du menu

      @title.draw_rot(1920/2, 200, 1, 0.5, 0.5)
      @jouer.draw_rot(1920/2, 600, 1, 0.5, 0.5, 1, @hoverJouer)
      @credits.draw_rot(1920/2, 700, 1, 0.5, 0.5)
      @quitter.draw_rot(1920/2, 800, 1, 0.5, 0.5)

      off1 = -@move*0.5
      if off1 + @x1 >= @bg1.width*2.2
        @x1-=@bg1.width*2.2
      end
      if off1 + @x1 < (@bg1.width*2.2 - 2300)
        @x1+=@bg1.width*2.2
      end

      off2 = -@move*0.25
      if off2 + @x2 >= @bg2.width*2.2
        @x2-=@bg2.width*2.2
      end
      if off2 + @x2 < (@bg2.width*2.2 - 2300)
        @x2+=@bg2.width*2.2
      end

      off3 = -@move*0.125
      if off3 + @x3 >= @bg3.width*2.2
        @x3-=@bg3.width*2.2
      end
      if off3 + @x3 < (@bg3.width*2.2 - 2300)
        @x3+=@bg3.width*2.2
      end

      off4 = -@move*0.0625
      if off4 + @x4 >= @bg4.width*2.2
        @x4-=@bg4.width*2.2
      end
      if off4 + @x4 < (@bg4.width*2.2 - 2300)
        @x4+=@bg4.width*2.2
      end

      col = Gosu::Color.new(160, 255, 255, 255)

      @bgn.draw(0, 0, -2,1,1,col)

      @bg1.draw(off1+@x1, 183, -3, 2.2,2.2)
      @bg2.draw(off2+@x2, 0, -4,2.2,2.2)
      @bg3.draw(off3+@x3, 0, -5, 2.2,2.2)
      @bg4.draw(off4+@x4, 0, -6, 2.2,2.2)


      @bgn.draw(0, 0, -2,1,1,col)
      @bg1.draw(off1+@x1-@bg1.width*2.2, 183, -3, 2.2,2.2)
      @bg2.draw(off2+@x2-@bg2.width*2.2, 0, -4,2.2,2.2)
      @bg3.draw(off3+@x3-@bg3.width*2.2, 0, -5, 2.2,2.2)
      @bg4.draw(off4+@x4-@bg4.width*2.2, 0, -6, 2.2,2.2)
    else
      # Le jeu a commencé : on affiche le background, la profondeur, l'inventaire
      # le héro et la map

      col = Gosu::Color.new(150, 255, 255, 255)

      off1 = -@move*0.5
      if off1 + @x1 >= @bg1.width*2.2
        @x1-=@bg1.width*2.2
      end
      if off1 + @x1 < (@bg1.width*2.2 - 2300)
        @x1+=@bg1.width*2.2
      end

      off2 = -@move*0.25
      if off2 + @x2 >= @bg2.width*2.2
        @x2-=@bg2.width*2.2
      end
      if off2 + @x2 < (@bg2.width*2.2 - 2300)
        @x2+=@bg2.width*2.2
      end

      off3 = -@move*0.125
      if off3 + @x3 >= @bg3.width*2.2
        @x3-=@bg3.width*2.2
      end
      if off3 + @x3 < (@bg3.width*2.2 - 2300)
        @x3+=@bg3.width*2.2
      end

      off4 = -@move*0.0625
      if off4 + @x4 >= @bg4.width*2.2
        @x4-=@bg4.width*2.2
      end
      if off4 + @x4 < (@bg4.width*2.2 - 2300)
        @x4+=@bg4.width*2.2
      end

      @bgn.draw(0, 0, -2,1,1,col)

      yoff = min(0, 128*64 - @hero.y)*0.2

      @bg1.draw(off1+@x1, 183 + yoff, -3, 2.2,2.2)
      @bg2.draw(off2+@x2, 0 + yoff, -4,2.2,2.2)
      @bg3.draw(off3+@x3, 0 + yoff, -5, 2.2,2.2)
      @bg4.draw(off4+@x4, 0 + yoff, -6, 2.2,2.2)


      @bgn.draw(0, 0, -2,1,1,col)
      @bg1.draw(off1+@x1-@bg1.width*2.2, 183 + yoff, -3, 2.2,2.2)
      @bg2.draw(off2+@x2-@bg2.width*2.2, 0 + yoff, -4,2.2,2.2)
      @bg3.draw(off3+@x3-@bg3.width*2.2, 0 + yoff, -5, 2.2,2.2)
      @bg4.draw(off4+@x4-@bg4.width*2.2, 0 + yoff, -6, 2.2,2.2)

      #Profondeur du joueur
      $fontXL.draw("Profondeur : " + (@hero.y/64).to_s, 20, 20, 5)

      @inventaire.draw
      Gosu.translate(-@camera_x, -@camera_y) do
        @hero.draw
        @map.draw(@hero.x, @hero.y)
        @mobs.each do |m|
          m.draw()
        end
      end

    end
  end

end

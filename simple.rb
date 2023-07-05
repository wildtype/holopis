class Window

  BASE_WIDTH = 3440
  BASE_HEIGHT = 1440

  WIDTH = 1960
  HEIGHT = 1200

  CORNER_X = 3440 - WIDTH - 120
  CORNER_Y = 120

  def initialize(id:)
    @window_id = id
  end

  def set_geometry(param)
    width, height = geom(param)
    `xdotool windowsize #{@window_id} #{width} #{height}`
  end

  def set_position(param)
    corner_x, corner_y = position(param)
    `xdotool windowmove #{@window_id} #{corner_x} #{corner_y}`
  end

  private

  def position(param)
    if param == :right
      return CORNER_X + (WIDTH/2)+2, 120
    else
      return CORNER_X, CORNER_Y
    end
  end

  def geom(param)
    if param == :full
      return WIDTH, HEIGHT
    else
      return (WIDTH/2)-2, HEIGHT
    end
  end

  def self.create_from_active_window
    window_id = `xdotool getactivewindow`.strip
    self.new(id: window_id)
  end
end

window = Window.create_from_active_window

param = case ARGV[0]
         when 'left'
           :left
         when 'right'
           :right
         else
           :full
         end

window.set_position(param)
window.set_geometry(param)

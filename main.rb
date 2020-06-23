#!/usr/bin/env ruby

class Array
  def second
    self[1]
  end
end

WindowGeometry = Struct.new(:x, :y, :width, :height)

class Xdotool
  class << self
    def get_active_window
      `xdotool getactivewindow`.strip
    end

    def get_window_geometry(id)
      lines = `xdotool getwindowgeometry #{id}`.strip.split("\n")
      position = lines[1].strip.split(' ').second.split(',')
      geometry = lines[2].strip.split(' ').second.split('x')

      WindowGeometry.new(
        position[0].to_i,
        position[1].to_i,
        geometry[0].to_i,
        geometry[1].to_i
      )
    end

    def get_display_geometry
      `xdotool getdisplaygeometry`.strip.split(' ').map(&:to_i)
    end

    def window_move(window:, x:, y:)
      `xdotool windowmove #{window} #{x} #{y}`
    end

    def window_activate(window)
      `xdotool windowactivate #{window}`
    end

    def window_minimize(window)
      `xdotool windowminimize #{window}`
    end
  end
end

class Desktop
  attr_reader :width, :height

  def initialize
    geom = Xdotool.get_display_geometry
    @width = geom[0]
    @height = geom[1]
    @active_window = active_window
  end

  def windows
    @windows ||= wmctrl_list_window_ids
      .map { |window_id| Window.new(window_id, self) }
  end

  def active_window
    active_window_id = Xdotool.get_active_window.to_i

    windows.find do |window|
      window.id == active_window_id
    end
  end

  def minimize_all(except: [])
    (windows - except).each do |window|
      window.minimize!
    end
  end

  private

  def wmctrl_list_window_ids
    `wmctrl -l`
      .split("\n")
      .map(&:split)
      .filter{|line| line[1].to_i > -1}
      .map(&:first)
      .map{|hex| Integer(hex, 16)}
  end
end

class Window
  attr_reader :id, :desktop

  def initialize(window_id, desktop_obj)
    @desktop = desktop_obj
    @id = window_id
  end

  def geometry
    @geometry ||= Xdotool.get_window_geometry(id)
  end

  def center!
    position = centered_position
    Xdotool.window_move(window: id, x: position[:x], y: position[:y])
  end

  def centered_position
    desktop_center_x = desktop.width / 2
    desktop_center_y = desktop.height / 2

    {
      x: desktop_center_x - (geometry.width / 2),
      y: desktop_center_y - (geometry.height / 2)
    }
  end

  def activate!
    Xdotool.window_activate(id)
  end

  def minimize!
    Xdotool.window_minimize(id)
  end
end

desktop = Desktop.new
active_window = desktop.active_window

desktop.minimize_all(except: [active_window])
active_window.center!

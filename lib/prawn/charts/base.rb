module Prawn
  class Charts::Base
    attr_reader :pdf
    attr_accessor :title, :legend
    attr_accessor :padding, :x, :y, :y1, :series
    attr_accessor :at, :width, :height
    attr_accessor :key_formatter, :value_formatter

    extend Forwardable

    def_delegators :@pdf, :bounding_box, :bounds
    def_delegators :@pdf, :draw_text, :pad, :text
    def_delegators :@pdf, :stroke_axis, :rotate, :stroke_bounds
    def_delegators :@pdf, :height_of, :width_of
    def_delegators :@pdf, :fill, :fill_color
    def_delegators :@pdf, :rectangle, :stroke_color, :line, :stroke
    def_delegators :@pdf, :fill_ellipse, :curve

    def initialize pdf, opts = {}

      @pdf             = pdf
      opts             = defaults.merge(opts)
      @title           = opts[:title]
      @legend          = opts[:legend]
      @padding         = opts[:padding]
      @x               = opts[:x]
      @y               = opts[:y]
      @y1              = opts[:y1]
      @at              = opts[:at]
      @width           = opts[:width]
      @height          = opts[:height]
      @series          = opts[:series]
      @key_formatter   = opts[:key_formatter]
      @value_formatter = opts[:value_formatter]
    end

    def defaults
      {
        padding:  {
          bottom:  50,
          left:    50,
          right:   50,
          top:     50,
        },
        at:       [0,0],
        width:    500,
        height:   200,
        key_formatter: lambda{ |key| key.to_s },
        value_formatter: lambda{ |value| value.to_s }
      }
    end

    def draw
      bounding_box at, width: width, height: height do
        stroke_bounds

        draw_title
        draw_x_axis_label if x
        draw_y_axis_label if y
        draw_y1_axis_label if y1

        bounding_box(chart_at, width: chart_width, height: chart_height) do
          draw_x_axis if x
          draw_y_axis if y
          draw_y1_axis if y1
          #stroke_axis( color: 'FF00', step_length: 50 )
          plot_values
        end

      end
    end

    def padding_top_bottom
      padding[:top] + padding[:bottom]
    end

    def padding_left_right
      padding[:left] + padding[:right]
    end

    def chart_at
      [ bounds.left + (padding_left_right / 2), bounds.top - (padding_top_bottom / 2) ]
    end

    def chart_width
      bounds.width - padding_left_right
    end

    def chart_height
      bounds.height - padding_top_bottom
    end

    def draw_title
      opts ={ width: bounds.width, height: height_of(title.to_s) }
      bounding_box( [bounds.left, bounds.top - height_of(title.to_s) / 2], opts ) do
        text title, align: :center
      end
    end

    def draw_y_axis_label
      w = width_of(y[:title]) / 2
      rotate 90, origin: [bounds.left + w , (bounds.height / 2 )] do
        mid = bounds.height / 2
        draw_text y[:title], at: [0, mid]
      end
    end

    def draw_y1_axis_label
      w = width_of(y1[:title]) / 2
      rotate 270, origin: [bounds.right - w, (bounds.height / 2 )] do
        mid = bounds.height / 2
        draw_text y1[:title], at: [bounds.right - w, mid]
      end
    end

    def draw_x_axis_label
      opts ={ width: bounds.width, height: height_of(x[:title]) }
      bounding_box( [bounds.left, bounds.bottom + height_of(x[:title])], opts ) do
        text x[:title], align: :center
      end
    end


    def draw_x_axis
      txt = series.map do |s|
        s[:values].map{ |v| height_of(key_formatter.call(v[:key]))}.max
      end.max

      opts = {
        series:  series,
        at:      [0,0],
        width:   bounds.width,
        height:  txt,
        points:  x_points,
        formatter: key_formatter
      }

      Prawn::Charts::XAxis.new(pdf, opts).draw
    end

    def draw_y_axis
      txt = series.map do |s|
        s[:values].map{ |v| width_of(value_formatter.call(v[:value]))}.max
      end.max

      opts = {
        at:         [-txt, bounds.height],
        width:      txt,
        height:     bounds.height,
        points:     [min_value, max_value],
        formatter:  value_formatter
      }

      Prawn::Charts::YAxis.new(pdf, opts).draw

    end

    def draw_y1_axis
      txt = series.map do |s|
        s[:values].map{ |v| width_of(value_formatter.call(v[:value]))}.max
      end.max

      opts = {
        at:         [bounds.right, bounds.height],
        width:      txt,
        height:     bounds.height,
        points:     [min_value, max_value],
        formatter:  value_formatter
      }

      Prawn::Charts::YAxis.new(pdf, opts).draw

    end


    def plot_values
    end

    def x_points
    end

    def values
      @values ||= series.map{ |bar| bar[:values].map{|single| single[:value] }}.flatten
    end

    def max_value
      #n = values.max + delta_value * 0.1
      n = values.max
      exp = 10 ** (Math.log10(n).floor - 1)
      n + ( exp  - n % exp)  + exp
    end

    def min_value
      n = (values.min - delta_value * 0.1).to_i
      exp = 10 ** (Math.log10(n).floor - 1)
      n - (n % exp)
    end

    def delta_value
      values.max - values.min
    end

    def series_height
      max_value - min_value
    end
  end
end

module Prawn
  class Charts::YAxis
    attr_reader :pdf
    attr_accessor :points, :at, :width, :height, :formatter

    extend Forwardable

    def_delegators :@pdf, :bounding_box, :stroke_bounds, :text
    def_delegators :@pdf, :height_of, :width_of
    def_delegators :@pdf, :draw_text, :bounds

    def initialize pdf, opts
      @pdf       = pdf
      @at        = opts[:at]
      @width     = opts[:width]
      @height    = opts[:height]
      @points    = opts[:points]
      @formatter = opts[:formatter]
    end

    def draw
      bounding_box at, width: width, height: height do
        #stroke_bounds

        next_point = -100
        slice = if (text_height * list.count) > bounds.height
                  list.count.to_f / text_height.to_f
                else
                  1
                end.ceil.to_i

        list.each_slice(slice) do |items|
          items.each do |item|
            percent = ((item - points.min).to_f / axis_height.to_f)
            y_point = (percent * bounds.height) - (text_height / 3).to_i
            if y_point > next_point
              draw_text formatter.call(item), at: [0, y_point]
              next_point = y_point + text_height
              break
            end

          end
        end
      end
    end

    def max_slice
      (bounds.height.to_f / single_height.to_f).ceil
    end

    def text_height
      @text_height ||= height_of(formatter.call( points.first))
    end

    def axis_height
      points.max - points.min
    end

    def single_height
      (bounds.height / text_height).to_i
    end

    def list
      return @range if @range
      exp = Math.log10(points.min).floor - 1
      @range =[]
      (points.min.to_i..points.max.to_i).each_slice( 10 ** exp) do |n|
        @range.push n.first
      end
      @range

    end
  end
end

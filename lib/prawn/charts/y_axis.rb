module Prawn
  module Charts
    class YAxis
      attr_reader :pdf
      attr_accessor :points, :at, :width, :height, :formatter

      extend Forwardable

      def_delegators :@pdf, :bounding_box, :stroke_bounds, :text
      def_delegators :@pdf, :height_of, :width_of, :fill_color
      def_delegators :@pdf, :draw_text, :bounds

      def initialize pdf, opts
        @pdf       = pdf
        @at        = opts[:at]
        @width     = opts[:width]
        @height    = opts[:height]
        @points    = opts[:points]
        @formatter = opts[:formatter]
        @percentage = opts[:percentage]
      end

      def draw
        fill_color '0000'
        bounding_box at, width: width, height: height do
          last_point = nil
          list.each do |item|
            percent = ((item - points.min).to_f / axis_height.to_f)
            y_point = (percent * bounds.height) - (text_height / 3).to_i
            if y_point > (last_point || y_point - 1)
              draw_text formatter.call(item), at: [0, y_point]
              last_point = y_point + text_height
            end
          end
        end
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
        return percentage_list if percentage?
        return @range if @range
        @range =[]
        exp = Math.log10(points.min).floor - 1
        (points.min.to_i..points.max.to_i).each_slice( 10 ** exp) do |n|
          @range.push n.first
        end
        @range
      end

      def percentage?
        @percentage
      end

      def percentage_list
        percentage_list = []
        (0 .. 100).each_slice(10) do |n|
          percentage_list.push n.first
        end
        percentage_list
      end

    end
  end
end
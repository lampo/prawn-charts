module Prawn
  module Charts
    class YAxis
      attr_reader :pdf
      attr_accessor :points, :at, :width, :height, :formatter

      extend Forwardable

      def_delegators :@pdf, :bounding_box, :stroke_bounds, :text
      def_delegators :@pdf, :height_of, :width_of, :fill_color
      def_delegators :@pdf, :text_box, :bounds

      def initialize pdf, opts
        @pdf        = pdf
        @at         = opts[:at]
        @width      = opts[:width]
        @height     = opts[:height]
        @points     = opts[:points]
        @formatter  = opts[:formatter]
        @percentage = opts[:percentage]
      end

      def with_font
        original_font = @pdf.font_size
        @pdf.font_size -= 2
        yield
        @pdf.font_size = original_font
      end

      def draw
        with_font do
          bounding_box at, width: width, height: height do
            last_point = nil
            list.each do |item|
              percent = ((item - points.min).to_f / axis_height.to_f)
              y_point = (percent * bounds.height) + (text_height / 3).to_i
              if y_point > (last_point || y_point - 1)
                text_box formatter.call(item), at: [0, y_point], align: :right
                last_point = y_point + text_height * 1.5
              end
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
        (points.min.to_i..points.max.to_i).each_slice(exp) do |n|
          @range.push n.first
        end
        @range
      end

      def exp
        n = points.min <= 0 ? 10 : points.min
        10 ** (Math.log10(n).floor)
      end

      def percentage?
        @percentage
      end

      def percentage_list
        [0, 25, 50, 75, 100]
      end

    end
  end
end

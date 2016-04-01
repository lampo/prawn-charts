module Prawn
  module Charts
    class YAxis
      attr_reader :pdf
      attr_accessor :points, :at, :width, :height, :formatter, :percentage

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
        @only_zero = opts[:only_zero]

        if percentage?
          @points = [0, 100]
        end
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
              percent = ((item - points.min).to_f / (axis_height).to_f)
              y_point = (percent * (bounds.height - text_height)) + (text_height / 3).to_i

              if y_point < 0
                y_point = text_height
              else
                y_point = y_point + text_height
              end

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
        if only_zero?
          100
        else
          points.max - points.min
        end
      end

      def single_height
        (bounds.height / text_height).to_i
      end

      def list
        return percentage_list if percentage? || only_zero?
        return @range.uniq if @range
        @range =[]
        min_val = exp(points.max / 4)
        result = points.min - (points.min % min_val) - min_val
        # @range.push(result)
        @range.push(0)

        (points.min.to_i..points.max.to_i).each do |n|
          val = n == 0 ? 1 : n
          result = val - (val % min_val) - min_val
          @range.push(result)
        end

        val = points.max
        result = val - (val % min_val) - min_val
        @range.push(result)
        @range.uniq
      end

      def exp n, offset = 0
        if n <= 0
          1
        else
          10 ** (Math.log10(n).floor) - offset
        end
      end

      def only_zero?
        @only_zero
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

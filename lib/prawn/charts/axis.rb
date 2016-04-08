module Prawn
  module Charts
    class Axis
      extend Forwardable

      attr_reader :pdf
      attr_accessor :series, :at, :width, :height, :formatter, :ratio
      attr_accessor :orientation, :points, :axis_value_labels, :max_label_width

      def_delegators :@pdf, :bounding_box, :stroke_bounds, :text
      def_delegators :@pdf, :height_of, :width_of, :fill_color
      def_delegators :@pdf, :draw_text, :text_box, :bounds, :rotate
      def_delegators :@pdf, :stroke, :rectangle, :stroke_vertical_line, :stroke_horizontal_line

      def initialize(pdf, opts)
        @pdf       = pdf
        @series    = opts[:series]
        @at        = opts[:at]
        @width     = opts[:width]
        @height    = opts[:height]
        @points    = opts[:points]
        @percentage = opts[:percentage]
        @only_zero = opts[:only_zero]
        @axis_value_labels = opts[:axis_value_labels]
        @max_label_width = opts[:max_label_width]
        @formatter = opts[:formatter]
        @ratio     = opts[:ratio] || 0.9
        @orientation = opts[:orientation]
        if orientation == :values && percentage?
          @points = [0, 100]
        end
      end

      def draw
        if orientation == :series
          draw_series
        else
          draw_values
        end
      end

      def series_labels
        @series_labels ||= series.map do |s|
          s[:values].map do |v|
            formatter.call(v[:key])
          end.uniq
        end.flatten.uniq
      end

      def with_font
        original_font = @pdf.font_size
        @pdf.font_size -= 3
        yield
        @pdf.font_size = original_font
      end

      def exp(n, offset = 0)
        if n <= 0
          1
        else
          10 ** (Math.log10(n).floor) - offset
        end
      end

      def series_length
        series.map { |v| v[:values].length }.max * series.count
      end

      def percentage?
        @percentage
      end

      def only_zero?
        @only_zero
      end

      def label_height
        height_of("0") * 2
      end

      def label_width
        desired_width =
          if orientation == :series
            series.map do |s|
              s[:values].map do |v|
                width_of(formatter.call(v[:key]))
              end.max
            end.max
          else
            axis_value_labels.map do |v|
              width_of(formatter.call(v.first))
            end.max
          end
        desired_padding =
          if orientation == :series
            10
          else
            height_of(formatter.call(0)) / 2
          end

        [desired_width, (bounds.width - desired_padding)].min
      end
    end
  end
end

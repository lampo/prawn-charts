module Prawn
  module Charts
    class HorizontalBar < HorizontalBase
      def initialize(pdf, opts={})
        super pdf, opts
      end

      def plot_values
        return if series.nil?

        series.each_with_index do |bar,index|
          point_y = first_y_point index

          bar[:values].each_with_index do |h, i|
            width = value_width(h[:value])
            if bar[:colors]
              color = bar[:colors][i]
            end
            color ||= bar[:color]
            with_color color do
              fill do
                rectangle [0, point_y], width, bar_height
              end
            end

            with_smaller_font do
              text_box value_formatter.call(h[:value]), at: [width + 5, point_y - label_padding], height: bar_height, width: label_width
            end
            point_y -= additional_points
          end
        end
      end

      def values_height
        bounds.height + 15
      end

      def additional_points
        (bar_space + bar_height) * series.count
      end

      def bar_space
        @bar_space ||= (values_height * (1.0 - ratio)) / (series_length + 1).to_f
      end

      def value_width(val)
        scale_factor =
          if val == 0
            0.01
          elsif percentage
            val * 0.01
          else
            (val - min_value) / series_span.to_f
          end
        scale_factor * (bounds.width - 10)
      end

      def label_width
        series.map { |b| b[:values].map { |val| width_of(val.to_s) }.max }.max
      end

      def bar_height
        @bar_height ||= (values_height * ratio) / series_length.to_f
      end

      def first_y_point(index)
        values_height + ((bar_height * index) + (bar_space * (index + 1))) - 15
      end

      def label_padding
        @label_padding ||= (bar_height - label_height) / 2.0
      end

      def label_height
        @label_height ||= height_of("0")
      end

      def y_points
        points = []
        point_y = first_y_point(0) + (bar_height / 2)
        series.first[:values].each do |_value|
          points << point_y

          point_y -= additional_points
        end
        points
      end
    end
  end
end

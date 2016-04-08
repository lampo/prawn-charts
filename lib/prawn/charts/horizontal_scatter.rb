module Prawn
  module Charts
    class HorizontalScatter < HorizontalBar
      def initialize(pdf, opts={})
        super pdf, opts
      end

      def plot_values
        return if series.nil?

        point_x = 0
        axis_value_labels.each do |val, _item|
          point_x = value_width(val) - radius + 1
          point_y = first_y_point - radius

          stroke_vertical_line 0, point_y, at: point_x, width: 0.5
        end

        max_x = point_x

        series.each_with_index do |bar,index|
          point_y = first_y_point - radius

          bar[:values].each_with_index do |h, i|
            if index.zero?
              stroke_horizontal_line 0, max_x, at: point_y
            end

            unless h[:value]
              point_y -= additional_points
              next
            end

            point_x = value_width(h[:value])

            if bar[:colors]
              color = bar[:colors][i]
            end
            color ||= bar[:color]
            with_color color do
              fill do
                circle [point_x - radius + 1, point_y], radius * 2
              end
            end

            # TODO: optionally enable?
            # with_smaller_font do
            #   text = value_formatter.call(h[:value])
            #   label_width = width_of(text)
            #   label_x = point_x - radius - label_width / 2.0
            #   label_y = point_y - 2 * radius
            #   if index.even?
            #     label_y = point_y + 2 * radius + label_height
            #   end
            #
            #   text_box text, at: [label_x, label_y], height: bar_height, width: label_width
            # end

            point_y -= additional_points
          end
        end
      end

      def values_height
        @values_height ||= bounds.height * (1 + 1 / values_length.to_f)
      end

      def first_y_point(_series_index=0)
        values_height + (bar_height + bar_space) - 1.5 * additional_points
      end

      def radius
        @radius ||= bar_height / 4.0
      end

      def additional_points
        @additional_points ||= bar_space + bar_height
      end

      def bar_height
        @bar_height ||= (values_height * ratio) / values_length.to_f
      end

      def bar_space
        @bar_space ||= (values_height * (1.0 - ratio)) / (values_length + 1).to_f
      end

      def values_length
        @values_length ||= series.map { |b| b[:values].count }.max
      end
    end
  end
end

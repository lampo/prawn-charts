module Prawn
  module Charts
    class StackedBar < Bar

      def plot_values
        stacked_bar_values.each_with_index do |stack,index|
          point_x = first_x_point(index)

          point_y = bounds.bottom
          stack[:values].each do |h|
            fill_color h[:color]
            fill do
              percentage = h[:value].to_f / stack[:total].to_f
              height = bounds.height * percentage
              point_y += height
              rectangle [point_x,point_y], bar_width, height
            end
          end
        end
      end

      def percentage
        true
      end

      def x_points
        points = []
        stacked_bar_values.each_with_index do |stack,index|
          points << first_x_point(index) + (bar_width / 2)
        end
        points
      end

      def series_length
        series.map { |v| v[:values].length }.max
      end

      def max_value
        100
      end

      def min_value
        0
      end


    end
  end
end

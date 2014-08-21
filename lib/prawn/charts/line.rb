module Prawn
  module Charts

    class Line < StackedBar

      def plot_values
        return if series.nil?
        series.each_with_index do |bar,index|
          point_x = first_x

          points = bar[:values].map do |h|
            height = value_height(h[:value])
            point = [point_x,height]

            fill_color bar[:color]
            fill_ellipse point, 2
            point_x += addition_x

            point
          end

          stroke_color bar[:color]
          stroke do
            last_point = points.first
            points.each do |point|
              line last_point, point
              last_point = point
            end
          end

        end
      end

      def first_x
        (bar_width / 2) + bar_space
      end

      def addition_x
        bar_width + bar_space
      end
    end
  end
end

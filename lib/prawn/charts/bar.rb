module Prawn
  module Charts
    class Bar < Base
      attr_accessor :ratio

      def initialize pdf, opts = {}
        super pdf, opts
        @ratio = opts[:ratio] || 0.75
      end

      def plot_values
        return if series.nil?
        series.each_with_index do |bar,index|
          point_x = first_x_point index

          bar[:values].each do |h|
            fill_color bar[:color]
            fill do
              height = value_height(h[:value])
              rectangle [point_x,height], bar_width, height
            end
            point_x += additional_points
          end

        end
      end

      def first_x_point index
        (bar_width * index) + (bar_space * (index + 1))
      end

      def additional_points
        (bar_space + bar_width) * series.count
      end

      def x_points
        points = nil
        series.each_with_index do |bar,index|
          tmp = []

          tmp << first_x_point(index) + (bar_width / 2)

          bar[:values].each do |h|
            tmp << tmp.last + additional_points
          end

          points ||= [0] * tmp.length

          tmp.each_with_index do |point, i|
            points[i] += point
          end
        end

        points.map do |point|
          (point / series.count).to_i
        end
      end

      def bar_width
        @bar_width ||= (bounds.width * ratio) / series_length.to_f
      end

      def bar_space
        @bar_space ||= (bounds.width * (1.0 - ratio)) / (series_length + 1).to_f
      end

      def series_length
        series.map { |v| v[:values].length }.max * series.count
      end

      def value_height val
        bounds.height * ((val - min_value) / series_height.to_f)
      end

    end
  end
end

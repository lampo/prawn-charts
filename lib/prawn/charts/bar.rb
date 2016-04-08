module Prawn
  module Charts
    class Bar < VerticalBase
      attr_accessor :ratio

      def initialize pdf, opts = {}
        super pdf, opts
        @ratio = opts[:ratio] || 0.75
      end

      def plot_values
        return if series.nil?
        series.each_with_index do |bar,index|
          point_x = first_x_point index

          bar[:values].each_with_index do |h, i|
            height = value_height(h[:value])
            if bar[:colors]
              color = bar[:colors][i]
            end
            color ||= bar[:color]
            with_color color do
              fill do
                rectangle [point_x,height], bar_width, height
              end
            end
            with_smaller_font do
              text_box value_formatter.call(h[:value]), at: [point_x, height + 10], width: bar_width, align: :center
            end
            point_x += additional_points
          end

        end
      end

      def with_smaller_font val = 3
        original_font = @pdf.font_size
        @pdf.font_size -= val
        yield
        @pdf.font_size = original_font
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

      def value_height val
        scale_factor = 
          if val == 0
            0.01
          elsif percentage
            val * 0.01
          else
            (val - min_value) / series_span.to_f
          end
        scale_factor * bounds.height
      end

    end
  end
end

module Prawn
  module Charts
    class XAxis < Axis
      def initialize pdf, opts
        super(pdf, opts)
      end

      def draw_series
        with_font do
          bounding_box at, width: width, height: height do
            index = 0
            slice =
              if label_count_width < series_labels.count
                (series_labels.count.to_f / label_count_width.to_f).floor
              else
                1
              end

            series_labels.each_slice(slice) do |items|
              offset = (max_label_width) / 2
              origin = [(points[index] - offset).to_i, 0]
              point = [origin.first, 0]
              text_box items.first.to_s, at: point, width: max_label_width, height: label_height, align: :center
              index += slice
            end
          end
        end
        stroke_horizontal_line 0, bounds.width, at: 0
      end

      def draw_values
        with_font do
          bounding_box at, width: width, height: height do
            axis_value_labels.each do |val, item|
              percent =
                if item.is_a? String
                  val / axis_width.to_f
                else
                  ((item - points.min).to_f / (axis_width).to_f)
                end
              x_point = (percent * (width - 10)) - (max_label_width / 2.0)

              text_box formatter.call(item), at: [x_point, 10], width: max_label_width, height: label_height, align: :center
            end
          end
        end

        stroke_horizontal_line 0, bounds.width, at: 0
      end

      def axis_width
        if only_zero? || percentage?
          100
        else
          points.max - points.min
        end
      end

      def label_height
        height_of("0") * 10 # arbitrarily long, any extra space is transparent
      end

      def label_count_width
        (bounds.width / max_label_width).to_i
      end
    end
  end
end

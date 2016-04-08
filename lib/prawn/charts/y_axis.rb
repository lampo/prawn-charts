module Prawn
  module Charts
    class YAxis < Axis
      def initialize pdf, opts
        super(pdf, opts)
      end

      def draw_series
        with_font do
          bounding_box at, width: width, height: height do
            index = 0
            slice =
              if label_count_height < series_labels.count
                (series_labels.count.to_f / label_count_height.to_f).floor
              else
                1
              end


            series_labels.each_slice(slice) do |items|
              offset = (max_label_height) / 2
              origin = points[index] - offset
              point = [0, origin]
              text_box items.first.to_s, at: point, width: label_width, height: label_height, align: :right
              index += slice
            end
          end
        end
        stroke_vertical_line(0, bounds.top + (label_height / 2), at: 0)
      end

      def draw_values
        with_font do
          bounding_box at, width: width, height: height do
            axis_value_labels.each do |val, item|
              percent =
                if item.is_a? String
                  val / axis_height.to_f
                else
                  ((item - points.min).to_f / (axis_height).to_f)
                end
              y_point = (percent * bounds.height)

              if y_point < 0
                y_point = label_height
              else
                y_point += 5
              end

              text_box formatter.call(item), at: [0, y_point], width: label_width, height: label_height, align: :right
            end
          end
        end
        stroke_vertical_line(0, bounds.top + (label_height / 2), at: 0)
      end

      def axis_height
        if only_zero?
          100
        else
          points.max - points.min
        end
      end

      def max_label_height
        ratio * full_label_height
      end

      def full_label_height
        height / series_length.to_f
      end

      def label_count_height
        (bounds.height / max_label_height).to_i
      end
    end
  end
end

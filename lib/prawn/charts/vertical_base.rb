module Prawn
  module Charts

    # Prawn::Charts::VerticalBase will handle most of the common activities that any
    # vertical chart (series along x, values on y) will require.
    class VerticalBase < Base
      def draw
        with_color do
          bounding_box at, width: width, height: height do

            with_larger_font { draw_title } if config[:title].present?
            draw_legend if config[:legend].present?

            bounding_box(chart_at, width: chart_width, height: chart_height) do

              draw_x_axis  if x[:display]
              draw_y_axis  if y[:display]
              draw_y1_axis if y1[:display]

              plot_values
            end

          end
        end
      end

      def draw_x_axis
        opts = {
          series: series,
          at: [0,0],
          width:  bounds.width,
          height: x_axis_height,
          points: x_points,
          formatter: key_formatter,
          orientation: x_orientation,
          max_label_width: max_label_width,
        }

        Prawn::Charts::XAxis.new(pdf, opts).draw

        with_smaller_font do
          opts ={ width: bounds.width, height: height_of(x[:title]) }
          bounding_box( [bounds.left, (-x_axis_height - height_of(x[:title]) / 2)], opts ) do
            text x[:title], align: :center
          end
        end
      end

      def draw_y_axis
        opts = {
          series: series,
          at: [-y_axis_width, bounds.height],
          width: y_axis_width,
          height: bounds.height,
          points: y_points,
          formatter: value_formatter,
          percentage: percentage,
          only_zero: only_zero?,
          axis_value_labels: axis_value_labels,
          orientation: y_orientation,
          max_label_width: max_label_width,
        }

        Prawn::Charts::YAxis.new(pdf, opts).draw

        with_smaller_font do
          mid = (bounds.height - width_of(y[:title])) / 2
          draw_text y[:title], { at: [(-y_axis_width - 1), mid ], rotate: 90 }
        end
      end

      def draw_y1_axis
        opts = {
          series:     series,
          at:         [bounds.right, bounds.height],
          width:      y_axis_width,
          height:     bounds.height,
          points:     y_points,
          formatter:  value_formatter,
          only_zero: only_zero?,
          orientation: y_orientation,
          max_label_width: max_label_width,
        }

        Prawn::Charts::YAxis.new(pdf, opts).draw

        with_smaller_font do
          mid = bounds.height - width_of(y1[:title])
          draw_text y[:title], { at: [bounds.right + y_axis_width + 1, mid ], rotate: 270 }
        end

      end

      def x_orientation
        :series
      end

      def y_orientation
        :values
      end

      def x_axis_height
        @x_axis_height ||= series.map do |s|
          s[:values].map{ |v| height_of(key_formatter.call(v[:key]))}.max
        end.max
      end

      def y_axis_width
        @y_axis_width ||=
          begin
            if percentage || only_zero?
              vals = [ { values: [
                { value: 0 },
                { value: 25 },
                { value: 50 },
                { value: 75 },
                { value: 100 }
              ] } ]
            else
              vals = series
            end

            if percentage
              width_of('100%')
            else
              vals.map do |s|
                s[:values].map do |v|
                  width_of(value_formatter.call(v[:value]))
                end.max
              end.max
            end
          end
      end

      def y_points
        [min_value, max_value]
      end

      alias_method :series_points, :x_points
      alias_method :value_points, :y_points

      def stacked_bar_values
        keys.map do |key|
          items = for_key(key)
          {
            key:     key,
            values:  items,
            total:   items.inject(0){ |s,v| s + v[:value] }
          }
        end
      end
    end
  end
end

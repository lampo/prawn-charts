module Prawn
  module Charts

    # Prawn::Charts::Base will handle most of the common activities that any
    # chart will require.  It also will call the drawing functions for each of
    # the types of charts.
    class Base
      attr_reader :pdf, :config

      extend Forwardable

      def_delegators :@pdf, :bounding_box, :bounds
      def_delegators :@pdf, :draw_text, :pad, :text, :text_box
      def_delegators :@pdf, :stroke_axis, :rotate, :stroke_bounds
      def_delegators :@pdf, :height_of, :width_of
      def_delegators :@pdf, :fill, :fill_color
      def_delegators :@pdf, :circle, :rectangle, :stroke_color, :line, :stroke, :line_width
      def_delegators :@pdf, :stroke_horizontal_line, :stroke_vertical_line
      def_delegators :@pdf, :fill_ellipse, :curve

      #
      # @param pdf [Prawn::Document] and instance of the prawn document
      # @param opts [Hash]
      # @option opts :title [String]
      # @option opts :at [Array<x,y>]
      # @option opts :width [Fixnum] (500)
      # @option opts :height [Fixnum] (200)
      # @option opts :percentage [Boolean] (false)
      # @option opts :x  [Hash] ({title: 'X Axis', display: false })
      # @option opts :y  [Hash] ({title: 'Y Axis', display: false})
      # @option opts :y1 [Hash] ({title: 'Y1 Axis', display: false})
      # @option opts :key_formatter   [Proc] lambda{|key| key.to_s },
      # @option opts :value_formatter [Proc] lambda{|value| value.to_s},
      # @option opts :series [Array<Hash>] [
      #     {
      #       name:             'Red',
      #       color:            'FF00',
      #       values:           [{ key: , value: }]
      #     },
      #     {
      #       name:             'Blue',
      #       color:            '1F1F',
      #       values:           [{ key: , value: }]
      #     }]
      # }
      def initialize pdf, opts = {}

        @pdf    = pdf
        opts    = defaults.merge(opts)
        @config = OpenStruct.new defaults.merge(opts)
        @config.each_pair.each do |key, val|
          unless respond_to? key
            define_singleton_method key.to_s, &@config.method(key)
          end
        end

      end

      def defaults
        {
          title: '',
          padding:  {
            bottom:  0,
            left:    30,
            right:   30,
            top:     100,
          },
          at:      [bounds.left, bounds.top],
          width:   bounds.width,
          height:  bounds.height,
          percentage: false,
          value_labels: [],
          x:  { display: false },
          y:  { display: false },
          y1: { display: false },
          key_formatter:    lambda{ |key| key.to_s },
          value_formatter:  lambda{ |value| value.to_s }
        }
      end

      def with_color(color = nil)
        original_fill_color   = @pdf.fill_color
        original_stroke_color = @pdf.stroke_color
        if color
          fill_color color
          stroke_color color
        end
        yield
        @pdf.fill_color   = original_fill_color
        @pdf.stroke_color = original_stroke_color
      end

      def with_smaller_font val = 3
        original_font = @pdf.font_size
        @pdf.font_size -= val
        yield
        @pdf.font_size = original_font
      end

      def with_larger_font val = 3
        original_font = @pdf.font_size
        @pdf.font_size += val
        yield
        @pdf.font_size = original_font
      end

      def draw
      end

      def padding_top_bottom
        padding[:top] + padding[:bottom]
      end

      def padding_left_right
        padding[:left] + padding[:right] + y_axis_width + 10
      end

      def chart_at
        [ padding[:left] + y_axis_width, bounds.top - (padding_top_bottom / 2) ]
      end

      def chart_width
        bounds.width - padding_left_right
      end

      def chart_height
        bounds.height - title_height - legend_height - (x_axis_height * 2)
      end

      def draw_title
        opts ={ width: bounds.width, height: height_of(title.to_s) }
        bounding_box( [bounds.left, bounds.top - 1 ], opts ) do
          text title, align: :center
        end
      end

      def legend_at
        [chart_at.first, bounds.top - height_of(series.first[:name].to_s) - 5]
      end

      def legend_height
        ( legend_at.last - chart_at.last )
      end

      def draw_legend
        opts = {
          at: legend_at,
          width:chart_width,
          height: legend_height,
          series: series,
          left: y1[:display]

        }
        Prawn::Charts::Legend.new(pdf, opts).draw
      end

      def title_height
        val = 0
        with_larger_font do
          val = height_of(title.to_s)
        end
        val
      end

      def plot_values
      end

      def x_points
      end

      def y_points
      end

      def values
        @values ||= series.map{ |bar| bar[:values].map{|single| single[:value] }}.flatten
      end

      def keys
        @keys ||= series.map{ |v| v[:values].map{|k| k[:key] }}.flatten.uniq
      end

      def exp n, offset = 0
        if n <= 0
          1
        else
          10 ** (Math.log10(n).floor) - offset
        end
      end

      def present_values
        values.compact
      end

      def max_value
        return 100 if percentage
        return value_labels[-1][0] if value_labels && value_labels.count > 0
        increment = exp(step_value) * 2
        mvalue = present_values.max
        mvalue + increment
      end

      def step_value
        n = (present_values.min - delta_value * 0.1).to_i
        n - (n % exp(n)) - exp(n)
      end

      def min_value
        # Original code, probably needs config to enable
        # n = (present_values.min - delta_value * 0.1).to_i
        # n - (n % exp(n)) - exp(n)
        0
      end

      def delta_value
        present_values.max - present_values.min
      end

      def series_span
        max_value - min_value
      end

      def series_length
        series.map { |v| v[:values].length }.max * series.count
      end

      def only_zero?
        @zero ||= present_values.all?(&:zero?)
      end

      def percentage_list
        [0, 25, 50, 75, 100].zip([0, 25, 50, 75, 100])
      end

      def for_key key
        series.map do |v|
          {
            name: v[:name],
            color: v[:color],
            value: v[:values].detect{|k| k[:key] == key }[:value]
          }
        end
      end

      def max_label_width
        if x_orientation == :values
          if axis_value_labels[0][1].is_a? String
            width / (axis_value_labels[-1][0].to_f) + 5
          else
            width / (axis_value_labels.count - 1.0) + 5
          end
        else
          ratio * full_label_width
        end
      end

      def full_label_width
        bounds.width / series_length.to_f
      end

      def axis_value_labels(zero_base = true)
        return percentage_list if percentage || only_zero?
        return @config.value_labels if @config.value_labels
        @value_labels ||= begin
          labels = []

          max_point_value = value_points.max.to_f
          min_point_value = value_points.min.to_f

          min_val = exp(max_point_value / 4)
          first_value =
            if zero_base || min_point_value.zero?
              0.0
            else
              min_point_value - (min_point_value % min_val) - min_val
            end
          labels.push(first_value)

          point_range = max_point_value.to_i - min_point_value.to_i
          stride = point_range/6.0
          n = min_point_value

          while n < max_point_value
            val = n == 0 ? 1 : n
            result = val - (val % min_val) - min_val
            if result > min_point_value
              labels.push(result)
            end
            n += stride
          end

          val = max_point_value.to_f
          result = val - (val % min_val) - min_val
          labels.push(result)
          labels.uniq!

          labels.zip(labels)
        end
      end
    end
  end
end

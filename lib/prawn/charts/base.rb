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
      def_delegators :@pdf, :rectangle, :stroke_color, :line, :stroke, :line_width
      def_delegators :@pdf, :fill_ellipse, :curve

      #
      # @param pdf [Prawn::Document] and instance of the prawn document
      # @param opts [Hash]
      # @option opts :title [String]
      # @option opts :at [Array<x,y>]
      # @option opts :width [Fixnum] (500)
      # @option opts :height [Fixnum] (200)
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
          define_singleton_method key.to_s, &@config.method(key)
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
          x:  { display: false },
          y:  { display: false },
          y1: { display: false },
          key_formatter:    lambda{ |key| key.to_s },
          value_formatter:  lambda{ |value| value.to_s }
        }
      end

      def with_color color = '000000'
        original_fill_color   = @pdf.fill_color
        original_stroke_color = @pdf.stroke_color
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

      def padding_top_bottom
        padding[:top] + padding[:bottom]
      end

      def padding_left_right
        padding[:left] + padding[:right] + y_axis_width - 10
      end

      def chart_at
        [ bounds.left + (padding_left_right / 2), bounds.top - (padding_top_bottom / 2) ]
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

      def x_axis_height
        @x_axis_height ||= series.map do |s|
          s[:values].map{ |v| height_of(key_formatter.call(v[:key]))}.max
        end.max
      end

      def draw_x_axis

        opts = {
          series:  series,
          at:      [0,0],
          width:   bounds.width,
          height:  x_axis_height,
          points:  x_points,
          formatter: key_formatter
        }

        Prawn::Charts::XAxis.new(pdf, opts).draw

        with_smaller_font do
          opts ={ width: bounds.width, height: height_of(x[:title]) }
          bounding_box( [bounds.left, (-x_axis_height - height_of(x[:title]) / 2)], opts ) do
            text x[:title], align: :center
          end
        end
      end

      def title_height
        val = 0
        with_larger_font do
          val = height_of(title.to_s)
        end
        val
      end

      def y_axis_width
        @y_axis_width ||= begin
                            txt = series.map do |s|
                              s[:values].map do |v|
                                width_of(value_formatter.call(v[:value]))
                              end.max
                            end.max

                            txt = width_of('100%') if percentage
                            txt
                          end
      end

      def draw_y_axis

        opts = {
          at:         [-y_axis_width, bounds.height],
          width:      y_axis_width,
          height:     bounds.height,
          points:     [min_value, max_value],
          formatter:  value_formatter,
          percentage: percentage
        }

        Prawn::Charts::YAxis.new(pdf, opts).draw

        with_smaller_font do
          mid = (bounds.height - width_of(y[:title])) / 2
          draw_text y[:title], { at: [(-y_axis_width - 1), mid ], rotate: 90 }
        end

      end

      def draw_y1_axis
        opts = {
          at:         [bounds.right, bounds.height],
          width:      y_axis_width,
          height:     bounds.height,
          points:     [min_value, max_value],
          formatter:  value_formatter
        }

        Prawn::Charts::YAxis.new(pdf, opts).draw

        with_smaller_font do
          mid = bounds.height - width_of(y1[:title])
          draw_text y[:title], { at: [bounds.right + y_axis_width + 1, mid ], rotate: 270 }
        end

      end


      def plot_values
      end

      def x_points
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

      def max_value
        increment = exp(min_value) * 2
        mvalue = values.max

        (min_value..(mvalue + increment )).detect do |sample|
          sample >= mvalue + increment
        end || (mvalue + increment)
      end

      def min_value
        n = (values.min - delta_value * 0.1).to_i
        n - (n % exp(n)) - exp(n)
      end

      def delta_value
        values.max - values.min
      end

      def series_height
        max_value - min_value
      end

      def percentage
        false
      end

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


      def for_key key
        series.map do |v|
          {
            name: v[:name],
            color: v[:color],
            value: v[:values].detect{|k| k[:key] == key }[:value]
          }
        end
      end

    end
  end
end

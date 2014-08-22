module Prawn
  module Charts
    class XAxis
      attr_reader :pdf
      attr_accessor :series, :at, :width, :height, :formatter

      extend Forwardable

      def_delegators :@pdf, :bounding_box, :stroke_bounds, :text
      def_delegators :@pdf, :height_of, :width_of, :fill_color
      def_delegators :@pdf, :draw_text, :bounds, :rotate

      def initialize pdf, opts
        @pdf       = pdf
        @series    = opts[:series]
        @at        = opts[:at]
        @width     = opts[:width]
        @height    = opts[:height]
        @points    = opts[:points]
        @formatter = opts[:formatter]
      end

      def draw
        bounding_box at, width: width, height: height do
          index = 0
          slice = if label_count_width < labels.count
                    (labels.count.to_f / label_count_width.to_f).ceil
                  else
                    1
                  end

          labels.each_slice(slice) do |items|
            offset = width_of(items.first) / 2
            origin = [(@points[index] - offset).to_i,0]
            point = [origin.first,0]
            draw_text items.first, at: point
            index += slice
          end
        end
      end

      def labels
        @labels ||= series.map do |s|
          s[:values].map do |v|
            formatter.call(v[:key])
          end.uniq
        end.flatten.uniq
      end

      def max_label_width
        @max_label_width ||= labels.map { |label| width_of(label) }.max
      end


      def label_count_width
        (bounds.width / max_label_width).to_i
      end
    end
  end
end

module Prawn
  module Charts

    class Legend

      attr_reader :at, :width, :height, :bar_height

      extend Forwardable

      def_delegators :@pdf, :bounding_box, :bounds
      def_delegators :@pdf, :draw_text, :pad, :text, :text_box
      def_delegators :@pdf, :stroke_axis, :stroke_bounds
      def_delegators :@pdf, :height_of, :width_of
      def_delegators :@pdf, :fill_rectangle, :fill_color

      def initialize pdf, opts
        @pdf       = pdf
        @at        = opts[:at]
        @width     = opts[:width]
        @height    = opts[:height]
        @series    = opts[:series]
        @formatter = opts[:formatter]
        @left      = opts[:left]
        @bar_height = 3
      end


      def draw
        bounding_box at, width: width, height: height do
          with_font do
            enum = @series.each
            label_coordinates.each do |point|
              with_color do


                begin
                  item = enum.next
                  w =  width_of(item[:name]) + side
                  rec_point = [point.first, point.last - label_height]
                  bounding_box point,height: label_height, width: w  do
                    text item[:name], align: :center
                  end
                  fill_color item[:color]
                  fill_rectangle rec_point, w, bar_height
                rescue StopIteration
                end
              end
            end
          end
        end
      end

      def with_color color = '000000'
        original_fill_color   = @pdf.fill_color
        original_stroke_color = @pdf.stroke_color
        yield
        @pdf.fill_color   = original_fill_color
        @pdf.stroke_color = original_stroke_color
      end

      def with_font
        original_font = @pdf.font_size
        @pdf.font_size -= 3
        yield
        @pdf.font_size = original_font
      end

      def label_coordinates
        return @corrinates unless @corrinates.nil?
        @corrinates = []

        last_width = 0
        x,y =0,height
        @series.each_with_index do |item,index|
          x = last_width
          w = width_of(item[:name]) + side
          x = (bounds.right - w - last_width) if @left

          if x + w > bounds.width
            x = 0
            last_width = 0
            y -= (label_height + bar_height + 2)
          end

          @corrinates.push [x,y]

          last_width += w
        end

        @corrinates
      end

      def standard_width
        label_width + side
      end

      def label_height
        @label_height ||= @series.map{|item| height_of(item[:name]) }.max
      end
      alias_method :side, :label_height


      def label_width
        @label_width ||= @series.map{|item| width_of(item[:name]) }.max
      end

    end
  end
end


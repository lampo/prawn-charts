module Prawn
  module Charts

    class Legend

      attr_reader :at, :width, :height

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
      end


      def draw
        bounding_box at, width: width, height: height do
          enum = @series.each
          label_coordinates.each do |point|
            with_color do

              begin
                item = enum.next
                rec_point = [point.first, point.last - label_height + 2]
                bounding_box point,height: label_height, width: standard_width do
                  text item[:name], align: :center
                end
                fill_color item[:color]
                fill_rectangle rec_point, standard_width, 3
              rescue StopIteration
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

      def label_coordinates
        return @corrinates unless @corrinates.nil?
        horz_count = (width.to_f / standard_width.to_f).ceil
        vert_count = (height.to_f / label_height.to_f).ceil
        @corrinates = []
        vert_count.times do |y|
          horz_count.times do |x|
            x_corr= x * standard_width
            x_corr = bounds.right - ((x+1) * standard_width) if @left
            @corrinates.push [x_corr,(y * (label_height)) + bounds.height]
          end
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


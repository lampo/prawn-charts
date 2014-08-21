module Prawn
  module Charts

    class Combo

      def initialize pdf, opts = {}
        @pdf        = pdf
        @line_chart = opts[:line_chart]
        @bar_chart  = opts[:bar_chart]
      end

      def draw
        Prawn::Charts::Bar.new( @pdf,  @bar_chart ).draw
        Prawn::Charts::Line.new(@pdf, @line_chart ).draw
      end

    end
  end
end

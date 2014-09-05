module Prawn
  module Charts

    class Combo

      attr_reader :line_chart, :bar_chart

      def initialize pdf, opts = {}
        @pdf        = pdf
        @bar_chart = Prawn::Charts::Bar.new( @pdf,  opts[:bar_chart] )
        @line_chart = Prawn::Charts::Line.new(@pdf, opts[:line_chart] )
      end

      def draw
        bar_chart.draw
        line_chart.draw
      end

    end
  end
end

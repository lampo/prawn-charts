module Prawn
  class Charts::Combo

    def initialize pdf, opts = {}
      @pdf = pdf
      @line_chart = opts[:line_chart]
      @bar_chart  = opts[:bar_chart]
    end

    def draw
      @bar_chart.merge!({ y1: nil })
      @line_chart.merge!({ x: nil, y: nil, title: nil })
      Prawn::Charts::Bar.new( @pdf,  @bar_chart ).draw
      Prawn::Charts::Line.new(@pdf, @line_chart ).draw
    end
  end
end

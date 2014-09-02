module Prawn
  module Charts
    NoChartData        = Class.new StandardError
    MalformedSeries    = Class.new StandardError
    MalformedAxis      = Class.new StandardError
    NoPlotValuesMethod = Class.new StandardError
  end
end

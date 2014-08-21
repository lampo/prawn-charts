require "prawn/charts/version"
#require File.dirname(__FILE__) + '/charts/errors'
require File.dirname(__FILE__) + '/charts/base'
#require File.dirname(__FILE__) + '/charts/grid'
require File.dirname(__FILE__) + '/charts/bar'
require File.dirname(__FILE__) + '/charts/stacked_bar'
require File.dirname(__FILE__) + '/charts/line'
require File.dirname(__FILE__) + '/charts/combo'
#require File.dirname(__FILE__) + '/charts/themes'
require File.dirname(__FILE__) + '/charts/x_axis'
require File.dirname(__FILE__) + '/charts/y_axis'

module Prawn
  class Document

    def bar_chart opts={}, &block
      chart = Prawn::Charts::Bar.new(self, opts)
      yield chart if block_given?
      chart.draw
    end

    def stacked_bar_chart opts={}, &block
      chart = Prawn::Charts::StackedBar.new(self, opts)
      yield chart if block_given?
      chart.draw
    end

    def line_chart opts={}, &block
      chart = Prawn::Charts::Line.new(self, opts)
      yield chart if block_given?
      chart.draw
    end

    def combo_chart opts={}, &block
      chart = Prawn::Charts::Combo.new(self, opts)
      yield chart if block_given?
      chart.draw
    end
  end
end

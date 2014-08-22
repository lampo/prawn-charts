require "prawn/charts/version"
require "ostruct"
require 'i18n'
require File.dirname(__FILE__) + '/charts/error'
require File.dirname(__FILE__) + '/charts/error/no_series'
require File.dirname(__FILE__) + '/charts/base'
require File.dirname(__FILE__) + '/charts/bar'
require File.dirname(__FILE__) + '/charts/stacked_bar'
require File.dirname(__FILE__) + '/charts/line'
require File.dirname(__FILE__) + '/charts/combo'
require File.dirname(__FILE__) + '/charts/x_axis'
require File.dirname(__FILE__) + '/charts/y_axis'

I18n.load_path << File.dirname(__FILE__) + '/../config/locales/en.yml'
I18n.enforce_available_locales = false
module Prawn
  class Document

    # Draws a bar chart.
    #
    #
    # @example
    #   1 + 1 = 2
    #
    # @param [Hash] opts ({}) the data and all options
    # @option opts [String] :title The Title on the Chart
    # @option opts [Boolean] :legend show legend
    # @option opts [Hash] :padding { top: bottom: left: right: }
    # @option opts [String] :x name of the x axis
    # @option opts [String] :y name of the y axis
    # @option opts [String] :y1 name of the y1 axis
    # @option opts [Array [x,y]] :at Top Left corner of bounding box
    # @option opts [Fixnum] :width width of chart
    # @option opts [Fixnum] :height height of chart
    # @option opts [Hash] :series all the data
    # @option opts [Proc] :key_formatter formatter for the X values
    # @option opts [Proc] :value_formatter formatter for the Y values
    #
    # @yieldparam [Prawn::Charts::Bar#config]
    #
    # @return [Prawn::Charts::Bar]
    def bar_chart opts={}, &block
      chart = Prawn::Charts::Bar.new(self, opts)
      yield chart.config if block_given?
      chart.draw
    end

    # Draws a stacked bar chart
    #
    # @example
    #   1 + 1 = 2
    #
    # @param [Hash] opts ({}) the data and all options
    # @option opts [String] :title The Title on the Chart
    # @option opts [Boolean] :legend show legend
    # @option opts [Hash] :padding { top: bottom: left: right: }
    # @option opts [String] :x name of the x axis
    # @option opts [String] :y name of the y axis
    # @option opts [String] :y1 name of the y1 axis
    # @option opts [Array [x,y]] :at Top Left corner of bounding box
    # @option opts [Fixnum] :width width of chart
    # @option opts [Fixnum] :height height of chart
    # @option opts [Hash] :series all the data
    # @option opts [Proc] :key_formatter formatter for the X values
    # @option opts [Proc] :value_formatter formatter for the Y values
    #
    # @yieldparam [Prawn::Charts::StackedBar#config]
    #
    # @return [Prawn::Charts::StackedBar]
    def stacked_bar_chart opts={}, &block
      chart = Prawn::Charts::StackedBar.new(self, opts)
      yield chart.config if block_given?
      chart.draw
    end

    # Draws a line chart
    #
    # @example
    #   1 + 1 = 2
    #
    # @param [Hash] opts ({}) the data and all options
    # @option opts [String] :title The Title on the Chart
    # @option opts [Boolean] :legend show legend
    # @option opts [Hash] :padding { top: bottom: left: right: }
    # @option opts [String] :x name of the x axis
    # @option opts [String] :y name of the y axis
    # @option opts [String] :y1 name of the y1 axis
    # @option opts [Array [x,y]] :at Top Left corner of bounding box
    # @option opts [Fixnum] :width width of chart
    # @option opts [Fixnum] :height height of chart
    # @option opts [Hash] :series all the data
    # @option opts [Proc] :key_formatter formatter for the X values
    # @option opts [Proc] :value_formatter formatter for the Y values
    #
    # @yieldparam [Prawn::Charts::Line#config]
    #
    # @return [Prawn::Charts::Line]
    def line_chart opts={}, &block
      chart = Prawn::Charts::Line.new(self, opts)
      yield chart.config if block_given?
      chart.draw
    end

    # Draws a combo of other charts.  Currently it will draw
    # a combo of a bar chart and a line chart
    #
    # @example
    #   1 + 1 = 2
    #
    # @param [Hash] opts ({}) the data and all options
    # @option opts [String] :title The Title on the Chart
    # @option opts [Boolean] :legend show legend
    # @option opts [Hash] :padding { top: bottom: left: right: }
    # @option opts [String] :x name of the x axis
    # @option opts [String] :y name of the y axis
    # @option opts [String] :y1 name of the y1 axis
    # @option opts [Array [x,y]] :at Top Left corner of bounding box
    # @option opts [Fixnum] :width width of chart
    # @option opts [Fixnum] :height height of chart
    # @option opts [Hash] :series all the data
    # @option opts [Proc] :key_formatter formatter for the X values
    # @option opts [Proc] :value_formatter formatter for the Y values
    #
    # @yieldparam [Prawn::Charts::Combo]
    #
    # @return [Prawn::Charts::Combo]
    def combo_chart opts={}, &block
      chart = Prawn::Charts::Combo.new(self, opts)
      #yield chart if block_given?
      chart.draw
    end
  end
end

require 'prawn'
require 'date'
require_relative '../lib/prawn/charts'

Prawn::Document.generate('chart.pdf') do
  red   = []
  green = []
  blue  = []

  5.times do |i|
    red.push(   { key: i, value: rand(780) + 750 })
    green.push( { key: i, value: rand(780) + 750 })
    blue.push(  { key: i, value: rand(780) + 750 })
  end

  opts = {
    title: 'Bar',
    at: [bounds.left + 20, bounds.top],
    width: 500,
    height: 200,
    x: {title: 'X Axis'},
    y: {title: 'Y Axis'},
    y1: {title: 'Y1 Axis'},
    key_formatter:    lambda{|key| (Date.today >> key).strftime('%b %Y')},
    value_formatter:  lambda{|value| value.to_s},
    series: [
      {
        name:             'Red',
        color:            'FF00',
        value_formatter:  lambda{|value| value.to_s},
        values:           red
      },
      {
        name:             'Green',
        color:            '0000',
        value_formatter:  lambda{|value| value.to_s},
        values:           green
      },
      {
        name:             'Blue',
        color:            '1F1F',
        value_formatter:  lambda{|value| value.to_s},
        values:           blue
      }
    ]
  }

  bar_chart(opts) do |config|
    config.title = 'Bar'
  end

  start_new_page
  stacked_bar_chart(opts) do |config|
    config.title = 'Stacked Bar'
  end

  start_new_page
  line_chart(opts) do |config|
    config.title = 'Line Chart'
  end

  start_new_page

  line_opts = opts.merge({
    series: [
      {
        name:             'Red',
        color:            'FF00',
        key_formatter:    lambda{|key| 'Red ' * key},
        value_formatter:  lambda{|value| value.to_s},
        values:           red
      },
    ]
  })

  bar_opts = opts.merge({
    title: 'Combo Chart',
    series: [
      {
        name:             'BLUE',
        color:            '12AA',
        key_formatter:    lambda{|key| key.to_s},
        value_formatter:  lambda{|value| value.to_s},
        values:           blue
      },
    ]
  })
  combo_chart(line_chart: line_opts, bar_chart: bar_opts)
end

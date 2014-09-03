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
    title:   'Bar',
    at:      [bounds.left + 20, bounds.top],
    width:   500,
    height:  200,
    x: {title: 'X Axis', display: true},
    y: {title: 'Y Axis', display: true},
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
        color:            '1BB2',
        value_formatter:  lambda{|value| value.to_s},
        values:           blue
      }
    ] * 4
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
    title: nil,
    x: {title: 'X Axis', display: false},
    y: {title: 'Y Axis', display: false},
    y1: {title: 'Y1 Axis', display: true},
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
    x: {title: 'X Axis', display: true},
    y: {title: 'Y Axis', display: true},
    series: [
      {
        name:             'Blue',
        color:            'A33A',
        key_formatter:    lambda{|key| key.to_s},
        value_formatter:  lambda{|value| value.to_s},
        values:           blue
      },
    ]
  })
  combo_chart(line_chart: line_opts, bar_chart: bar_opts)
end

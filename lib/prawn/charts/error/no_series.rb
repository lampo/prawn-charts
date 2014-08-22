module Prawn
  module Charts
    class NoSeries < Error

      def initialize chart_type, klass, opts
        super(
          compose_message(
            "no_series",
            {
              chart_type:       chart_type,
              klass:            klass,
              example_options:  "\n\n" + opts.merge(series).inspect
            }
          )
        )
      end


      private

      def series
        {
          series: [
            {
              name:             'Red',
              color:            'FF00',
              value_formatter:  "lambda{|value| value.to_s}",
              values:           [
                { key: 1, value: 100 },
                { key: 2, value: 220 },
                { key: 3, value: 330 },
                { key: 4, value: 403 }
              ]
            },
            {
              name:             'Green',
              color:            '0000',
              value_formatter:  "lambda{|value| value.to_s}",
              values:           [
                { key: 1, value: 140 },
                { key: 2, value: 120 },
                { key: 3, value: 330 },
                { key: 4, value: 300 }
              ]
            }
          ]
        }
      end

    end
  end
end

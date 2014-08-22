module Prawn
  module Charts
    # Modelled after Mongoid Errors
    # SOURCE: Mongoid creator of awesome error messages
    #  https://github.com/mongoid/mongoid/blob/master/lib/mongoid/errors/mongoid_error.rb
    class Error < StandardError

      BASE_KEY = 'prawn.charts.errors.messages'
      #
      # Compose the message.
      #
      # @example Create the message
      #   error.compose_message
      #
      # @return [ String ] The composed message.
      def compose_message(key, attributes)
        @problem = problem(key, attributes)
        @summary = summary(key, attributes)
        @resolution = resolution(key, attributes)

        "\n\nProblem:\n\n  #{@problem}"+
        "\n\nSummary:\n\n  #{@summary}"+
        "\n\nResolution:\n\n  #{@resolution} \n\n"
      end

      private

      # Given the key of the specific error and the options hash, translate the
      # message.
      #
      # @example Translate the message.
      #   error.translate("errors", :key => value)
      #
      # @param [ String ] key The key of the error in the locales.
      # @param [ Hash ] options The objects to pass to create the message.
      #
      # @return [ String ] A localized error message string.
      def translate(key, options)
        ::I18n.translate("#{BASE_KEY}.#{key}", options)
      end

      # Create the problem.
      #
      # @example Create the problem.
      #   error.problem("error", {})
      #
      # @param [ String, Symbol ] key The error key.
      # @param [ Hash ] attributes The attributes to interpolate.
      #
      # @return [ String ] The problem.
      def problem(key, attributes)
        translate("#{key}.message", attributes)
      end

      # Create the summary.
      #
      # @example Create the summary.
      #   error.summary("error", {})
      #
      # @param [ String, Symbol ] key The error key.
      # @param [ Hash ] attributes The attributes to interpolate.
      #
      # @return [ String ] The summary.
      def summary(key, attributes)
        translate("#{key}.summary", attributes)
      end

      # Create the resolution.
      #
      # @example Create the resolution.
      #   error.resolution("error", {})
      #
      # @param [ String, Symbol ] key The error key.
      # @param [ Hash ] attributes The attributes to interpolate.
      #
      # @return [ String ] The resolution.
      def resolution(key, attributes)
        translate("#{key}.resolution", attributes)
      end

    end
    #NoChartData        = Class.new StandardError
    #MalformedSeries    = Class.new StandardError
    #MalformedAxis      = Class.new StandardError
    #NoPlotValuesMethod = Class.new StandardError
  end
end

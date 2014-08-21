module Prawn
  class Charts::StackedBar < Charts::Bar

    def plot_values
      stacked_bar_values.each_with_index do |stack,index|
        point_x = first_x_point(index)

        point_y = bounds.bottom
        stack[:values].each do |h|
          fill_color h[:color]
          fill do
            percentage = h[:value].to_f / stack[:total].to_f
            height = bounds.height * percentage
            point_y += height
            rectangle [point_x,point_y], bar_width, height
          end
        end
      end
    end

    def x_points
      points = []
      stacked_bar_values.each_with_index do |stack,index|
        points << first_x_point(index) + (bar_width / 2)
      end
      points
    end

    def series_length
      series.map { |v| v[:values].length }.max
    end

    def stacked_bar_values
      keys.map do |key|
        items = for_key(key)
        {
          key: key,
          values: items,
          total: items.inject(0){ |s,v| s + v[:value] }
        }
      end
    end


    def keys
      @keys ||= series.map{ |v| v[:values].map{|k| k[:key] }}.flatten.uniq
    end

    def for_key key
      series.map do |v|
        {
          name: v[:name],
          color: v[:color],
          value: v[:values].detect{|k| k[:key] == key }[:value]
        }
      end
    end
  end
end

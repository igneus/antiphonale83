module Antiphonal
  # utility for working with weekdays
  class Weekdays
    SHORTCUTS = %w(d f2 f3 f4 f5 f6 s)

    def self.each
      SHORTCUTS.each {|s| yield Day.new(s) }
    end

    class Day
      def initialize(shortcut)
        @shortcut = shortcut
      end

      attr_reader :shortcut

      def latin
        case @shortcut
        when 'd'
          'dominica'
        when /^f[1-6]$/
          "feria #{Helpers.roman(@shortcut[1..-1].to_i)}"
        when 's'
          'sabbato' # the ablativ is usually used in titles
        else
          raise RuntimeError.new("Unknown weekday '#{@shortcut}'")
        end
      end
    end
  end
end

module Rouge
  module Formatters
    class HTMLGitlab < Rouge::Formatters::HTML
      tag 'html_gitlab'

      # Creates a new <tt>Rouge::Formatter::HTMLGitlab</tt> instance.
      #
      # [+tag+]     The tag (language) of the lexer used to generate the formatted tokens
      def initialize(tag: nil)
        @line_number = 1
        @tag = tag
      end

      def stream(tokens)
        is_first = true
        token_lines(tokens) do |line|
          yield "\n" unless is_first
          is_first = false

          yield %(<span id="LC#{@line_number}" class="line" lang="#{@tag}">)
          line.each { |token, value| yield span(token, value.chomp) }
          yield %(</span>)

          @line_number += 1
        end
      end
    end
  end
end

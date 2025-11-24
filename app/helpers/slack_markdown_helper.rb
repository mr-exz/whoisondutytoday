require 'kramdown'
require 'kramdown-parser-gfm'

module SlackMarkdownHelper
  class SlackMarkdownConverter < Kramdown::Converter::Base
    def convert(el)
      send("convert_#{el.type}", el)
    end

    def convert_root(el)
      el.children.map { |child| convert(child) }.join.strip
    end

    def convert_header(el)
      level = el.options[:level]
      text = inner_text(el)

      case level
      when 1
        "*#{text}*\n\n"
      when 2
        "*#{text}*\n"
      when 3, 4, 5, 6
        "*#{text}*\n"
      end
    end

    def convert_p(el)
      inner_text(el) + "\n\n"
    end

    def convert_strong(el)
      "*#{inner_text(el)}*"
    end

    def convert_em(el)
      "_#{inner_text(el)}_"
    end

    def convert_text(el)
      el.value
    end

    def convert_codeblock(el)
      lang = el.attr['class']&.sub('language-', '') || ''
      "```#{lang}\n#{el.value.chomp}```\n\n"
    end

    def convert_codespan(el)
      "`#{el.value}`"
    end

    def convert_a(el)
      url = el.attr['href']
      text = inner_text(el)
      "<#{url}|#{text}>"
    end

    def convert_ul(el)
      el.children.map { |li| convert_li(li, '•', '') }.join + "\n"
    end

    def convert_ol(el)
      el.children.map.with_index(1) { |li, i| convert_li(li, "#{i}.", '') }.join + "\n"
    end

    def convert_li(el, marker, indent)
      content = el.children.map do |child|
        case child.type
        when :ul
          "\n" + child.children.map { |nested_li| convert_li(nested_li, '◦', indent + '  ') }.join
        when :ol
          "\n" + child.children.map.with_index(1) { |nested_li, i| convert_li(nested_li, "#{i}.", indent + '  ') }.join
        when :p
          inner_text(child)
        else
          convert(child)
        end
      end.join

      "#{indent}#{marker} #{content.strip}\n"
    end

    def convert_blockquote(el)
      inner_text(el).lines.map { |line| "> #{line.chomp}\n" }.join + "\n"
    end

    def convert_hr(el)
      "---\n\n"
    end

    def convert_br(el)
      "\n"
    end

    def convert_blank(el)
      "\n"
    end

    def convert_smart_quote(el)
      el.value.to_s
    end

    def convert_typographic_sym(el)
      el.value.to_s
    end

    # Fallback for any unhandled elements
    def method_missing(method, *args)
      if method.to_s.start_with?('convert_')
        el = args.first
        inner_text(el)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      method.to_s.start_with?('convert_') || super
    end

    private

    def inner_text(el)
      el.children.map { |child| convert(child) }.join
    end
  end

  # Helper method to convert markdown text to Slack format
  def markdown_to_slack(markdown_text)
    doc = Kramdown::Document.new(markdown_text, input: 'GFM')
    converter = SlackMarkdownConverter.new
    converter.convert(doc.root)
  end
end

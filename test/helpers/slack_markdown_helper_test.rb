require "test_helper"

class SlackMarkdownHelperTest < ActiveSupport::TestCase
  include SlackMarkdownHelper

  test "converts markdown to slack format" do
    markdown = <<~MD
      # Main Title

      This is a paragraph with **bold text** and _italic text_.

      ## Subheading

      Here's a list:
      - Item 1
      - Item 2
      - Item 3

      And some code:
      ```ruby
      def hello
        puts "world"
      end
      ```

      Check out [this link](https://example.com).
    MD

    result = markdown_to_slack(markdown)

    # Verify key conversions
    assert_includes result, "*Main Title*"
    assert_includes result, "*bold text*"
    assert_includes result, "_italic text_"
    assert_includes result, "• Item 1"
    assert_includes result, "• Item 2"
    assert_includes result, "```ruby"
    assert_includes result, "<https://example.com|this link>"
  end
end

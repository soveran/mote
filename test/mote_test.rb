require File.expand_path("../lib/mote", File.dirname(__FILE__))

scope do
  test "assignment" do
    example = Mote.parse("<%= \"***\" %>")
    assert_equal "***", example.call
  end

  test "comment" do
    example = Mote.parse("*<%# \"*\" %>*")
    assert_equal "**", example.call
  end

  test "control flow" do
    example = Mote.parse("<% if false %>*<% else %>***<% end %>")
    assert_equal "***", example.call
  end

  test "block evaluation" do
    example = Mote.parse("<% 3.times { %>*<% } %>")
    assert_equal "***", example.call
  end

  test "parameters" do
    example = Mote.parse("<% params[:n].times { %>*<% } %>")
    assert_equal "***", example[:n => 3]
    assert_equal "****", example[:n => 4]
  end

  test "multiline" do
    example = Mote.parse("The\nMan\nAnd\n<%=\n\"The\"\n%>\nSea")
    assert_equal "The\nMan\nAnd\nThe\nSea", example[:n => 3]
  end
end

include Mote::Helpers

scope do
  test do
    assert_equal "1 2 3", mote("1 <%= 2 %> 3")
  end

  test do
    assert_equal "1 2 3", mote("1 <%= params[:n] %> 3", :n => 2)
  end

  test do
    assert_equal "***\n", mote_file("test/basic", :n => 3)
  end
end

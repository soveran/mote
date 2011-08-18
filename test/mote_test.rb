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

  test "quotes" do
    example = Mote.parse("'foo' 'bar' 'baz'")
    assert_equal "'foo' 'bar' 'baz'", example.call
  end

  test "context" do
    context = Object.new
    context.instance_variable_set(:@user, "Bruno")

    example = Mote.parse("<%= @user %>", context)
    assert_equal "Bruno", example.call
  end

  test "locals" do
    context = Object.new

    example = Mote.parse("<%= user %>", context, [:user])
    assert_equal "Bruno", example.call(user: "Bruno")
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
    assert_equal "***\n", mote_file("test/basic.erb", :n => 3)
  end

  test do
    context = Object.new
    context.instance_variable_set(:@user, "Bruno")
    context.extend(Mote::Helpers)

    assert_equal "Bruno", context.mote("<%= @user %>")
  end

  test do
    context = Object.new
    context.extend(Mote::Helpers)

    assert_equal "Bruno", context.mote("<%= user %>", user: "Bruno")
    assert_equal "Brutus", context.mote("<%= user %>", user: "Brutus")
  end

  test do
    context = Object.new
    context.extend(Mote::Helpers)

    context.instance_variable_set(:@user, "Bruno")

    assert_equal "\n  Bruno rhymes with Piano\n\n",
      context.mote_file("./test/complex.html.mote")

    context.instance_variable_set(:@user, "Brutus")

    assert_equal "\n  Brutus rhymes with Opus\n\n",
      context.mote_file("./test/complex.html.mote")
  end
end
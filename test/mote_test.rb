require File.expand_path("../lib/mote", File.dirname(__FILE__))

scope do
  test "assignment" do
    example = Mote.parse("{{ \"***\" }}")
    assert_equal "***", example.call
  end

  test "comment" do
    template = (<<-EOT).gsub(/ {4}/, "")
    *
    % # "*"
    *
    EOT

    example = Mote.parse(template)
    assert_equal "*\n*\n", example.call.squeeze("\n")
  end

  test "control flow" do
    template = (<<-EOT).gsub(/ {4}/, "")
    % if false
      *
    % else
      ***
    % end
    EOT

    example = Mote.parse(template)
    assert_equal "\n  ***\n\n", example.call
  end

  test "block evaluation" do
    template = (<<-EOT).gsub(/ {4}/, "")
    % 3.times {
    *
    % }
    EOT

    example = Mote.parse(template)
    assert_equal "\n*\n\n*\n\n*\n\n", example.call
  end

  test "parameters" do
    template = (<<-EOT).gsub(/ {4}/, "")
    % params[:n].times {
    *
    % }
    EOT

    example = Mote.parse(template)
    assert_equal "\n*\n\n*\n\n*\n\n", example[:n => 3]
    assert_equal "\n*\n\n*\n\n*\n\n*\n\n", example[:n => 4]
  end

  test "multiline" do
    example = Mote.parse("The\nMan\nAnd\n{{\"The\"}}\nSea")
    assert_equal "The\nMan\nAnd\nThe\nSea", example[:n => 3]
  end

  test "quotes" do
    example = Mote.parse("'foo' 'bar' 'baz'")
    assert_equal "'foo' 'bar' 'baz'", example.call
  end

  test "context" do
    context = Object.new
    context.instance_variable_set(:@user, "Bruno")

    example = Mote.parse("{{ @user }}", context)
    assert_equal "Bruno", example.call
  end

  test "locals" do
    context = Object.new

    example = Mote.parse("{{ user }}", context, [:user])
    assert_equal "Bruno", example.call(user: "Bruno")
  end

  test "curly bug" do
    example = Mote.parse("{{ [1, 2, 3].map { |i| i * i }.join(',') }}")
    assert_equal "1,4,9", example.call
  end
end

scope do
  test "simple directive" do
    example = Mote.parse("{{{ [1, 2, 3].map { |i| i * i }.join(',') }}}")
    assert_equal "1,4,9", example.call
  end

  test "using a method in the context" do
    context = Struct.new(:settings).new
    context.settings = { title: "Hello World" }

    example = Mote.parse("{{{settings[:title]}}}", context)
    assert_equal "Hello World", example.call
  end

end

include Mote::Helpers

scope do
  test "helpers" do
    assert_equal "\n  *\n\n  *\n\n  *\n\n", mote("test/basic.erb", :n => 3)
  end
end

require "benchmark"

class Settings
  def title
    "Hello World"
  end
end

class Context
  def settings
    $settings ||= Settings.new
  end

  def countries_dropdown
    $bla ||= (0..100).to_a.map { |e| %{<option>#{e}</option>} }.join("\n")
  end
end

context = Context.new

tmpl1 = Mote.parse("{{settings.title}} {{ countries_dropdown }}", context)
tmpl2 = Mote.parse("{{{settings.title}}} {{{ countries_dropdown }}}", context)

r1 = Benchmark.realtime {
  1000.times {
    tmpl1.call
  }
}

r2 = Benchmark.realtime {
  1000.times {
    tmpl2.call
  }
}

puts r1
puts r2
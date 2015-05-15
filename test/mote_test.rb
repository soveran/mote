require File.expand_path("../lib/mote", File.dirname(__FILE__))

scope do
  test "empty lines" do
    example = Mote.parse("\n\n \n")
    assert_equal "\n\n \n", example.call
  end

  test "empty lines with mixed code" do
    example = Mote.parse("\n% true\n\n% false\n\n")
    assert_equal "\n\n\n", example.call
  end

  test "empty lines with control flow" do
    example = Mote.parse("\n% if true\n\n\n% else\n\n% end\n")
    assert_equal "\n\n\n", example.call
  end

  test "control flow without final newline" do
    example = Mote.parse("\n% if true\n\n\n% else\n\n% end")
    assert_equal "\n\n\n", example.call
  end

  test "assignment" do
    example = Mote.parse("{{ '***' }}")
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
    assert_equal "  ***\n", example.call
  end

  test "block evaluation" do
    template = (<<-EOT).gsub(/ {4}/, "")
    % 3.times {
    *
    % }
    EOT

    example = Mote.parse(template)
    assert_equal "*\n*\n*\n", example.call
  end

  test "parameters" do
    template = (<<-EOT).gsub(/ {4}/, "")
    % params[:n].times {
    *
    % }
    EOT

    example = Mote.parse(template)
    assert_equal "*\n*\n*\n", example[:n => 3]
    assert_equal "*\n*\n*\n*\n", example[:n => 4]
  end

  test "multiline" do
    example = Mote.parse("The\nMan\nAnd\n{{\"The\"}}\nSea")
    assert_equal "The\nMan\nAnd\nThe\nSea", example.call
  end

  test "quotes" do
    example = Mote.parse("'foo' 'bar' 'baz'")
    assert_equal "'foo' 'bar' 'baz'", example.call
  end

  test "context" do
    context = Object.new
    def context.user; "Bruno"; end

    example = Mote.parse("{{ user }}", context)
    assert_equal "Bruno", example.call
  end

  test "locals" do
    example = Mote.parse("{{ user }}", TOPLEVEL_BINDING, [:user])
    assert_equal "Bruno", example.call(user: "Bruno")
  end

  test "nil" do
    example = Mote.parse("{{ user }}", TOPLEVEL_BINDING, [:user])
    assert_equal "", example.call(user: nil)
  end

  test "multi-line XML-style directives" do
    template = (<<-EOT).gsub(/^    /, "")
    <?
      # Multiline code evaluation
      lucky = [1, 3, 7, 9, 13, 15]
      prime = [2, 3, 5, 7, 11, 13]
    ?>

    {{ lucky & prime }}
    EOT

    example = Mote.parse(template)
    assert_equal "\n\n[3, 7, 13]\n", example.call
  end

  test "preserve XML directives" do
    template = (<<-EOT).gsub(/^    /, "")
    <?xml "hello" ?>
    EOT

    example = Mote.parse(template)
    assert_equal "<?xml \"hello\" ?>\n", example.call
  end
end

include Mote::Helpers

class Cutest::Scope
  def foo
    "foo"
  end
end

scope do
  prepare do
    mote_cache.clear
  end

  test "helpers" do
    assert_equal "  *\n  *\n  *\n", mote("test/basic.mote", :n => 3)
  end

  test "using functions in the context" do
    assert_equal "foo\n", mote("test/foo.mote")
  end

  test "passing in a context" do
    assert_raise NameError do
      mote("test/foo.mote", {}, TOPLEVEL_BINDING)
    end
  end

  test "passing in a buffer" do
    assert_equal "barfoo\n", mote("test/foo.mote", {}, self, "bar")
  end
end

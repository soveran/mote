Mote
====

Minimum Operational Template.

Description
-----------

Mote is very simple and fast template engine that praises itself of being
simple--both internally and externally-- and super fast.

Usage
-----

Usage is very similar to that of ERB:

    template = Mote.parse("This is a template")
    template.call #=> "This is a template"

Silly example, you may say, and I would agree. What follows is a short list of
the different use cases you may face:


    % if user == "Bruno"
      ${user} rhymes with Piano
    % elsif user == "Brutus"
      ${user} rhymes with Opus
    % end

## Control flow

Lines that start with `%` are evaluated as Ruby code.

## Assignment

Whatever it is between `${` and `}` gets printed in the template.

## Comments

There's nothing special about comments, it's just a `#` inside your Ruby code:

    % # This is a comment.


## Block evaluation

As with control instructions, it happens naturally:

    % 3.times do |i|
      ${i}
    % end

## Parameters

The values passed to the template are available as local variables:

    example = Mote.parse("Hello ${name}")
    assert_equal "Hello world", example.call(name: "world")
    assert_equal "Hello Bruno", example.call(name: "Bruno")

# Helpers

There's a helper available in the `Mote::Helpers` module, and you are
free to include it in your code. To do it, just type:

    include Mote::Helpers

## mote

The `mote` helper receives a file name and a hash and returns the rendered
version of its content. The compiled template is cached for subsequent calls.

    assert_equal "***\n", mote("test/basic.erb", n: 3)

Installation
------------

    $ gem install mote

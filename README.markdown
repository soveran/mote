Mote
====

Minimum Operational Template.

Description
-----------

Mote is the little brother of ERB. It only provides a subset of ERB's
features, but praises itself of being simple--both internally and externally--
and super fast. It was born out of experimentations while discussing
[NOLATE](https://github.com/antirez/nolate), another small library with the
same goals and more features.

Usage
-----

Usage is very similar to that of ERB:

    template = Mote.parse("This is a template")
    template.call #=> "This is a template"

Silly example, you may say, and I would agree. What follows is a short list of
the different use cases you may face:

## Assignment

    example = Mote.parse("<%= \"***\" %>")
    assert_equal "***", example.call

## Comment

    example = Mote.parse("*<%# \"*\" %>*")
    assert_equal "**", example.call

## Control flow

    example = Mote.parse("<% if false %>*<% else %>***<% end %>")
    assert_equal "***", example.call

## Block evaluation

    example = Mote.parse("<% 3.times { %>*<% } %>")
    assert_equal "***", example.call

## Parameters

    example = Mote.parse("<% params[:n].times { %>*<% } %>")
    assert_equal "***", example[n: 3]
    assert_equal "****", example[n: 4]

Two things are worth noting in the last example: the first is that as the
returned value is a `Proc`, you can call it with square brackets and anything
you put inside becomes a parameter. Second, that within the template you have
access to those parameters through the `params` hash, instead of the usual
approach of converting each key to a local variable.

# Helpers

There are a couple helpers available in the `Mote::Helpers` module, and you are
free to include it in your code. To do it, just type:

    include Mote::Helpers

Here are the available helpers:

## `mote`

The `mote` helper receives a template string and returns the rendered version
of it:

    assert_equal "1 2 3", mote("1 <%= 2 %> 3")

It works with parameters too:

    assert_equal "1 2 3", mote("1 <%= params[:n] %> 3", :n => 2)

## `mote_file`

The `mote_file` helper receives a file name without the `.erb` extension and
returns the rendered version of its content. The compiled template is cached
for subsequent calls.

    assert_equal "***\n", mote_file("test/basic", :n => 3)

Installation
------------

    $ gem install mote

License
-------

Copyright (c) 2011 Michel Martens

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

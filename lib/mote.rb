# Copyright (c) 2011 Michel Martens
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
class Mote
  VERSION = "1.3.0"

  # The regex has three alternative blocks that capture the embedded
  # Ruby code. The rest is left as is.
  PATTERN = /
    ^[^\S\n]*(%)[^\S\n]*(.*?)(?:\n|\Z) | # Ruby evaluated lines
    (<\?)\s+(.*?)\s+\?>                | # Multiline Ruby blocks
    (\{\{)(.*?)\}\}                      # Ruby evaluated to strings
  /mx

  def self.src(template, vars = [])
    terms = template.split(PATTERN)

    code = "Proc.new do |params, __o| params ||= {}; __o ||= '';"

    vars.each do |var|
      code << "%s = params[%p];" % [var, var]
    end

    while (term = terms.shift)
      case term
      when "<?" then code << "#{terms.shift}\n"
      when "%"  then code << "#{terms.shift}\n"
      when "{{" then code << "__o << (#{terms.shift}).to_s\n"
      else           code << "__o << #{term.dump}\n"
      end
    end

    code << "__o; end"
  end

  def self.parse(_template, _context = self, _vars = [], _name = "template")
    _context.instance_eval(src(_template, _vars), _name, -1)
  end

  module Helpers
    def mote(file, params = {}, context = self)
      template = File.read(file)

      mote_cache[file] ||= Mote.parse(template, context, params.keys, file)
      mote_cache[file][params]
    end

    def mote_cache
      Thread.current[:_mote_cache] ||= {}
    end
  end
end

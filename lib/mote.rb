# Copyright (c) 2011, 2012 Michel Martens
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
  VERSION = "1.1.2"

  PATTERN = /^(\n)|^\s*(%)\s*(.*?)(?:\n|\Z)|(<\?)\s+(.*?)\s+\?>|(\{\{)(.*?)\}\}/m

  def self.parse(template, context = self, vars = [])
    terms = template.split(PATTERN)

    parts = "Proc.new do |params, __o|\n params ||= {}; __o ||= ''\n"

    vars.each do |var|
      parts << "%s = params[%s]\n" % [var, var.inspect]
    end

    while term = terms.shift
      case term
      when "<?" then parts << "#{terms.shift}\n"
      when "%"  then parts << "#{terms.shift}\n"
      when "{{" then parts << "__o << (#{terms.shift}).to_s\n"
      else           parts << "__o << #{term.dump}\n"
      end
    end

    parts << "__o; end"

    compile(context, parts)
  end

  def self.compile(context, parts)
    context.instance_eval(parts)
  end

  module Helpers
    def mote(file, params = {}, context = self)
      mote_cache[file] ||= Mote.parse(File.read(file), context, params.keys)
      mote_cache[file][params]
    end

    def mote_cache
      Thread.current[:_mote_cache] ||= {}
    end
  end
end

# Copyright (c) 2010 Michel Martens
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
  VERSION = "0.2.0"

  def self.parse(template, context = self, vars = [])
    terms = template.split(/^\s*(%)(.*?)$|(\{\{)(.*?)\}\}/)

    parts = "Proc.new do |params = {}, ontainted = nil, __o = ''|\n"

    vars.each do |var|
      parts << "%s = params[:%s]\n" % [var, var]
    end

    while term = terms.shift
      case term
      when "%"  then parts << "#{terms.shift}\n"
      when "{{" then parts << "__o << ::Mote.clean((#{terms.shift}).to_s, ontainted)\n"
      else           parts << "__o << #{term.dump}\n"
      end
    end

    parts << "__o; end"

    context.instance_eval(parts)
  end

  def self.clean(str, ontainted)
    ontainted && str.tainted? ? ontainted.call(str) : str
  end

  module Helpers
    def mote(filename, params = {}, ontaint = nil)
      mote_cache[filename] ||= Mote.parse(File.read(filename), self, params.keys)
      mote_cache[filename][params, ontaint]
    end

    def mote_cache
      Thread.current[:_mote_cache] ||= {}
    end
  end
end

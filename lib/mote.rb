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
  VERSION = "0.0.1"

  def self.parse(template, context = self)
    terms = template.split(/(<%[=#]?)\s*(.*?)\s*%>/)

    parts = "Proc.new do |params, __o|\n params ||= {}; __o ||= ''\n"

    while term = terms.shift
      case term
      when "<%#" then terms.shift # skip
      when "<%"  then parts << "#{terms.shift}\n"
      when "<%=" then parts << "__o << (#{terms.shift}).to_s\n"
      else            parts << "__o << #{term.inspect}\n"
      end
    end

    parts << "__o; end"

    context.instance_eval(parts)
  end

  module Helpers
    def mote(template, params = {})
      mote_cache[template] ||= Mote.parse(template)
      mote_cache[template][params]
    end

    def mote_file(filename, params = {})
      mote_files[filename] ||= Mote.parse(File.read(filename))
      mote_files[filename][params]
    end

    def mote_cache
      @_mote_cache ||= {}
    end

    def mote_files
      @_mote_files ||= {}
    end
  end
end

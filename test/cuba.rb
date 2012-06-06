require File.expand_path("../lib/mote", File.dirname(__FILE__))
require "cuba"
require "rack/test"

TMPL = <<-EOT
uid: {{ current_user.id }}
path: {{ req.path }}
EOT

class User < Struct.new(:id)
  def self.[](id)
    new(id)
  end
end

Cuba.use Rack::Session::Cookie

Cuba.define do
  def current_user
    # User[session[:user_id]]
    User[$FOO[:user_id]]
  end

  def cache
    Thread.current[:_mote] ||= {}
  end

  def mote(str, locals = {})
    cache[str] ||= Mote.parse(str, self, locals.keys)
    cache[str].call(locals)
  end

  on put, :id do |id|
    $FOO ||= {}
    $FOO[:user_id] = id
    # session[:user_id] = id
  end

  on default do
    res.write mote(TMPL)
  end
end

scope do
  extend Rack::Test::Methods

  def app
    Cuba
  end

  test do
    put "/1"

    get "/"
    puts last_response.body

    put "/2"
    get "/"
    puts last_response.body

    get "/foo/bar/baz"
    puts last_response.body
  end
end

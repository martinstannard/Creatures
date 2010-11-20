#Rackup file for serving up a static site from a "public" directory
#
# Useful for chucking a static site on Heroku

class IndexRewriter
  def initialize(app) @app = app end
  def call(env)
    env["PATH_INFO"].gsub! /\/$/, '/index.html'
    @app.call(env)
  end
end

use IndexRewriter

run Rack::File.new("public")

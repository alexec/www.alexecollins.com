
###
# Blog settings
###

# Time.zone = "UTC"

set :markdown_engine, :kramdown

activate :blog do |blog|
  # blog.prefix = "blog"
  blog.permalink = "/:title"
  blog.sources = "articles/:year-:month-:day-:title.html"
  blog.taglink = "tags/:tag.html"
  #blog.layout = "layouts/blog"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 250
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  blog.default_extension = ".md"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  blog.paginate = true
  blog.per_page = 20
  blog.page_link = "page/:num"
end

page "/feed.xml", :layout => false

###
# Compass
###

# Susy grids in Compass
# First: gem install susy
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'css'

set :js_dir, 'js'

set :images_dir, 'images'


# Adds a .html unless we're GETing /
#use Rack::Rewrite do
#  rewrite %r{^/(.[^.]+)$}, '/$1.html'
#end

#activate :deploy do |deploy|
#  deploy.method = :rsync
#  deploy.host   = "ec2"
#  deploy.path   = "/var/www/html"
#  deploy.clean = true
# => end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  activate :minify_html

  # Enable cache buster
  # activate :cache_buster

  # Use relative URLs
	# screws 404 page
  # activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"

	activate :directory_indexes
#	activate :gzip
#  activate :livereload
  activate :syntax
end

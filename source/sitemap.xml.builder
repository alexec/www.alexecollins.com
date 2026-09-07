xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  skip = %r{\A(404|tags/|page/|\d{4}/)}
  pages = sitemap.resources.select { |r| r.path.end_with?(".html") && r.path !~ skip }
  pages.sort_by(&:url).each do |page|
    xml.url do
      xml.loc "https://www.alexecollins.com#{page.url}"
      xml.lastmod page.date.strftime("%Y-%m-%d") if page.respond_to?(:date) && page.date
    end
  end
end

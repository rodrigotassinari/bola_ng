xml.instruct!(:xml, :version => "1.0")
xml.rss('version' => '2.0',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom',
        'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do |xml|
  xml.channel do |xml|
    xml.title("#{Settings.site.name} :: Lifestream :: Busca :: #{@query}")
    xml.description("#{Settings.site.tagline}")
    xml.link(root_url)
    xml.tag!('atom:link', :href => File.join(root_url.to_s, File.join(request.request_uri.to_s)), :rel => 'self', :type => 'application/rss+xml')
    xml.pubDate(@posts.first.published_at.to_s(:rfc822)) if @posts.first
    xml.generator("bola_ng")
    @posts.each do |post|
      xml.item do
        xml.title("Eu #{t post.service_action} no #{post.service.name}: #{h(post.title)}")
        xml.description do
          xml.cdata!(post.summary)
        end
        xml.tag!('content:encoded') do
          xml.cdata!(post.body)
        end
        xml.tag!('dc:creator', (post.extra_content && post.extra_content['author'] ? post.extra_content['author'] : 'PiTT') )
        xml.pubDate(post.published_at.to_s(:rfc822))
        xml.link(post.service.class == BlogService ? blog_url(post.slug) : post.url)
        xml.guid(post_url(post.id), :isPermaLink => true)
        post.tag_list.each do |tag|
          xml.category(tag)
        end
      end
    end
  end
end

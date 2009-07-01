# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Example:
  #
  #   >> flash[:notice] = "Yada yada yada"
  #   >> display_flashes
  #   => "<div class=\"flash\ id=\"flash_notice\"><p>Yada yada yada</p></div>"
  #
  def display_flashes
    return nil if flash.empty?
    html = ''
    flash.each do |key, message|
      flash_message = content_tag(:p, message)
      close_link = content_tag(
        :span,
        link_to_function('fechar', "$('#flash_#{key}').hide()"),
        :class => 'close'
      )
      html << content_tag(:div, close_link + flash_message, :class => 'flash', :id => "flash_#{key}")
    end
    html
  end

  def tag_cloud(tags, classes)
    return if tags.empty?
    max_count = tags.sort_by(&:count).last.count.to_f
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end

  def disqus_comments_tag(disqus_site_id)
    html = ""
    html << javascript_tag("var disqus_developer = 1;") if Rails.env.development? && Settings.disqus_in_development
    html << %{<div id="disqus_thread"></div><script type="text/javascript" src="http://disqus.com/forums/#{disqus_site_id}/embed.js"></script><noscript><a href="http://#{disqus_site_id}.disqus.com/?url=ref">View the discussion thread.</a></noscript><a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>}
    html
  end

  def disqus_comment_counter_tag(disqus_site_id)
    return if Rails.env.development? && !Settings.disqus_in_development
    html = javascript_tag do
      <<-eos
        (function() {
          var links = document.getElementsByTagName('a');
          var query = '?';
          for(var i = 0; i < links.length; i++) {
            if(links[i].href.indexOf('#disqus_thread') >= 0) {
              query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';
            }
          }
          document.write('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/#{disqus_site_id}/get_num_replies.js' + query + '"></' + 'script>');
        })();
      eos
    end
    html
  end

  def google_analytics_javascript(analytics_id)
    return unless Rails.env.production?
    <<-eos
      <script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
      </script>
      <script type="text/javascript">
      try {
      var pageTracker = _gat._getTracker("#{analytics_id}");
      pageTracker._trackPageview();
      } catch(err) {}</script>
    eos
  end

  def random_phrase
    [
      "Each place has its own advantages - heaven for the climate, and hell for the society. <i>(Mark Twain)</i>",
      "Love is a snowmobile racing across the tundra and then suddenly it flips over, pinning you underneath. At night, the ice weasels come. <i>(Matt Groening)</i>",
      "$ who | grep -i blonde | talk; date; cd ~; wine; talk; touch; unzip; touch; strip; finger; mount; fsck; more; yes; umount; make clean; sleep",
      "Não sabendo que era impossível, foi lá e fez.",
      "Laptoptospirose é a doença transmitida pela urina do mouse.",
      "Given the choice between dancing pigs and security, people will choose dancing pigs every time. <i>(Ed Felton)</i>",
      "O pior não é morrer, é não poder espantar as moscas.",
      "Gatos radioativos têm 14 meias-vidas.",
      "E se não existissem situações hipotéticas?",
      "O bom de usar dentadura é poder escovar os dentes e cantar ao mesmo tempo.",
      "Nunca diga 'Eu não posso'; diga 'Nós não podemos'.",
      "Viva a vida perigosamente: Faça pipoca com a panela aberta!",
      "It's so simple to be wise. Just think of something stupid to say and then don't say it. <i>(Sam Levenson)</i>",
      "Management is doing things right; leadership is doing the right things. <i>(Peter Drucker)</i>",
      "Progress isn't made by early risers. It's made by lazy men trying to find easier ways to do something. <i>(Robert Heinlein)</i>",
      "I learned long ago never to wrestle with a pig. You get dirty, and besides, the pig likes it. <i>(Cyrus Ching)</i>",
      "Se só o que você tem é um martelo, trate tudo como um prego.",
      "Coma merda. Um trilhão de moscas não podem estar erradas.",
      "Hmmmmmm.. Que cheiro de bicho morto! AAAAAAAAAAAAHHHHHHHHH!!! Meu mouse morreu!! Snif, snif! :(",
      "Minhoca: Um absurdo sem pé nem cabeça.",
      "Um programa sem bugs é um conceito teórico abstrato.",
      "Basically my wife was immature. I'd be at home in the bath and she'd come in and sink my boats. <i>(Woody Allen)</i>",
      "Cloquet hated reality but realized it was still the only place to get a good steak. <i>(Woody Allen)</i>",
      "I don't want to achieve immortality through my work. I want to achieve it through not dying. <i>(Woody Allen)</i>",
      "Love is the answer, but while you're waiting for the answer, sex raises some pretty interesting questions. <i>(Woody Allen)</i>",
      "Not only is there no God, but try finding a plumber on Sunday. <i>(Woody Allen)</i>",
      "What if everything is an illusion and nothing exists? In that case, I definitely overpaid for my carpet. <i>(Woody Allen)</i>",
      "A man who carries a cat by the tail learns something he can learn in no other way. <i>(Mark Twain)</i>",
      "'Classic.' A book which people praise and don't read. <i>(Mark Twain)</i>",
      "Os últimos poderão até ser os primeiros, porém os do meio sempre serão os do meio. <i>(PiTT)</i>",
      "It's practically impossible to look at a penguin and feel angry. <i>(Joe Moore)</i>",
      "There are two major products that came out of Berkeley: LSD and UNIX. We don't believe this to be a coincidence. <i>(Jeremy S. Anderson)</i>",
      "O maior inimigo da verdade, não é a mentira e sim, a convicção. <i>(Friedrich Nietzsche)</i>",
      "Você pode viver até os cem anos se abandonar todas as coisas que fazem com que você queira viver até os cem anos. <i>(Woody Allen)</i>"
    ].sort_by { rand }.first
  end

end

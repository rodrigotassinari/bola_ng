module LifestreamHelper

  def relative_published_date(date)
    l(date, :format => "%d %B %Y, %H:%M:%S")
  end

  def is_last_in_row?(index, per_row=3)
    ((index + 1) % per_row) == 0
  end

  def title_if_needed(text, size)
    text.to_s.length > size ? text : nil
  end

  def twitter_auto_link(text)
    text = auto_twitter_profiles(text)
    text = auto_twitter_keywords(text)
    auto_link(text)
  end

  private

    def auto_twitter_profiles(text)
      return '' if text.blank?
      text.gsub(/\@([\w_\-\.]+)/) do
        link_to("@#{$1}", "http://twitter.com/#{$1}")
      end
    end

    def auto_twitter_keywords(text)
      return '' if text.blank?
      text.gsub(/\#([\w_\-\.]+)/) do
        link_to("##{$1}", "http://search.twitter.com/search?tag=#{$1}")
      end
    end

end

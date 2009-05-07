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

end

module LifestreamHelper

  def relative_published_date(date)
    #TODO
    date.strftime("%d %B %Y, %I:%M %p")
  end

  def is_last_in_row?(index, per_row=3)
    ((index + 1) % per_row) == 0
  end

end

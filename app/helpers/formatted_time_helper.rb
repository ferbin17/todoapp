module FormattedTimeHelper

  def format_time(time)
    time.strftime("%l.%M %P, %e %B %Y")
  end

end

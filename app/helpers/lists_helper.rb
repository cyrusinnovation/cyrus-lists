module ListsHelper
  def email_list name
    "#{name}@#{Settings.domain}"
  end

  def email_list_mail_to name
    mail_to email_list(name), name
  end

  def get_all_subscribers_except list, except
    list.subscribers.collect {|s| [ s.email, s.id ] unless s == except}.compact
  end

  def list_display_date list
    return '' if list.last_sent_time.nil?
    list.last_sent_time.strftime('%B %d, %Y')
  end
end

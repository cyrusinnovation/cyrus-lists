class NewListMailer < ActionMailer::Base
  def distribute list
    @list = list
    
    newlist = get_newlist_and_update_time
    emails = newlist.email_addresses
    emails.each do |email|
      mail(:to => email,
           :subject => "New List: #{@list.name} was created",
           :from => "newlist@#{Settings.domain}").deliver
    end
  end

  def get_newlist_and_update_time
    newlist = List.newlist
    newlist.update_last_sent_time
    newlist
  end
end

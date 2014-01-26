class ListExploder

  def initialize(domains = Settings.list_domain_aliases, catchall_address = Settings.catchall_address)
    @domains = domains
    @catchall_address = catchall_address
  end

  def simplified email
    Mail::Address.new(email).address
  end

  def internal email
    has_valid_domain?(email) ? email : nil
  end

  def relevant email
    internal(simplified(email))
  end

  def explode(email_addresses, from)
    recipients = []
    email_addresses.flat_map do |email|
      recipients.concat recipients_for(relevant email)
    end.compact
    recipients.uniq.select { |x| x != simplified(from) }
  end

  def recipients_for list_email, exploded_lists = []
    return [] if exploded_lists.include?(list_email) || list_email.nil?
    return [list_email] unless has_valid_domain? list_email
    return [@catchall_address] unless list = get_list(list_email)
    exploded_lists << list_email
    list.update_last_sent_time
    recipients = list.email_addresses
    recipients << Settings.archive_address unless list.restricted?
    recipients.flat_map { |email| recipients_for(email, exploded_lists)}.uniq
  end
  
  private

  def has_valid_domain? email
    email_domain = email.split(/@/)[1]
    @domains.include?(email_domain)
  end

  def get_list email
    list_name, domain = email.split(/@/)
    has_valid_domain?(email) ? List.find_by_name(list_name) : nil
  end
end

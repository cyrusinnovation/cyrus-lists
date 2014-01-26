#encoding: utf-8
class Email
  attr_reader :uid

  def initialize(email, uid)
    @email = email
    @uid = uid
  end

  def lists
    @lists ||= extract_lists_from_email_destinations
  end

  def from
    @from ||= @email.From.value
  end

  def body
    @body ||= normalize_body
  end

  def subject
    @subject ||= @email.subject
  end

  def date
    @date ||= normalize_date(@email.date)
  end

  def to_hash
    {
        'lists' => lists,
        'subject' => subject,
        'uid' => uid,
        'from' => from,
        'body' => body,
        'date' => date
    }
  end

  def == other
    self.uid == other.uid
  end

  private

  def normalize_date(date)
    date.strftime("%b %e, %Y at %I:%M %p")
  end

  def normalize_body
    text = nil
    if @email.multipart?
      text = @email.text_part.body if @email.text_part
    else
      text = @email.body.decoded
    end
    text = text.to_s.force_encoding("ISO8859-1").encode('utf-8')
    text.gsub("\n", "<br />").html_safe

  end

  def extract_lists_from_email_destinations
    lists = [].concat(@email.to.to_a).
        concat(@email.cc.to_a).
        concat(@email.bcc.to_a)
    lists.select do |email_address|
      list_email_address? email_address
    end.map do |email_address|
      email_address.split('@').first
    end
  end

  def list_email_address? email_address
      email_address[lists_domain_regexp]
  end


  def lists_domain_regexp
    domains = Settings.list_domain_aliases.join("|")
    /@#{domains}/
  end
end
class ArchiveCache

  def self.update
    clear_redis

    List.all.map do |list|
      {
          list: list.name,
          meta_id: GmailService.enqueue(list.name).meta_id,
      }
    end.each do |running_job|
      job = GmailService.get_meta running_job[:meta_id]

      if job_pending?(job)
        Rails.logger.info "Waiting for #{running_job[:list]} to complete"
        sleep 2
        redo
      end

      if job.succeeded?
        update_cached_messages(running_job, job)
      else
        Rails.logger.info "Error updating #{running_job[:list]}"
        next
      end

    end
  end

  def self.update_cached_messages(running_job, job)
    Rails.logger.info "#{running_job[:list]} completed!"

    Rails.logger.info "Deleting cache"
    Rails.cache.delete(running_job[:list])

    Rails.logger.info "Writing updated cache"
    Rails.cache.fetch(running_job[:list]) { job.result }
  end

  def self.clear_redis
    Resque.redis.flushall
  end

  def self.job_pending?(job)
    job.succeeded?.nil?
  end

  def update_unread_messages
    unread_messages.each do |email|
      email.lists.each do |list|
        Rails.logger.info "Adding message to #{list}"
        add_to_cache(list, email.to_hash)
      end

    end
  end

  def unread_messages
    gmail.inbox.emails(:unread).map do |gmail_message|
      #TODO I think GmapEmail -> OurEmail is the abstraction we're looking for
      Email.new(gmail_message.message, gmail_message.uid)
    end
  end

  def add_to_cache(list, message)
    cache = Rails.cache.read(list)
    cache ||= []
    cache.push << message

    Rails.logger.info "Deleting cache"
    Rails.cache.delete(list)

    Rails.logger.info "Writing updated cache"
    Rails.cache.fetch(list) { cache[0...10] }
  end

  private

  def gmail
    @gmail ||= Gmail.connect!(Settings.archive_address, Settings.archive_password)
  end

end

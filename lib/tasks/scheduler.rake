#TODO namespace 'archives' and rename the first task as 'reprocess'
desc "This task is called by the Heroku scheduler add-on"
task :update_archives => :environment do
  puts "Updating archives..."
  ArchiveCache.update
  puts "done."
end

desc "This task is called by the Heroku scheduler add-on"
task :incremental_update => :environment do
  puts "Processing unread messages..."
  archive_cache = ArchiveCache.new
  archive_cache.update_unread_messages
  puts "Done processing unread messages."
end

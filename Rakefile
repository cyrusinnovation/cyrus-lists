#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
Listlist::Application.load_tasks

begin
  require 'rspec/core/rake_task'

  desc "Run specs that don't require redis"
  RSpec::Core::RakeTask.new('spec:noredis') do |t|
    t.rspec_opts = "--tag ~redis"
  end

rescue LoadError
  desc "Install rspec for rspec tasks"
  task 'spec:noredis' do
    abort "Rspec is not available. Install rspec."
  end
end

#!/usr/bin/env ruby

load("config/environment.rb")

developer_id = ARGV[0]
unless developer_id
  puts "Usage: ruby script/rebuild_rfc_count.rb <developer_id>"
  exit 1
end

facts = event_store.read.stream("Developer$#{developer_id}")
progress = build_progress_bar(facts.count, "Count RFC issued")

ReadModels::NumberOfRfcIssuedByDeveloper.where(developer_id: developer_id).delete_all
count = ReadModels::NumberOfRfcIssuedByDeveloper.new

facts.each do |fact|
  count.call(fact)
  progress.increment
end

puts "Rebuild completed for developer: #{developer_id}"

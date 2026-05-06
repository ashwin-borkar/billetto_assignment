#!/usr/bin/env ruby

# Practical Usage Examples for Guidelines Module
# Run this script to see the Guidelines module in action

load("config/environment.rb")

puts "🚀 Guidelines Module Usage Examples"
puts "=" * 50

# Example 1: Issue a new RFC
puts "\n📝 Example 1: Issue a new RFC"
puts "-" * 30

begin
  # Create the command
  issue_command = Guidelines::IssueRequestForComment.new(
    description: "Implement OAuth2 authentication system",
    developer_id: "dev-123"
  )
  
  # Execute via command bus
  command_bus.call(issue_command)
  
  # Get the created RFC
  rfc = Guidelines::RequestForComment.last
  puts "✅ RFC created successfully!"
  puts "   Number: #{rfc.number}"
  puts "   Description: #{rfc.description}"
  puts "   Author: #{rfc.author_id}"
  puts "   TID: #{rfc.tid}"
  
rescue => e
  puts "❌ Error creating RFC: #{e.message}"
end

# Example 2: Approve RFC by developers
puts "\n👍 Example 2: Approve RFC by developers"
puts "-" * 35

begin
  rfc = Guidelines::RequestForComment.last
  puts "Approving RFC: #{rfc.number}"
  
  # First developer approval
  approve_command1 = Guidelines::ApproveByDeveloper.new(
    tid: rfc.tid,
    developer_id: "dev-456"
  )
  command_bus.call(approve_command1)
  puts "✅ Approved by developer: dev-456"
  
  # Second developer approval (this should trigger final approval)
  approve_command2 = Guidelines::ApproveByDeveloper.new(
    tid: rfc.tid,
    developer_id: "dev-789"
  )
  command_bus.call(approve_command2)
  puts "✅ Approved by developer: dev-789"
  
  # Check approval count
  rfc.reload
  puts "📊 Total approvals: #{rfc.approvals.count}"
  
rescue => e
  puts "❌ Error approving RFC: #{e.message}"
end

# Example 3: Query read models
puts "\n📊 Example 3: Query read models"
puts "-" * 30

begin
  # Get RFC count by developer
  count = ReadModels::NumberOfRfcIssuedByDeveloper::Count.find_or_initialize_by(developer_id: "dev-123")
  puts "📈 Developer dev-123 has issued #{count.value || 0} RFCs"
  
  # List all RFCs
  rfcs = Guidelines::RequestForComment.all
  puts "📋 Total RFCs in system: #{rfcs.count}"
  
  rfcs.each_with_index do |rfc, index|
    puts "   #{index + 1}. #{rfc.number} - #{rfc.description} (#{rfc.approvals.count} approvals)"
  end
  
rescue => e
  puts "❌ Error querying read models: #{e.message}"
end

# Example 4: Manual final approval
puts "\n🎯 Example 4: Manual final approval"
puts "-" * 35

begin
  rfc = Guidelines::RequestForComment.last
  puts "Manually approving RFC: #{rfc.number}"
  
  final_approve_command = Guidelines::ApproveRequestForComment.new(
    tid: rfc.tid
  )
  command_bus.call(final_approve_command)
  puts "✅ RFC final approval completed!"
  
rescue => e
  puts "❌ Error with final approval: #{e.message}"
end

# Example 5: Error handling demonstration
puts "\n⚠️  Example 5: Error handling demonstration"
puts "-" * 40

begin
  # Try to approve non-existent RFC
  invalid_approve_command = Guidelines::ApproveByDeveloper.new(
    tid: "invalid-tid",
    developer_id: "dev-123"
  )
  command_bus.call(invalid_approve_command)
  
rescue ActiveRecord::RecordNotFound => e
  puts "✅ Expected error caught: RFC not found"
  puts "   Error: #{e.message}"
rescue => e
  puts "❌ Unexpected error: #{e.message}"
end

# Example 6: Command validation
puts "\n✅ Example 6: Command validation"
puts "-" * 30

begin
  # Try to create invalid command (missing required fields)
  invalid_command = Guidelines::IssueRequestForComment.new(
    description: "",  # Empty description
    developer_id: ""  # Empty developer_id
  )
  
  if invalid_command.valid?
    puts "❌ Command should be invalid"
  else
    puts "✅ Command validation working correctly"
    puts "   Errors: #{invalid_command.errors.full_messages.join(', ')}"
  end
  
rescue => e
  puts "❌ Error in validation test: #{e.message}"
end

puts "\n🎉 Usage Examples Complete!"
puts "=" * 50
puts "\nNext steps:"
puts "1. Try the examples in Rails console: rails console"
puts "2. Check the documentation: GUIDELINES_USAGE.md"
puts "3. Test webhook endpoints: POST /webhooks/some_service"
puts "4. Monitor event streams in your event store"

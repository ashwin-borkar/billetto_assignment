#!/usr/bin/env ruby

# Simple Usage Guide for Guidelines Module
# This demonstrates the core functionality without complex dependencies

load("config/environment.rb")

puts "🎯 Simple Guidelines Module Usage Guide"
puts "=" * 50

# Step 1: Create a new RFC directly (without command bus for simplicity)
puts "\n📝 Step 1: Create a new RFC"
puts "-" * 30

begin
  rfc = Guidelines::RequestForComment.create!(
    number: "RFC-2024-001",
    description: "Implement OAuth2 authentication system",
    author_id: "dev-123"
  )
  
  puts "✅ RFC created successfully!"
  puts "   Number: #{rfc.number}"
  puts "   Description: #{rfc.description}"
  puts "   Author: #{rfc.author_id}"
  puts "   TID: #{rfc.tid}"
  puts "   Approvals: #{rfc.approvals.count}"
  
rescue => e
  puts "❌ Error creating RFC: #{e.message}"
end

# Step 2: Add approvals directly
puts "\n👍 Step 2: Add developer approvals"
puts "-" * 35

begin
  rfc = Guidelines::RequestForComment.last
  
  # First approval
  approval1 = rfc.approvals.create!(developer_id: "dev-456")
  puts "✅ Approved by developer: dev-456"
  
  # Second approval
  approval2 = rfc.approvals.create!(developer_id: "dev-789")
  puts "✅ Approved by developer: dev-789"
  
  # Check total approvals
  rfc.reload
  puts "📊 Total approvals: #{rfc.approvals.count}"
  
rescue => e
  puts "❌ Error adding approvals: #{e.message}"
end

# Step 3: Query and display RFCs
puts "\n📋 Step 3: Query all RFCs"
puts "-" * 25

begin
  rfcs = Guidelines::RequestForComment.all
  puts "📊 Total RFCs in system: #{rfcs.count}"
  
  rfcs.each_with_index do |rfc, index|
    puts "   #{index + 1}. #{rfc.number}"
    puts "      Description: #{rfc.description}"
    puts "      Author: #{rfc.author_id}"
    puts "      Approvals: #{rfc.approvals.count}"
    puts "      Status: #{rfc.approvals.count >= 2 ? '✅ Approved' : '⏳ Pending'}"
    puts
  end
  
rescue => e
  puts "❌ Error querying RFCs: #{e.message}"
end

# Step 4: Demonstrate command validation
puts "\n✅ Step 4: Command validation"
puts "-" * 30

begin
  # Test valid command
  valid_command = Guidelines::ApproveByDeveloper.new(
    tid: rfc.tid,
    developer_id: "dev-123"
  )
  
  if valid_command.valid?
    puts "✅ Valid command passes validation"
  else
    puts "❌ Valid command failed validation"
  end
  
  # Test invalid command
  invalid_command = Guidelines::ApproveByDeveloper.new(
    tid: "",  # Empty tid
    developer_id: ""  # Empty developer_id
  )
  
  if invalid_command.valid?
    puts "❌ Invalid command should fail validation"
  else
    puts "✅ Invalid command properly rejected"
    puts "   Errors: #{invalid_command.errors.full_messages.join(', ')}"
  end
  
rescue => e
  puts "❌ Error in validation test: #{e.message}"
end

# Step 5: Show database structure
puts "\n🗄️  Step 5: Database structure"
puts "-" * 30

begin
  puts "📊 Guidelines Request for Comments:"
  Guidelines::RequestForComment.column_names.each do |col|
    puts "   - #{col}"
  end
  
  puts "\n📊 Guidelines Approvals:"
  Guidelines::Approval.column_names.each do |col|
    puts "   - #{col}"
  end
  
rescue => e
  puts "❌ Error showing database structure: #{e.message}"
end

# Step 6: Demonstrate ObjectRepository
puts "\n🔍 Step 6: ObjectRepository functionality"
puts "-" * 40

begin
  rfc = Guidelines::RequestForComment.last
  puts "🔍 Looking up RFC by TID: #{rfc.tid}"
  
  found_rfc = ObjectRepository.find(rfc.tid)
  if found_rfc
    puts "✅ RFC found via ObjectRepository"
    puts "   Number: #{found_rfc.number}"
    puts "   Description: #{found_rfc.description}"
  else
    puts "❌ RFC not found via ObjectRepository"
  end
  
rescue => e
  puts "❌ Error with ObjectRepository: #{e.message}"
end

puts "\n🎉 Simple Usage Guide Complete!"
puts "=" * 50
puts "\n📚 Next Steps:"
puts "1. Open Rails console: rails console"
puts "2. Try the commands manually"
puts "3. Read the full documentation: GUIDELINES_USAGE.md"
puts "4. Test API endpoints with HTTP clients"
puts "\n🔗 Available Controllers:"
puts "- RequestForCommentApprovalsController"
puts "- SomeIncomingWebhookController"
puts "- ApiController (base class)"

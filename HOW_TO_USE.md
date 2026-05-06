# 🚀 HOW TO USE THE GUIDELINES MODULE

This guide shows you exactly how to use the Guidelines module implementation that follows the Developer's Guide architecture.

## 🎯 QUICK START

### 1. Create Your First RFC

```ruby
# In Rails console: rails console
rfc = Guidelines::RequestForComment.create!(
  number: "RFC-2024-001",
  description: "Implement OAuth2 authentication system",
  author_id: "dev-123"
)

puts "✅ RFC Created: #{rfc.number}"
puts "   TID: #{rfc.tid}"
puts "   Status: #{rfc.approvals.count >= 2 ? 'Approved' : 'Pending'}"
```

### 2. Add Developer Approvals

```ruby
# First developer approval
rfc.approvals.create!(developer_id: "dev-456")
puts "✅ Approved by dev-456"

# Second developer approval  
rfc.approvals.create!(developer_id: "dev-789")
puts "✅ Approved by dev-789"

# Check status
rfc.reload
puts "📊 Total approvals: #{rfc.approvals.count}"
puts "🎯 Status: #{rfc.approvals.count >= 2 ? 'FULLY APPROVED' : 'Pending more approvals'}"
```

### 3. Query RFCs

```ruby
# Get all RFCs
rfcs = Guidelines::RequestForComment.all
puts "📋 Total RFCs: #{rfcs.count}"

# Get specific RFC
rfc = Guidelines::RequestForComment.find_by(number: "RFC-2024-001")
puts "🔍 Found RFC: #{rfc&.number}"

# Get RFCs by author
author_rfcs = Guidelines::RequestForComment.where(author_id: "dev-123")
puts "👤 RFCs by dev-123: #{author_rfcs.count}"
```

## 🛠️ USING THE COMMAND BUS

### 1. Issue RFC via Command

```ruby
# Create command
command = Guidelines::IssueRequestForComment.new(
  description: "Add rate limiting to API endpoints",
  developer_id: "dev-123"
)

# Execute via command bus
command_bus.call(command)

# Get the created RFC
rfc = Guidelines::RequestForComment.last
puts "✅ RFC issued via command bus: #{rfc.number}"
```

### 2. Approve RFC via Command

```ruby
# Get existing RFC
rfc = Guidelines::RequestForComment.find_by(number: "RFC-2024-001")

# Create approval command
command = Guidelines::ApproveByDeveloper.new(
  tid: rfc.tid,
  developer_id: "dev-456"
)

# Execute via command bus
command_bus.call(command)
puts "✅ RFC approved via command bus"
```

### 3. Final Approval via Command

```ruby
# Create final approval command
command = Guidelines::ApproveRequestForComment.new(
  tid: rfc.tid
)

# Execute via command bus
command_bus.call(command)
puts "✅ RFC final approval completed"
```

## 🌐 USING THE API ENDPOINTS

### 1. Approve RFC via HTTP

```bash
# POST /request_for_comment_approvals
curl -X POST http://localhost:3000/request_for_comment_approvals \
  -H "Content-Type: application/json" \
  -d '{
    "id": "RequestForComment$uuid-here",
    "developer_id": "dev-456"
  }'
```

### 2. Incoming Webhook

```bash
# POST /webhooks/some_service
curl -X POST http://localhost:3000/webhooks/some_service \
  -H "Content-Type: application/json" \
  -d '{
    "event": "rfc_approved",
    "data": {
      "rfc_id": "RequestForComment$uuid-here"
    }
  }'
```

## 🔍 ADVANCED USAGE

### 1. Using ObjectRepository

```ruby
# Find RFC by TID
rfc = ObjectRepository.find("RequestForComment$uuid-here")
puts "🔍 Found RFC: #{rfc.number}"

# This works with any registered domain object
```

### 2. Working with Approvals

```ruby
# Get all approvals for an RFC
approvals = rfc.approvals
approvals.each do |approval|
  puts "👍 Approved by: #{approval.developer_id} at #{approval.created_at}"
end

# Check if specific developer approved
dev_approval = rfc.approvals.find_by(developer_id: "dev-456")
if dev_approval
  puts "✅ dev-456 has approved this RFC"
else
  puts "❌ dev-456 has not approved this RFC yet"
end
```

### 3. Command Validation

```ruby
# Create invalid command
invalid_command = Guidelines::ApproveByDeveloper.new(
  tid: "",  # Empty tid
  developer_id: ""  # Empty developer_id
)

# Check validation
if invalid_command.valid?
  puts "❌ Command should be invalid"
else
  puts "✅ Command properly validated"
  puts "   Errors: #{invalid_command.errors.full_messages.join(', ')}"
end
```

## 📊 MONITORING AND DEBUGGING

### 1. Check System Status

```ruby
# Check registered domain objects
puts "📋 Registered domain objects:"
ObjectRepository.registered_objects.keys.each do |key|
  puts "   - #{key}"
end

# Check command bus registration
puts "🔧 Command bus registrations:"
puts "   Executable commands: #{Command::CommandBus.executable_commands.keys.count}"
puts "   Handler commands: #{Command::CommandBus.handlers.keys.count}"
```

### 2. Database Queries

```ruby
# Get RFC statistics
total_rfcs = Guidelines::RequestForComment.count
approved_rfcs = Guidelines::RequestForComment.joins(:approvals)
                                           .group('guidelines_request_for_comments.id')
                                           .having('COUNT(guidelines_approvals.id) >= 2')
                                           .count

puts "📊 RFC Statistics:"
puts "   Total RFCs: #{total_rfcs}"
puts "   Approved RFCs: #{approved_rfcs.count}"

# Get developer statistics
developer_stats = Guidelines::RequestForComment.group(:author_id)
                                               .count

puts "👥 Developer RFC counts:"
developer_stats.each do |developer_id, count|
  puts "   #{developer_id}: #{count} RFCs"
end
```

## 🎯 COMMON WORKFLOWS

### 1. Complete RFC Lifecycle

```ruby
# 1. Issue RFC
command = Guidelines::IssueRequestForComment.new(
  description: "Implement user authentication",
  developer_id: "dev-123"
)
command_bus.call(command)

# 2. Get the RFC
rfc = Guidelines::RequestForComment.last

# 3. Add approvals
rfc.approvals.create!(developer_id: "dev-456")
rfc.approvals.create!(developer_id: "dev-789")

# 4. Check final status
rfc.reload
if rfc.approvals.count >= 2
  puts "🎉 RFC is fully approved!"
  # Optionally trigger final approval
  final_command = Guidelines::ApproveRequestForComment.new(tid: rfc.tid)
  command_bus.call(final_command)
end
```

### 2. Bulk Operations

```ruby
# Approve multiple RFCs for a developer
Guidelines::RequestForComment.where(author_id: "dev-123").each do |rfc|
  rfc.approvals.create!(developer_id: "dev-456")
  puts "✅ Approved RFC #{rfc.number}"
end

# Get all RFCs needing approval
pending_rfcs = Guidelines::RequestForComment.joins(:approvals)
                                           .group('guidelines_request_for_comments.id')
                                           .having('COUNT(guidelines_approvals.id) < 2')

puts "📋 RFCs pending approval: #{pending_rfcs.count}"
```

## 🚨 ERROR HANDLING

### 1. Common Errors and Solutions

```ruby
# RFC not found
begin
  rfc = Guidelines::RequestForComment.find_by(number: "NON-EXISTENT")
  raise "RFC not found" unless rfc
rescue => e
  puts "❌ Error: #{e.message}"
end

# Invalid command
begin
  command = Guidelines::ApproveByDeveloper.new(tid: "", developer_id: "")
  command_bus.call(command)
rescue => e
  puts "❌ Command failed: #{e.message}"
end

# Database errors
begin
  # Try to create duplicate approval
  rfc.approvals.create!(developer_id: "dev-456")  # Already exists
rescue ActiveRecord::RecordInvalid => e
  puts "❌ Validation error: #{e.message}"
end
```

## 📚 NEXT STEPS

1. **Run the examples**: `ruby simple_usage_guide.rb`
2. **Open Rails console**: `rails console` and try the commands
3. **Test API endpoints**: Use curl or Postman
4. **Read full documentation**: `GUIDELINES_USAGE.md`
5. **Extend the module**: Add new features following the same patterns

## 🔧 CONFIGURATION

### Environment Setup

```ruby
# config/initializers/object_repository.rb
Rails.configuration.to_prepare do
  ObjectRepository.register(Guidelines::RequestForComment)
  ObjectRepository.register(Guidelines::Approval)
end
```

### ClickUp Integration (Optional)

```ruby
# config/initializers/click_up.rb
Rails.configuration.to_prepare do
  Rails.configuration.clickup = ClickUp::Adapter.new(
    api_key: Rails.application.credentials.dig(:click_up, :api_key)
  )
end
```

## 🎯 BEST PRACTICES

1. **Always use the command bus** for business operations
2. **Keep controllers thin** - only parse params and send commands
3. **Validate commands** before executing them
4. **Handle errors gracefully** with proper rescue blocks
5. **Use ObjectRepository** for domain object lookup
6. **Monitor event streams** for debugging and auditing

---

**🎉 You're now ready to use the Guidelines module!** 

Start with the simple examples in Rails console, then gradually move to more complex workflows using the command bus and API endpoints.

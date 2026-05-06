# Guidelines Module Usage Documentation

This document provides usage examples and documentation for the Guidelines module implementation following the Developer's Guide architecture.

## Overview

The Guidelines module implements a Request for Comment (RFC) system with the following features:
- Domain-driven design with event sourcing
- Command and query separation
- Process managers for complex workflows
- Read models for optimized queries
- Third-party integrations

## Core Components

### 1. Domain Events

```ruby
# RFC Issued Event
event = Guidelines::RfcIssued.strict(data: {
  tid: "Rfc$123",
  developer_id: "dev-456", 
  number: "RFC-2024-001"
})

# RFC Approved by Developer Event
event = Guidelines::RfcApprovedByDeveloper.strict(data: {
  tid: "Rfc$123",
  developer_id: "dev-456"
})

# RFC Approved Event
event = Guidelines::RfcApproved.strict(data: {
  tid: "Rfc$123"
})
```

### 2. Commands

#### Executable Commands (Self-registering)
```ruby
# Approve RFC by developer
command = Guidelines::ApproveByDeveloper.new(
  tid: "Rfc$123",
  developer_id: "dev-456"
)
command_bus.call(command)
```

#### Service Commands (Handled by Service)
```ruby
# Issue new RFC
command = Guidelines::IssueRequestForComment.new(
  description: "Add new authentication system",
  developer_id: "dev-456"
)
command_bus.call(command)

# Approve RFC (final approval)
command = Guidelines::ApproveRequestForComment.new(
  tid: "Rfc$123"
)
command_bus.call(command)
```

### 3. Business Domain Objects

```ruby
# Create RFC
rfc = Guidelines::RequestForComment.create!(
  number: "RFC-2024-001",
  description: "Implement OAuth2 authentication",
  author_id: "dev-456"
)

# Approve by developer
rfc.approve_by!("dev-789")

# Final approval
rfc.approve!

# Check approvals
rfc.approvals.count
```

### 4. Process Managers

The `RfcApprovalProcess` automatically handles RFC approval when sufficient developers approve:

```ruby
# This process manager automatically triggers final approval
# when 2 or more developers have approved an RFC
```

### 5. Read Models

```ruby
# Get RFC count by developer
count = ReadModels::NumberOfRfcIssuedByDeveloper::Count.find_by(developer_id: "dev-456")
puts "Developer has issued #{count.value} RFCs"
```

## Usage Examples

### Complete RFC Workflow

```ruby
# 1. Issue a new RFC
issue_command = Guidelines::IssueRequestForComment.new(
  description: "Add rate limiting to API endpoints",
  developer_id: "dev-456"
)
command_bus.call(issue_command)

# 2. Get the created RFC
rfc = Guidelines::RequestForComment.last
puts "Created RFC: #{rfc.number}"

# 3. First developer approves
approve_command = Guidelines::ApproveByDeveloper.new(
  tid: rfc.tid,
  developer_id: "dev-789"
)
command_bus.call(approve_command)

# 4. Second developer approves (triggers final approval)
approve_command2 = Guidelines::ApproveByDeveloper.new(
  tid: rfc.tid,
  developer_id: "dev-123"
)
command_bus.call(approve_command2)

# 5. Check final status
rfc.reload
puts "RFC is fully approved!" if rfc.approvals.count >= 2
```

### Webhook Integration

```ruby
# Webhook endpoint automatically processes incoming webhooks
POST /webhooks/some_service
{
  "event": "rfc_approved",
  "data": {
    "rfc_id": "Rfc$123"
  }
}
```

### Third-party Integration (ClickUp Example)

```ruby
# When RFC is approved, automatically creates ClickUp task
# This is handled by GuidelinesIntegrators::ScheduleCodeRefactorWhenRfcApproved
```

## Configuration

### Object Repository Registration

```ruby
# config/initializers/object_repository.rb
Rails.configuration.to_prepare do
  ObjectRepository.register(Guidelines::RequestForComment)
  ObjectRepository.register(Guidelines::Approval)
end
```

### ClickUp Integration

```ruby
# config/initializers/click_up.rb
Rails.configuration.to_prepare do
  Rails.configuration.clickup = ClickUp::Adapter.new(
    api_key: Rails.application.credentials.dig(:click_up, :api_key)
  )
end
```

### Test Environment

```ruby
# config/environments/test.rb
Rails.configuration.clickup = ClickUp::FakeAdapter.new
```

## Testing

### Running Tests

```bash
# Test the complete implementation
ruby test_guidelines_implementation.rb

# Run Rails tests
rails test

# Run specific Guidelines tests
rails test test/domain/guidelines/
```

### Rebuilding Read Models

```bash
# Rebuild RFC count for specific developer
ruby script/rebuild_rfc_count.rb dev-456
```

## Database Schema

### Tables Created

- `guidelines_request_for_comments` - RFC records
- `guidelines_approvals` - Developer approvals
- `number_of_rfc_issued_by_developers` - Read model for counts
- `incoming_webhooks` - Webhook processing

## Error Handling

The implementation includes comprehensive error handling:

```ruby
# Command validation errors
begin
  command_bus.call(invalid_command)
rescue Command::ValidationError => e
  puts "Validation failed: #{e.message}"
end

# Record not found errors
begin
  command_bus.call(Guidelines::ApproveByDeveloper.new(tid: "invalid", developer_id: "dev-456"))
rescue ActiveRecord::RecordNotFound => e
  puts "RFC not found: #{e.message}"
end
```

## Monitoring and Logging

All command executions are logged:

```
Command executed successfully: Guidelines::ApproveByDeveloper
Command execution failed: Guidelines::IssueRequestForComment - Validation failed
```

Errors are automatically reported to the error reporting service.

## Best Practices

1. **Always use the command bus** - Never call commands directly
2. **Keep controllers thin** - Only parse params and send commands
3. **Use read models for complex queries** - Don't query domain objects directly
4. **Handle webhooks asynchronously** - Store payload first, process later
5. **Test in isolation** - Use fake adapters for third-party integrations
6. **Monitor event streams** - Use event store for debugging and auditing

## Extending the Module

To add new features to the Guidelines module:

1. **Add new domain events** in `app/domain/guidelines.rb`
2. **Create commands** in `app/domain/guidelines/`
3. **Add process managers** for complex workflows
4. **Update read models** for new queries
5. **Register new handlers** in the subscriptions

## Troubleshooting

### Common Issues

1. **Table not found errors** - Ensure migrations are run
2. **Command not registered** - Check command bus registration
3. **Event not published** - Verify event store configuration
4. **Read model not updating** - Check async job processing

### Debug Commands

```ruby
# Check command bus registration
Command::CommandBus.executable_commands.keys
Command::CommandBus.handlers.keys

# Check event subscriptions
Guidelines.subscriptions
ApplicationSubscriptions.handlers

# Verify database tables
ActiveRecord::Base.connection.tables
```

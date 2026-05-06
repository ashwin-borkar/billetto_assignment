# Billetto Rails Assignment

A Ruby on Rails application that demonstrates event-driven architecture, external API integration, and voting functionality for events imported from the Billetto API.

## Features

- **Event Management**: Import and display events from Billetto API
- **Voting System**: Upvote/downvote events using Rails Event Store
- **Event-Driven Architecture**: Uses Rails Event Store for tracking voting events
- **Responsive UI**: Bootstrap-based interface for event browsing and voting
- **Comprehensive Testing**: RSpec tests for models, controllers, and integrations

## Requirements

- Ruby 3.2.2 (using RVM)
- PostgreSQL 12+
- Rails 8.1.2

## Setup Instructions

### 1. Environment Setup

```bash
# Install Ruby 3.2.2 using RVM
rvm install 3.2.2
rvm use 3.2.2

# Clone the repository
git clone <repository-url>
cd billetto_assignment

# Install dependencies
bundle install
```

### 2. Database Setup

```bash
# Create PostgreSQL databases
rails db:create

# Run migrations
rails db:migrate

# Optional: Seed with sample data
rails db:seed
```

### 3. Configuration

#### Database Credentials

The application is configured to use PostgreSQL with these credentials:
- Username: `postgres`
- Password: `Ashu@123`
- Host: `localhost`
- Port: `5432`

Database configuration is in `config/database.yml`.

#### Billetto API Setup

1. Create a Billetto account at [https://billetto.com](https://billetto.com)
2. Generate API credentials in your account settings
3. Add API key to Rails credentials:

```bash
rails credentials:edit
```

Add the following structure:

```yaml
billetto:
  api_key: your_billetto_api_key_here
```

### 4. Running the Application

```bash
# Start the Rails server
rails server

# Or use the provided script
./bin/dev
```

Visit `http://localhost:3000` to access the application.

## Usage

### Importing Events

1. Navigate to the application homepage
2. Click the "Import Events" button in the navigation bar
3. Events will be fetched from the Billetto API and stored in the database
4. Imported events will appear in the event listing

### Browsing Events

- **All Events**: View all imported events
- **Upcoming**: Filter for future events only
- **Past Events**: Filter for events that have already occurred

### Voting on Events

1. Click on any event to view details
2. Use the upvote/downvote buttons on the event detail page
3. Vote counts are updated in real-time
4. Voting events are stored in Rails Event Store for audit trail

## Architecture

### Domain Structure

The application follows the developer's guide with domain-driven design:

```
app/
├── domain/
│   └── events/
│       ├── voting_events.rb      # Domain events for voting
│       └── vote_command.rb       # Command for voting logic
├── integrations/
│   └── billetto.rb             # Billetto API client
├── jobs/
│   └── import_events_job.rb     # Background job for importing events
└── controllers/
    ├── events_controller.rb      # Main events controller
    └── admin/
        └── events_controller.rb # Admin import controller
```

### Event Store Integration

- **Events**: `EventUpvoted`, `EventDownvoted`
- **Commands**: `VoteCommand` for handling voting logic
- **Streams**: Events are stored in both event and user streams for traceability

### Database Schema

- **events**: Main event data from Billetto API
- **event_store_events**: Rails Event Store event data
- **event_store_streams**: Stream relationships
- **event_vote_counts**: Read model for vote counting

## Testing

### Running Tests

```bash
# Run all tests
rspec

# Run specific test suites
rspec spec/models
rspec spec/requests
rspec spec/integrations

# Run with coverage
rspec --format documentation
```

### Test Structure

- **Model Tests**: Event model validations and methods
- **Request Tests**: Controller actions and routing
- **Integration Tests**: External API interactions
- **Command Tests**: Voting command logic

## API Endpoints

### Public Endpoints

- `GET /` - Events listing (root)
- `GET /events` - Events with filtering
- `GET /events/:id` - Event details
- `POST /events/:id/upvote` - Upvote an event
- `POST /events/:id/downvote` - Downvote an event

### Admin Endpoints

- `POST /admin/events/import` - Import events from Billetto API

## Development

### Adding New Features

1. **Domain Events**: Add to `app/domain/events/voting_events.rb`
2. **Commands**: Create in `app/domain/events/`
3. **Integrations**: Add to `app/integrations/`
4. **Tests**: Follow existing patterns in `spec/`

### Code Quality

```bash
# Run linting
bundle exec rubocop

# Security audit
bundle exec brakeman

# Dependency audit
bundle exec bundler-audit
```

## Deployment

### Production Setup

1. Set up PostgreSQL database
2. Configure Rails credentials with production API keys
3. Set environment variables:
   - `RAILS_ENV=production`
   - `RAILS_MASTER_KEY` (from `config/master.key`)
   - `DATABASE_URL` (production database URL)

4. Run migrations:
   ```bash
   rails db:migrate RAILS_ENV=production
   ```

5. Precompile assets:
   ```bash
   rails assets:precompile RAILS_ENV=production
   ```

6. Start the application server in production mode.

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Ensure PostgreSQL is running
   - Verify database credentials in `config/database.yml`
   - Check database exists: `createdb billetto_assignment_development`

2. **API Import Fails**
   - Verify Billetto API key in Rails credentials
   - Check internet connectivity
   - Review logs: `tail -f log/development.log`

3. **Event Store Errors**
   - Run migrations: `rails db:migrate`
   - Ensure event store tables exist in database

### Logs

- Development: `log/development.log`
- Test: `log/test.log`
- Production: `log/production.log`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is created as part of the Billetto Rails Engineer Test assignment.
# billetto_assignment
<img width="1708" height="1008" alt="image" src="https://github.com/user-attachments/assets/4798755f-4e78-4685-879b-548f95b18b4d" /><img width="1708" height="1008" alt="image" src="https://github.com/user-attachments/assets/44573c0b-5eb4-4286-8cc8-176e76b2e04e" /><img width="1708" height="1008" alt="image" src="https://github.com/user-attachments/assets/5e53eca4-d6d5-421f-b353-82fb0f71bfd9" />
<img width="1708" height="1008" alt="image" src="https://github.com/user-attachments/assets/b4e18723-21a4-41a4-805b-c1b9c198cd64" />
<img width="1708" height="1008" alt="image" src="https://github.com/user-attachments/assets/00a8c82d-0f5d-45cf-b583-a87c342d6a93" />
<img width="1708" height="1008" alt="image" src="https://github.com/user-attachments/assets/18c26885-39ff-4f4c-8d91-5432ee73227d" />



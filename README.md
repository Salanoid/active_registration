# ActiveRegistration

A drop-in Rails engine that adds secure user registration with email confirmation to your rails 8+ application, that uses Rails Authentication Generator.

## Features

- 🚀 Registration flow (sign up, email confirmation)
- 📧 Email confirmation with token expiration
- 🧩 Easy integration with existing User models (from Rails Autehntication Generator)
- 🎨 Generated views for customization

## Installation

Add this line to your application's Gemfile:

```ruby
gem "active_registration"
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install active_registration
```

Run the installation generator:

```bash
rails generate active_registration:install
```

Apply database migrations:
```bash
rails db:migrate
```

## Configuration
### Development Environment

Add `letter_opener` to preview emails:

```ruby
# Gemfile
gem 'letter_opener', group: :development
```

Configure mailer settings:
```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { 
    host: 'localhost', 
    port: 3000 
  }
end
```

### Production Environment

Configure your SMTP settings:

```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.yourprovider.com',
  port:                 587,
  user_name:            ENV['SMTP_USER'],
  password:             ENV['SMTP_PASSWORD'],
  authentication:       :plain,
  enable_starttls_auto: true
}
```

## Contributing
Fork the project

Create your feature branch (git checkout -b feature/amazing-feature)

Commit your changes (git commit -m 'Add some amazing feature')

Push to the branch (git push origin feature/amazing-feature)

Open a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

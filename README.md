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
This generator will:
- Add necessary fields to your User model (confirmation_token, confirmation_sent_at, confirmed_at)
- Create a RegistrationsController for handling user registration
- Generate view templates for registration forms
- Add routes for registration and confirmation
- Create a ConfirmationMailer and associated views
- Inject necessary methods into your User model

Apply database migrations:
```bash
rails db:migrate
```
## What the Generator Does

The `active_registration:install` generator performs the following actions:

1. **Database Migration**: Adds confirmation-related fields to your users table:
   - `confirmation_token`: A unique token for email confirmation
   - `confirmation_sent_at`: When the confirmation email was sent
   - `confirmed_at`: When the user confirmed their email

2. **Controller Generation**: Creates a RegistrationsController that handles:
   - New user registration
   - Email confirmation

3. **View Generation**: Creates view templates for:
   - Registration form
   - Confirmation emails

4. **Route Configuration**: Adds routes for registration and confirmation:
   ```ruby
   resource :registration, only: [ :new, :create ] do
     get :confirm, on: :collection
   end
   ```

5. **Mailer Generation**: Creates a ConfirmationMailer for sending confirmation emails

6. **User Model Extension**: Adds methods to your User model:
   - `confirm!`: Confirms a user's email
   - `confirmed?`: Checks if a user is confirmed
   - `confirmation_period_valid?`: Checks if the confirmation token is still valid
   - `generate_confirmation_token`: Generates a secure confirmation token

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

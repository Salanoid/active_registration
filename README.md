# ActiveRegistration

Short description and motivation.

## Usage

How to use my plugin.

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

## Add this code to config/environments/development.rb
```ruby
Rails.application.configure do
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
end
```
## Contributing

Contribution directions go here.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

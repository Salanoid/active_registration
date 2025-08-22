# Changelog

## [0.2.0] - 2025-08-22
### Changed
- **BREAKING**: Generator now injects methods directly into user.rb instead of using UserExtensions module
- Follows Rails authentication generator pattern for better consistency
### Removed
- `UserExtensions` module (methods are now added directly to User model)

## [0.1.0] - 2025-04-05 (Initial Release)
### Added
- User registration system with email confirmation
- Generator for migrations, controllers, and views
- `UserExtensions` module
- Basic mailer setup for confirmation emails
- CI test configuration

---

*This project adheres to [Semantic Versioning](https://semver.org/).*

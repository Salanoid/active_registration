require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  setup do
    # Clear any existing users and reset the database state
    User.delete_all if defined?(User)
    ActionMailer::Base.deliveries.clear
  end

  test "successful user registration and confirmation flow" do
    # Visit the registration page
    get new_registration_path
    assert_response :success

    # Submit the registration form
    post registration_path, params: {
      user: {
        email_address: "user@example.org",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    # Should redirect to root with success message
    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Confirmation email sent!"

    # Check that user was created but not yet confirmed
    user = User.find_by(email_address: "user@example.org")
    assert user.present?
    assert_not user.confirmed?
    assert user.confirmation_token.present?
    assert user.confirmation_sent_at.present?

    # Check that confirmation email was sent
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal [ "user@example.org" ], email.to
    assert_includes email.subject.downcase, "confirm"

    # Extract confirmation token from user and simulate clicking confirmation link
    confirmation_token = user.confirmation_token
    get confirm_registration_path(token: confirmation_token)

    # Should redirect to root with confirmation message
    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Email confirmed!"

    # Check that user is now confirmed
    user.reload
    assert user.confirmed?
    assert_nil user.confirmation_token
    assert user.confirmed_at.present?
  end

  test "registration with invalid data shows errors" do
    # Submit empty form
    post registration_path, params: { user: { email_address: "", password: "", password_confirmation: "" } }

    # Should show validation errors and stay on registration page
    assert_response :unprocessable_content
    assert_includes response.body, "can&#39;t be blank"

    # Check that no user was created
    assert_equal 0, User.count

    # Check that no email was sent
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "registration with mismatched passwords shows error" do
    post registration_path, params: {
      user: {
        email_address: "user@example.org",
        password: "password123",
        password_confirmation: "different_password"
      }
    }

    # Should show password confirmation error
    assert_response :unprocessable_content
    assert_includes response.body, "doesn&#39;t match"

    # Check that no user was created
    assert_equal 0, User.count
  end

  test "registration with duplicate email shows error" do
    # Create an existing user
    User.create!(
      email_address: "existing@example.org",
      password: "password123",
      password_confirmation: "password123"
    )

    post registration_path, params: {
      user: {
        email_address: "existing@example.org",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    # Should show uniqueness error
    assert_response :unprocessable_content
    assert_includes response.body, "already been taken"

    # Check that only one user exists
    assert_equal 1, User.count
  end

  test "confirmation with invalid token shows error" do
    get confirm_registration_path(token: "invalid_token")

    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Invalid or expired confirmation link"
  end

  test "confirmation with expired token shows error" do
    # Create a user with an old confirmation timestamp
    user = User.create!(
      email_address: "user@example.org",
      password: "password123",
      password_confirmation: "password123"
    )

    # Manually set confirmation_sent_at to be older than 24 hours
    user.update_column(:confirmation_sent_at, 25.hours.ago)

    get confirm_registration_path(token: user.confirmation_token)

    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Invalid or expired confirmation link"

    # User should still not be confirmed
    user.reload
    assert_not user.confirmed?
  end

  test "already confirmed user cannot be confirmed again" do
    # Create and confirm a user
    user = User.create!(
      email_address: "user@example.org",
      password: "password123",
      password_confirmation: "password123"
    )
    user.confirm!
    original_confirmed_at = user.confirmed_at

    # Try to confirm again with the same token (now nil)
    get confirm_registration_path(token: "any_token")

    assert_redirected_to root_path
    follow_redirect!
    assert_includes response.body, "Invalid or expired confirmation link"

    # Confirmed timestamp should remain unchanged
    user.reload
    assert_equal original_confirmed_at.to_i, user.confirmed_at.to_i
  end
end

#!/usr/bin/env ruby
# bump_version.rb
#
# Usage:
#   ruby bump_version.rb
#
# This will automatically bump the version in:
#   - lib/active_registration/version.rb
#   - Gemfile.lock
#
# Example: 0.1.3 -> 0.1.4, ... 0.1.9 -> 0.2.0

version_file = "lib/active_registration/version.rb"
gemfile_lock = "Gemfile.lock"

unless File.exist?(version_file)
  puts "#{version_file} not found!"
  exit 1
end

content = File.read(version_file)
current_version = content[/VERSION\s*=\s*["'](\d+\.\d+\.\d+)["']/, 1]

if current_version.nil?
  puts "Could not find VERSION in #{version_file}"
  exit 1
end

major, minor, patch = current_version.split(".").map(&:to_i)

patch += 1
if patch >= 10
  patch = 0
  minor += 1
end

if minor >= 10
  minor = 0
  major += 1
end

new_version = "#{major}.#{minor}.#{patch}"

new_content = content.gsub(/VERSION\s*=\s*["']\d+\.\d+\.\d+["']/, "VERSION = \"#{new_version}\"")
File.write(version_file, new_content)
puts "Updated #{version_file} to VERSION = \"#{new_version}\""

if File.exist?(gemfile_lock)
  lock_content = File.read(gemfile_lock)
  updated_lock = lock_content.gsub(/active_registration \(\d+\.\d+\.\d+\)/, "active_registration (#{new_version})")

  if lock_content != updated_lock
    File.write(gemfile_lock, updated_lock)
    puts "Updated #{gemfile_lock} to active_registration (#{new_version})"
  else
    puts "No active_registration entry found in #{gemfile_lock}"
  end
else
  puts "#{gemfile_lock} not found, skipping"
end

puts "Bumped version: #{current_version} → #{new_version}"

run "git config user.name 'CI Bot'"
run "git config user.email 'ci@example.com'"
run "git add #{version_file} #{gemfile_lock}"
run "git commit -m 'Bump version to #{new_version}' || echo 'No changes to commit'"
run "git tag v#{new_version}"

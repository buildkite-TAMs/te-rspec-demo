require "buildkite/test_collector"

# Stream every RSpec run to Buildkite Test Engine.
# Requires BUILDKITE_ANALYTICS_TOKEN in the environment (see README.md).
Buildkite::TestCollector.configure(hook: :rspec)

require_relative "../lib/calculator"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  # Stable, unique descriptions keep Test Engine's test identity consistent.
  config.disable_monkey_patching!
end

# Deliberately flaky — passes roughly 70% of the time.
#
# Excluded from the default run so CI stays green and the loop is deterministic.
# Opt in with RUN_FLAKY_LAB=true to watch Test Engine's flaky-test detection
# light up after several builds. See the "Flaky-detection lab" in README.md.
return unless ENV["RUN_FLAKY_LAB"] == "true"

RSpec.describe "Flaky behaviour (intentional)" do
  it "sometimes passes, sometimes fails" do
    expect(rand(10)).to be < 7
  end
end

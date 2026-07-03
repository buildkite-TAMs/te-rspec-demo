# Test Engine Lab: RSpec (Ruby)

A hands-on lab that takes a plain RSpec suite and wires it into **Buildkite Test
Engine** using the official [`buildkite-test_collector`](https://github.com/buildkite/test-collector-ruby)
gem. By the end you'll have real test analytics — timings, pass/fail history,
and flaky-test detection — flowing into a Test Engine suite.

**Time:** ~15 minutes · **Level:** beginner · **Agent:** any Linux agent with Docker (`queue: aws`)

---

## What's in this repo

```
te-rspec-demo/
├── lib/calculator.rb          # trivial code under test
├── spec/
│   ├── spec_helper.rb         # ← the Test Engine wiring lives here
│   ├── calculator_spec.rb     # 6 passing examples
│   └── flaky_spec.rb          # opt-in flaky test for the stretch lab
├── Gemfile                    # adds the buildkite-test_collector gem
└── .buildkite/pipeline.yml    # runs rspec in ruby:3.3 and reports to Test Engine
```

The only line that connects RSpec to Test Engine is in `spec/spec_helper.rb`:

```ruby
require "buildkite/test_collector"
Buildkite::TestCollector.configure(hook: :rspec)
```

Everything else is a normal Ruby project.

---

## Lab steps

### 1. Create a Test Engine suite and grab its token

1. In Buildkite, go to **Test Engine → New suite**.
2. Name it `rspec-demo`, choose **RSpec** as the framework.
3. Copy the **API token** it shows you (this is your `BUILDKITE_ANALYTICS_TOKEN`).

### 2. Make the token available to the pipeline (as a Buildkite secret)

This repo uses **Buildkite secrets** — the token is stored encrypted in the
cluster and pulled at job start, never committed and never a plain env var.

1. Create a cluster secret holding the suite token. Its key **cannot** start with
   `BUILDKITE`/`BK`, so we call it `RSPEC_ANALYTICS_TOKEN`:

   ```bash
   curl -H "Authorization: Bearer $TOKEN" \
     -X POST "https://api.buildkite.com/v2/organizations/tam-sandbox/clusters/<CLUSTER_ID>/secrets" \
     -H "Content-Type: application/json" \
     -d '{
       "key": "RSPEC_ANALYTICS_TOKEN",
       "value": "<the suite api_token from step 1>",
       "policy": "- pipeline_slug: te-rspec-demo"
     }'
   ```
   (Or create it in the UI: **Cluster → Secrets → New secret**.)

2. The pipeline declares `secrets: [RSPEC_ANALYTICS_TOKEN]`, which injects it as a
   job env var. Because the collector specifically wants `BUILDKITE_ANALYTICS_TOKEN`,
   the step re-exports it:

   ```yaml
   command: |
     export BUILDKITE_ANALYTICS_TOKEN="$RSPEC_ANALYTICS_TOKEN"
     bundle exec rspec
   secrets:
     - RSPEC_ANALYTICS_TOKEN
   ```

   The `policy` scopes the secret to this pipeline only, and Buildkite redacts the
   value from build logs automatically.

### 3. Push this repo and create the pipeline

```sh
# from inside te-rspec-demo/
git init && git add . && git commit -m "RSpec + Test Engine demo"
git remote add origin git@github.com:buildkite-TAMs/te-rspec-demo.git
git push -u origin main
```

Create a pipeline pointing at the repo (the `.buildkite/pipeline.yml` is picked
up automatically).

### 4. Run a build

Trigger a build on `main`. Watch the `:rspec: RSpec → Test Engine` step:

```
--- :bundler: Installing gems
--- :rspec: Running specs
......
Finished in 0.0x seconds (files took 0.x seconds to load)
6 examples, 0 failures
```

### ✅ Checkpoint

- The build is **green** (6 examples, 0 failures).
- In **Test Engine → rspec-demo** you see a **run** for this build, with all 6
  tests, their durations, and the branch/commit/build attached.

If the run appears but has no branch/commit, the CI env isn't reaching the
collector — check that `propagate-environment: true` is set in the pipeline.

---

## Stretch lab: flaky-test detection

Test Engine spots tests that pass and fail without code changes. Let's create one.

1. Turn on the flaky test by setting an env var on the pipeline (or the build):

   ```
   RUN_FLAKY_LAB=true
   ```

   `spec/flaky_spec.rb` fails ~30% of the time on purpose.

2. Trigger the build **6–10 times** on `main` (Buildkite → **New Build**, or use
   a scheduled build). Some pass, some fail.

3. Open **Test Engine → rspec-demo → Flaky tests**. After a few mixed runs the
   `sometimes passes, sometimes fails` test is flagged **flaky**, with its
   reliability percentage and run history.

### 🎯 Stretch challenge

Add [execution tags](https://buildkite.com/docs/test-engine/test-collection/ruby-collectors)
to split results by team or suite. In `spec_helper.rb`:

```ruby
RSpec.configuration.before(:each) do |example|
  Buildkite::TestCollector.annotate("owner:payments")
end
```

Re-run and confirm you can filter by the tag in Test Engine.

---

## What you learned

- Test Engine collection is **one gem + one config line** — no rewrite of tests.
- Results are attributed to a build via the **Buildkite CI environment**, which
  is why `propagate-environment` matters when running inside Docker.
- Flaky detection needs **multiple runs** of the same test to build history.

**Talking point for customers:** the collector is additive and low-risk — it
hooks RSpec's reporter, so a token misconfiguration degrades gracefully (tests
still run, results just don't upload) rather than breaking the build.

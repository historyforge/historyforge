# Run locally using bin/ci. This does not create a GitHub Actions workflow.
CI.run do
  step 'Application checks', 'bin/check'
end

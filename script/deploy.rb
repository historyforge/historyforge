#!/usr/bin/env ruby
# Deliberately independent of Rails and its database.
require 'json'
require 'fileutils'
require 'shellwords'
require 'tempfile'
require 'time'

root = File.expand_path('..', __dir__)
config = JSON.parse(File.read(ENV.fetch('DEPLOY_CONFIG', File.join(root, 'config/deploy.json'))))
release = ARGV.shift
abort 'Supply an immutable IMAGE@sha256:DIGEST release.' unless release&.match?(%r{\A[a-zA-Z0-9][a-zA-Z0-9._:/-]*@sha256:[a-f0-9]{64}\z})
abort 'Release repository does not match configured image.' unless release.split('@').first == config.fetch('image')
installations = config.fetch('installations')
abort 'Inventory must contain unique installation names.' unless installations.map { |i| i.fetch('name') }.uniq.size == installations.size
abort 'Inventory lists the same app more than once.' unless installations.map { |i| i.values_at('host', 'app') }.uniq.size == installations.size
unknown = ARGV - installations.map { |i| i.fetch('name') }
abort "Unknown installations: #{unknown.join(', ')}" unless unknown.empty?
installations = installations.select { |i| ARGV.empty? || ARGV.include?(i.fetch('name')) }
abort 'No installations selected.' if installations.empty?
installations.each do |i|
  %w[name host app url].each { |key| i.fetch(key) }
  abort 'Invalid SSH host.' unless i['host'].match?(/\A[a-zA-Z0-9][a-zA-Z0-9@._-]*\z/)
  abort 'Invalid Dokku app.' unless i['app'].match?(/\A[a-z0-9][a-z0-9-]*\z/)
  abort 'Health URL must use HTTPS.' unless i['url'].start_with?('https://')
end
state_dir = ENV.fetch('DEPLOY_STATE_DIR', File.join(root, 'tmp/deploy'))
FileUtils.mkdir_p(state_dir)
File.open(File.join(state_dir, 'lock'), 'w') do |lock|
  abort 'Another deployment is running from this coordinator.' unless lock.flock(File::LOCK_EX | File::LOCK_NB)
  state_path = File.join(state_dir, 'releases.json')
  state = File.exist?(state_path) ? JSON.parse(File.read(state_path)) : {}
  save = lambda do
    File.write("#{state_path}.tmp", JSON.pretty_generate(state) + "\n")
    File.rename("#{state_path}.tmp", state_path)
  end
  state_lock = Mutex.new
  deploy = lambda do |installation, label|
    name, host, app, url = installation.values_at('name', 'host', 'app', 'url')
    key = "#{host}/#{app}"
    entry = state_lock.synchronize do
      record = state[key] ||= {}
      record.merge!('desired' => release, 'status' => 'deploying', 'updated_at' => Time.now.utc.iso8601)
      save.call
      puts "#{label}: #{name} (#{key}) -> #{release}"
      $stdout.flush
      record
    end
    # Override locale values forwarded by SSH (macOS may send LC_CTYPE=UTF-8).
    command = ['env', 'LANG=C.UTF-8', 'LC_ALL=C.UTF-8', 'LC_CTYPE=C.UTF-8',
               'dokku', 'git:from-image', app, release].shelljoin
    deployed = system('ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=15', host, command)
    healthy = deployed && Tempfile.create('health', state_dir) do |response|
      system('curl', '--fail', '--silent', '--show-error', '--max-time', '20',
             '--retry', '3', '--output', response.path, "#{url.sub(%r{/$}, '')}/check.txt") &&
        response.read.include?('simple_check')
    end
    state_lock.synchronize do
      if healthy
        if entry['successful'] != release
          entry['previous_successful'] = entry['successful']
          entry['successful'] = release
        end
        entry['status'] = 'verified'
      else
        entry['status'] = deployed ? 'verification_failed' : 'deploy_failed'
      end
      entry['updated_at'] = Time.now.utc.iso8601
      save.call
      if healthy
        puts "Verified: #{name} -> #{release}"
      else
        warn "FAILED: #{name}. Inspect Dokku logs and #{state_path}."
      end
    end
    healthy
  end

  canary, *remaining = installations
  abort 'Canary failed. Rollout stopped.' unless deploy.call(canary, 'Canary')

  workers = remaining.group_by { |installation| installation.fetch('host') }.values.map do |sites|
    Thread.new do
      sites.all? { |installation| deploy.call(installation, 'Deploying') }
    end
  end
  results = workers.map(&:value)
  abort 'Rollout failed on one or more hosts.' unless results.all?

  puts "Deployment completed for #{installations.size} installation(s). State: #{state_path}"
end

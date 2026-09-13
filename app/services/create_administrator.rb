# frozen_string_literal: true

require 'securerandom'

class CreateAdministrator
  def initialize(input: $stdin, output: $stdout)
    @input = input
    @output = output
  end

  def run
    user = User.new(login: prompt('User name'), email: prompt('Email'))
    user.role_ids = [Role.find_by(name: 'Administrator').id]
    password = SecureRandom.base64(24)
    user.password = user.password_confirmation = password
    user.confirmed_at = Time.current
    user.save!
    @output.puts "Administrator created: #{user.email}\nPassword: #{password}\nSave this password securely."
  end

  private

  def prompt(label)
    @output.puts "#{label}:"
    value = @input.gets&.strip
    raise ArgumentError, "#{label} is required. Run this command in an interactive terminal." if value.blank?

    value
  end
end

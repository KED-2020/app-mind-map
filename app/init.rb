# frozen_string_literal: true

folders = %w[application models infrastructure domain presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end

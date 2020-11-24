# frozen_string_literal: true

folders = %w[models infrastructure controllers domain presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end

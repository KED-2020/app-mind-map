# frozen_string_literal: true

folders = %w[inboxes favorites]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
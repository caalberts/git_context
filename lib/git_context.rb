# frozen_string_literal: true

require 'git_context/cli'
require 'git_context/commands'
require 'git_context/configuration'
require 'git_context/interaction'
require 'git_context/version'

module GitContext
  class Error < StandardError; end

  Context = Struct.new(:work_dir, :profile_name)
  Profile = Struct.new(:profile_name, :user)
  User = Struct.new(:name, :email)
end

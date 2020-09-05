require 'git_context/commands'
require 'git_context/configuration'
require 'git_context/version'

module GitContext
  class Error < StandardError; end

  Context = Struct.new(:work_dir, :profile)
  Profile = Struct.new(:profile_name, :user)
  User = Struct.new(:name, :email)
end

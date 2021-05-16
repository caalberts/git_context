# frozen_string_literal: true

require 'git_context/cli'
require 'git_context/commands'
require 'git_context/configuration'
require 'git_context/interaction'
require 'git_context/storage'
require 'git_context/version'

module GitContext
  GITCONFIG_FILE = '.gitconfig'
  BASE_STORAGE_DIR = '.gitcontext'
  CONFIG_FILE = 'config.yml'
  PROFILES_DIR = 'profiles'
  CONTEXTS_FILE = 'contexts'

  class Error < StandardError; end

  Context = Struct.new(:work_dir, :profile_name) do
    def serialize
      {
        'work_dir' => work_dir,
        'profile_name' => profile_name
      }
    end
  end

  Profile = Struct.new(:profile_name, :user) do
    def serialize
      {
        'profile_name' => profile_name,
        'name' => user.name,
        'email' => user.email,
        'signing_key' => user.signing_key
      }
    end
  end

  User = Struct.new(:name, :email, :signing_key)
end

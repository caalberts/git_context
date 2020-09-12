# frozen_string_literal: true

require 'tty-prompt'

module GitContext
  class Interaction
    def initialize(prompt = TTY::Prompt.new)
      @prompt = prompt
    end

    def prompt_work_dir(default_dir)
      @prompt.ask('Please enter working directory:', default: default_dir, required: true)
    end

    def prompt_profile(saved_profiles)
      @prompt.select('Please select from existing profiles:', saved_profiles, cycle: true)
    end

    def prompt_profile_name
      @prompt.ask('Please enter profile name:', required: true)
    end

    def prompt_user_info
      @prompt.collect do
        key(:name).ask('Please enter the name to be used in git config:')
        key(:email).ask('Please enter the name to be used in git config:')
        key(:signing_key).ask('Please enter the signing key to be used in git config:')
      end
    end

    def show(message)
      @prompt.say(message)
    end

    def info(message)
      @prompt.ok(message)
    end
  end
end

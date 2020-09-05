# frozen_string_literal: true
require 'tty-prompt'

module GitContext
  class Interaction
    def initialize(prompt = TTY::Prompt.new)
      @prompt = prompt
    end

    def prompt_work_dir
      @prompt.ask('Please enter working directory:')
    end

    def prompt_profile(saved_profiles)
      @prompt.select('Please select from existing profiles:', saved_profiles)
    end

    def prompt_profile_name
      @prompt.ask('Please enter profile name:')
    end

    def prompt_user_name
      @prompt.ask('Please enter the name to be used in git config:')
    end

    def prompt_user_email
      @prompt.ask('Please enter the email address to be used in git config:')
    end
  end
end

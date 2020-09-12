# frozen_string_literal: true

module GitContext
  module Commands
    class Help < Base
      USAGE = <<~USAGE
        Usage:
        git-context setup # initialize git-context in your home directory
        git-context create_profile # create a new profile to be used in gitconfig
        git-context create_context # create a new context to use a profile in git repositories within a directory
        git-context list_profile # list stored git-context profiles
      USAGE

      def call
        puts USAGE
      end
    end
  end
end

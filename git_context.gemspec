require_relative 'lib/git_context/version'

Gem::Specification.new do |spec|
  spec.name          = "git_context"
  spec.version       = GitContext::VERSION
  spec.authors       = ["Albert Salim"]
  spec.email         = ["albertlimca@gmail.com"]

  spec.summary       = %q{Manage directory specific git configs easily}
  spec.description   = %q{Manage directory specific git configs easily}
  spec.homepage      = "https://github.com/caalberts/git_context"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/caalberts/git_context"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'tty-prompt', '~> 0.22'
end

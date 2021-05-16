# frozen_string_literal: true

require 'aruba/rspec'

Aruba.configure do |config|
  config.home_directory = File.expand_path('../tmp/aruba', __dir__)
end

RSpec.describe 'git-context exe', type: :aruba do
  ENTER_KEY = "\n"
  DOWN_ARROW_KEY = "\033[B"

  include Aruba::Api

  let(:base_gitconfig) { <<~GITCONFIG }
    [user]
    \tname = John Doe
    \temail = john@email.com
  GITCONFIG

  let(:work_profile) do
    {
      profile_name: 'work',
      name: 'John Doe at Work',
      email: 'john@company.com',
      signing_key: 'ABCD1234'
    }
  end

  let(:home_profile) do
    {
      profile_name: 'home',
      name: 'Johnny',
      email: 'john@home.com',
      signing_key: 'XYZU7654'
    }
  end

  let(:work_context) do
    {
      work_dir: 'work',
      profile_name: work_profile[:profile_name]
    }
  end

  before do
    write_file(gitconfig, base_gitconfig)
  end

  it 'git-context setup, create profiles and context, delete profile', :aggregate_failures do
    setup

    aggregate_failures do
      expect(last_command_started).to be_successfully_executed
      expect(exist?(config_file)).to be true
      expect(exist?(gitcontext_profiles)).to be true
      expect(exist?(context_file)).to be true
      expect(gitconfig).to have_file_content(base_gitconfig + gitconfig_hook)
    end

    create_profile(work_profile)

    aggregate_failures do
      expect(last_command_started).to be_successfully_executed
      expect(config_file).to have_file_content(/#{yml_profile_entry(work_profile)}/)
      expect(profile_file(work_profile)).to have_file_content(git_profile_entry(work_profile))
    end

    create_profile(home_profile)

    aggregate_failures do
      expect(last_command_started).to be_successfully_executed
      expect(config_file).to have_file_content(/#{yml_profile_entry(work_profile)}/)
      expect(config_file).to have_file_content(/#{yml_profile_entry(home_profile)}/)
      expect(profile_file(work_profile)).to have_file_content(git_profile_entry(work_profile))
      expect(profile_file(home_profile)).to have_file_content(git_profile_entry(home_profile))
    end

    create_context(work_context, work_profile)

    aggregate_failures do
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started).to have_output(/#{home_profile[:profile_name]}\s+#{work_profile[:profile_name]}/)
      expect(config_file).to have_file_content(/#{yml_context_entry(work_context).strip}/)
      expect(context_file).to have_file_content(include_context_entry(work_context, work_profile))
    end

    delete_profile(home_profile)

    aggregate_failures do
      expect(last_command_started).to be_successfully_executed
      expect(config_file).to have_file_content(/#{yml_profile_entry(work_profile)}/)
      expect(config_file).not_to have_file_content(/#{yml_profile_entry(home_profile)}/)
      expect(exist?(profile_file(home_profile))).to be(false)
    end
  end

  def setup
    command = git_context_command('setup')

    run_command(command)
  end

  def create_profile(profile)
    command = git_context_command('create_profile')

    run_command(command) do |cmd|
      cmd.write(profile[:profile_name] + ENTER_KEY)
      cmd.write(profile[:name] + ENTER_KEY)
      cmd.write(profile[:email] + ENTER_KEY)
      cmd.write(profile[:signing_key] + ENTER_KEY)
    end
  end

  def create_context(context, _profile)
    command = git_context_command('create_context')

    run_command(command) do |cmd|
      cmd.write(context[:work_dir] + ENTER_KEY)
      cmd.write(DOWN_ARROW_KEY) # Select `work`
      cmd.write(ENTER_KEY)
    end
  end

  def delete_profile(_profile)
    command = git_context_command('delete_profile')

    run_command(command) do |cmd|
      cmd.write(ENTER_KEY) # Select `home`
    end
  end

  def gitconfig_hook
    <<~GITCONFIG_HOOK
      [include]
      \tpath = #{path_to_aruba_work_dir}/#{context_file}
    GITCONFIG_HOOK
  end

  def yml_profile_entry(profile)
    <<~PROFILE_ENTRY
      - profile_name: #{profile[:profile_name]}
        name: #{profile[:name]}
        email: #{profile[:email]}
        signing_key: #{profile[:signing_key]}
    PROFILE_ENTRY
  end

  def yml_context_entry(context)
    <<~CONTEXT_ENTRY
      - work_dir: #{context[:work_dir]}
        profile_name: #{context[:profile_name]}
    CONTEXT_ENTRY
  end

  def git_profile_entry(profile)
    <<~USER_ENTRY
      [user]
      \tname = #{profile[:name]}
      \temail = #{profile[:email]}
      \tsigningKey = #{profile[:signing_key]}
    USER_ENTRY
  end

  def include_context_entry(context, profile)
    <<~CONTEXT_ENTRY
      [includeIf "gitdir:#{context[:work_dir]}/"]
      \tpath = #{full_path_to(profile_file(profile))}
    CONTEXT_ENTRY
  end

  def git_context_command(subcommand)
    "ruby -Ilib #{File.expand_path('../../exe/git-context', Aruba.config.working_directory)} #{subcommand}"
  end

  def profile_file(profile)
    ".gitcontext/profiles/#{profile[:profile_name]}"
  end

  def config_file
    '.gitcontext/config.yml'
  end

  def context_file
    '.gitcontext/contexts'
  end

  def gitcontext_profiles
    '.gitcontext/profiles'
  end

  def gitconfig
    '.gitconfig'
  end

  def full_path_to(dest)
    "#{path_to_aruba_work_dir}/#{dest}"
  end

  def path_to_aruba_work_dir
    File.join(File.expand_path('../', __dir__), Aruba.config.working_directory)
  end
end

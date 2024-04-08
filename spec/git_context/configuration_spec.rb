# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitContext::ConfigData do
  let(:home) { Dir.mktmpdir }
  let(:gitcontext_dir) { File.join(home, '.gitcontext') }

  before do
    Dir.mkdir(gitcontext_dir)
  end

  describe '#serialize' do
    subject { config.serialize }

    let(:config) { described_class.new(home) }

    let(:user) { GitContext::User.new('John Doe', 'john@email.com', 'ABCD1234') }
    let(:profile) { GitContext::Profile.new('test_profile', user) }
    let(:context) { GitContext::Context.new('~/work', 'test_profile') }

    before do
      config.profiles << profile
      config.contexts << context
    end

    it 'serializes profiles into hash' do
      expect(subject['profiles']).to contain_exactly(
        {
          'profile_name' => 'test_profile',
          'name' => 'John Doe',
          'email' => 'john@email.com',
          'signing_key' => 'ABCD1234'
        }
      )
      expect(subject['contexts']).to contain_exactly(
        {
          'profile_name' => 'test_profile',
          'work_dir' => '~/work'
        }
      )
    end
  end
end

RSpec.describe GitContext::Configuration do
  let(:home) { Dir.mktmpdir }
  let(:user) { GitContext::User.new('John Doe', 'john@email.com', 'ABCD1234') }
  let(:profile) { GitContext::Profile.new('test_profile', user) }

  subject { described_class.new(home) }

  after do
    FileUtils.remove_entry(home)
  end

  describe '#setup' do
    let(:gitconfig_path) { File.join(home, '.gitconfig') }

    before do
      FileUtils.touch(gitconfig_path)
    end

    it 'creates config file' do
      subject.setup

      expect(FileTest.exist?(File.join(home, '.gitcontext/config.yml'))).to be_truthy
    end

    it 'creates contexts file' do
      subject.setup

      expect(FileTest.exist?(File.join(home, '.gitcontext/contexts'))).to be_truthy
    end

    it 'creates profiles directory' do
      subject.setup

      expect(FileTest.exist?(File.join(home, '.gitcontext/profiles'))).to be_truthy
    end

    it 'includes contexts file into ~/.gitconfig' do
      subject.setup

      gitconfig = File.read(gitconfig_path)
      expect(gitconfig).to include("[include]\n\tpath = #{home}/.gitcontext/contexts")
    end

    context 'with existing .gitcontext directory' do
      before do
        FileUtils.mkdir(File.join(home, '.gitcontext'))
      end

      it 'does not raise error' do
        expect { subject.setup }.not_to raise_error
      end
    end

    context 'with existing contexts file' do
      before do
        FileUtils.mkdir(File.join(home, '.gitcontext'))
        FileUtils.touch(File.join(home, '.gitcontext/contexts'))
      end

      it 'does not raise error' do
        expect { subject.setup }.not_to raise_error
      end
    end

    context 'with existing profiles directory' do
      before do
        FileUtils.mkdir_p(File.join(home, '.gitcontext/profiles'))
      end

      it 'does not raise error' do
        expect { subject.setup }.not_to raise_error
      end
    end

    context 'with repeated set up' do
      before do
        subject.setup
      end

      it 'only hooks into ~/.gitconfig once' do
        subject.setup

        gitconfig = File.read(gitconfig_path)
        expect(gitconfig.scan(%r{gitcontext/contexts}).count).to eq(1)
      end
    end
  end

  describe '#add_profile' do
    before do
      subject.setup
    end

    it 'adds profile to config data' do
      subject.add_profile(profile)

      expect(subject.config_data.profiles).to contain_exactly(profile)
    end

    it 'stores profile in config.yml' do
      subject.add_profile(profile)

      aggregate_failures do
        expect(yaml_content['profiles'].length).to eq(1)
        expect(yaml_content['profiles'].first['profile_name']).to eq(profile.profile_name)
        expect(yaml_content['profiles'].first['name']).to eq(profile.user.name)
        expect(yaml_content['profiles'].first['email']).to eq(profile.user.email)
        expect(yaml_content['profiles'].first['signing_key']).to eq(profile.user.signing_key)
      end
    end

    it 'creates a profile config' do
      subject.add_profile(profile)

      expect(FileTest.exist?("#{home}/.gitcontext/profiles/test_profile")).to be(true)
    end

    it 'stores user.name' do
      subject.add_profile(profile)

      content = File.read("#{home}/.gitcontext/profiles/test_profile")
      expect(content).to include('[user]')
      expect(content).to include('name = John Doe')
    end

    it 'stores user.email' do
      subject.add_profile(profile)

      content = File.read("#{home}/.gitcontext/profiles/test_profile")
      expect(content).to include('[user]')
      expect(content).to include('email = john@email.com')
    end

    it 'stores user.signingKey' do
      subject.add_profile(profile)

      content = File.read("#{home}/.gitcontext/profiles/test_profile")
      expect(content).to include('[user]')
      expect(content).to include('signingKey = ABCD1234')
    end
  end

  describe '#list_profile_names' do
    let(:profile_1) { GitContext::Profile.new('work', user) }
    let(:profile_2) { GitContext::Profile.new('personal', user) }

    before do
      subject.setup
      subject.add_profile(profile_1)
      subject.add_profile(profile_2)
    end

    it 'lists all stored profiles sorted alphabetically' do
      stored_profile_names = subject.list_profile_names

      expect(stored_profile_names).to eq(%w[personal work])
    end
  end

  describe '#delete_profile' do
    before do
      subject.setup
      subject.add_profile(profile)
    end

    it 'deletes profile from config data' do
      subject.delete_profile(profile.profile_name)

      expect(subject.config_data.profiles).not_to include(profile)
    end

    it 'stores profile in config.yml' do
      subject.delete_profile(profile.profile_name)

      expect(yaml_content['profiles'].length).to eq(0)
    end

    it 'deletes a saved profile config' do
      subject.delete_profile(profile.profile_name)

      expect(FileTest.exist?("#{home}/.gitcontext/profiles/#{profile.profile_name}")).to be(false)
    end
  end

  describe '#add_context' do
    let(:context) { GitContext::Context.new('/my/work/dir', 'test_profile') }

    before do
      subject.setup
    end

    it 'adds context to config data' do
      subject.add_context(context)

      expect(subject.config_data.contexts).to contain_exactly(context)
    end

    it 'adds context to config data in nested order' do
      context1 = GitContext::Context.new('/my/home/dir/a', 'home_profile')
      context2 = GitContext::Context.new('/my/home/dir', 'home_profile')
      context3 = GitContext::Context.new('/my/home/dir/b', 'home_profile')

      subject.add_context(context1)
      subject.add_context(context2)
      subject.add_context(context3)

      expect(subject.config_data.contexts).to eq([context2, context1, context3])
    end

    it 'stores profile in config.yml' do
      subject.add_context(context)

      aggregate_failures do
        expect(yaml_content['contexts'].length).to eq(1)
        expect(yaml_content['contexts'].first['profile_name']).to eq(context.profile_name)
        expect(yaml_content['contexts'].first['work_dir']).to eq(context.work_dir)
      end
    end

    it 'adds context to git config' do
      subject.add_context(context)

      content = File.read("#{home}/.gitcontext/contexts")
      expect(content).to include(%([includeIf "gitdir:/my/work/dir/"]\n\tpath = #{home}/.gitcontext/profiles/test_profile))
    end
  end

  def yaml_content
    @yaml_content ||= YAML.load_file(File.join(home, '.gitcontext/config.yml'))
  end
end

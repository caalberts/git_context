# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GitContext::Configuration do
  let(:home) { Dir.mktmpdir }
  let(:user) { GitContext::User.new('John Doe', 'john@email.com', 'ABCD1234') }
  let(:profile) { GitContext::Profile.new('test_profile', user) }

  subject { described_class.new(home) }

  after do
    FileUtils.remove_entry(home)
  end

  describe '#setup' do
    let(:gitconfig_path) { Pathname.new(home).join('.gitconfig') }

    before do
      FileUtils.touch(gitconfig_path)
    end

    it 'creates contexts file' do
      subject.setup

      expect(FileTest.exists?(Pathname.new(home).join('.gitcontext/contexts'))).to be_truthy
    end

    it 'creates profiles directory' do
      subject.setup

      expect(FileTest.exists?(Pathname.new(home).join('.gitcontext/profiles'))).to be_truthy
    end

    it 'includes contexts file into ~/.gitconfig' do
      subject.setup

      gitconfig = File.read(gitconfig_path)
      expect(gitconfig).to include("[include]\n\tpath = #{home}/.gitcontext/contexts")
    end

    context 'with existing .gitcontext directory' do
      before do
        FileUtils.mkdir(Pathname.new(home).join('.gitcontext'))
      end

      it 'does not raise error' do
        expect { subject.setup }.not_to raise_error
      end
    end

    context 'with existing contexts file' do
      before do
        FileUtils.mkdir(Pathname.new(home).join('.gitcontext'))
        FileUtils.touch(Pathname.new(home).join('.gitcontext/contexts'))
      end

      it 'does not raise error' do
        expect { subject.setup }.not_to raise_error
      end
    end

    context 'with existing profiles directory' do
      before do
        FileUtils.mkdir_p(Pathname.new(home).join('.gitcontext/profiles'))
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

    it 'lists all stored profiles' do
      stored_profile_names = subject.list_profile_names

      expect(stored_profile_names).to contain_exactly('work', 'personal')
    end
  end

  describe '#delete_profile' do
    before do
      subject.setup
      subject.add_profile(profile)
    end

    it 'deletes a saved profile config' do
      subject.delete_profile(profile)

      expect(FileTest.exist?("#{home}/.gitcontext/profiles/test_profile")).to be(false)
    end
  end

  describe '#add_context' do
    let(:context) { GitContext::Context.new('/my/work/dir', 'test_profile') }

    before do
      subject.setup
    end

    it 'adds context to git config' do
      subject.add_context(context)

      content = File.read("#{home}/.gitcontext/contexts")
      expect(content).to include(%([includeIf "gitdir:/my/work/dir/"]\n\tpath = #{home}/.gitcontext/profiles/test_profile))
    end
  end
end

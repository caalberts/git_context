# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Storage::YML do
  subject { described_class.new(config) }

  let(:home) { Dir.mktmpdir }
  let(:gitcontext_dir) { File.join(home, '.gitcontext') }
  let(:config) { GitContext::ConfigData.new(home) }

  before do
    Dir.mkdir(gitcontext_dir)
  end

  after do
    FileUtils.remove_entry(home)
  end

  describe '#setup' do
    it 'creates config file' do
      subject.setup

      expect(FileTest.exists?(File.join(home, '.gitcontext/config.yml'))).to be_truthy
    end
  end

  describe '#load' do
    context 'without existing config file' do
      it 'loads empty config' do
        subject.load

        expect(config.home).to eq(home)
        expect(config.profiles).to be_empty
        expect(config.contexts).to be_empty
      end
    end

    context 'with existing empty config file' do
      before do
        File.write(File.join(gitcontext_dir, 'config.yml'), <<~CONFIG_YAML)
          ---
        CONFIG_YAML
      end

      it 'loads empty config' do
        subject.load

        expect(config.home).to eq(home)
        expect(config.profiles).to be_empty
        expect(config.contexts).to be_empty
      end
    end

    context 'with existing config' do
      before do
        File.write(File.join(gitcontext_dir, 'config.yml'), <<~CONFIG_YAML)
          profiles:
            - profile_name: work
              name: John Doe
              email: john@work.com
              signing_key: ABCD1234
            - profile_name: home
              name: Johnny
              email: john@home.com
              signing_key: XYZA9876
            - profile_name: other
              name: Anon
              email: anon@anon.com
              signing_key: OOOO0000
          contexts:
            - work_dir: ~/work
              profile_name: work
            - work_dir: ~/home
              profile_name: home
        CONFIG_YAML
      end

      it 'loads existing config' do
        subject.load

        expect(config.home).to eq(home)
        expect(config.profiles.map(&:profile_name)).to eq(%w[work home other])
        expect(config.contexts.map(&:profile_name)).to eq(%w[work home])
      end
    end
  end

  describe '#save' do
    let(:user) { GitContext::User.new('John Doe', 'john@email.com', 'ABCD1234') }
    let(:profile) { GitContext::Profile.new('test_profile', user) }
    let(:context) { GitContext::Context.new('~/work', 'test_profile') }

    before do
      config.profiles << profile
      config.contexts << context
    end

    it 'saves config into yaml' do
      subject.save

      data = YAML.load_file(File.join(gitcontext_dir, 'config.yml'))

      expect(data['profiles'].length).to eq(1)
      expect(data['profiles'][0]['profile_name']).to eq('test_profile')
    end
  end
end

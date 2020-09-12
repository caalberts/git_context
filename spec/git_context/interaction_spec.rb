# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Interaction do
  let(:prompt) { instance_double(TTY::Prompt) }

  subject { described_class.new(prompt) }

  describe '#prompt_work_dir' do
    it 'asks user for work directory' do
      default_dir = '/work/dir'
      expect(prompt).to receive(:ask)
        .with('Please enter working directory:', default: default_dir)
        .and_return('/work/projects')

      input = subject.prompt_work_dir(default_dir)
      expect(input).to eq('/work/projects')
    end
  end

  describe '#prompt_profile' do
    it 'asks user to select a saved profile' do
      saved_profiles = %w[personal work]
      expect(prompt).to receive(:select)
        .with('Please select from existing profiles:', saved_profiles)
        .and_return('personal')

      input = subject.prompt_profile(saved_profiles)
      expect(input).to eq('personal')
    end
  end

  describe '#prompt_profile_name' do
    it 'asks user for a profile name' do
      expect(prompt).to receive(:ask)
        .with('Please enter profile name:')
        .and_return('personal')

      input = subject.prompt_profile_name
      expect(input).to eq('personal')
    end
  end

  describe '#prompt_user_name' do
    it 'asks user for name' do
      expect(prompt).to receive(:ask)
        .with('Please enter the name to be used in git config:')
        .and_return('John Doe')

      input = subject.prompt_user_name
      expect(input).to eq('John Doe')
    end
  end

  describe '#prompt_user_email' do
    it 'asks user for email address' do
      expect(prompt).to receive(:ask)
        .with('Please enter the email address to be used in git config:')
        .and_return('john@email.com')

      input = subject.prompt_user_email
      expect(input).to eq('john@email.com')
    end
  end

  describe '#prompt_user_signing_key' do
    it 'asks user for signing key' do
      expect(prompt).to receive(:ask)
        .with('Please enter the signing key to be used in git config:')
        .and_return('ABCD1234')

      input = subject.prompt_user_signing_key
      expect(input).to eq('ABCD1234')
    end
  end

  describe '#info' do
    it 'prints message' do
      message = 'success'

      expect { subject.info(message) }.to output(/#{message}/).to_stdout
    end
  end
end

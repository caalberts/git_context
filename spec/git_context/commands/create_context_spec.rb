# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Commands::CreateContext do
  let(:configuration) { instance_double(GitContext::Configuration) }
  let(:interaction) { instance_double(GitContext::Interaction) }
  let(:user) { GitContext::User.new(name: 'john', email: 'john@email.com') }
  let(:profile_names) { %w[work personal] }
  let(:profile_1) { GitContext::Profile.new('work', user) }
  let(:profile_2) { GitContext::Profile.new('personal', user) }
  let(:work_dir) { '/home/projects' }

  subject { described_class.new(configuration: configuration, interaction: interaction) }

  before do
    allow(interaction).to receive(:prompt_work_dir).and_return(work_dir)
    allow(interaction).to receive(:prompt_profile).and_return(profile_1)
    allow(interaction).to receive(:info).and_return(profile_1)
    allow(configuration).to receive(:list_profile_names).and_return(profile_names)
    allow(configuration).to receive(:add_context)
  end

  describe '#call' do
    it 'asks user for working directory to set context, defaulting to current work dir' do
      expect(interaction).to receive(:prompt_work_dir).with(Dir.pwd)

      subject.call
    end

    it 'checks for existing profiles in the config' do
      expect(configuration).to receive(:list_profile_names)

      subject.call
    end

    it 'asks user for which profile to use with the context' do
      expect(interaction).to receive(:prompt_profile).with(profile_names)

      subject.call
    end

    it 'adds context with given work_dir and profile to configuration' do
      expected_context = GitContext::Context.new(work_dir, profile_1)
      expect(configuration).to receive(:add_context).with(expected_context)

      subject.call
    end

    it 'informs user when context is created' do
      expect(interaction).to receive(:info).with(/#{profile_1.profile_name}.+#{work_dir}/)

      subject.call
    end
  end
end

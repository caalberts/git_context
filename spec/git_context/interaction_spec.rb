# frozen_string_literal: true

require 'spec_helper'
require 'tty/prompt/test'

RSpec.describe GitContext::Interaction do
  let(:prompt) { TTY::Prompt::Test.new }

  subject { described_class.new(prompt) }

  describe '#prompt_work_dir' do
    let(:default_dir) { '/default/dir' }

    it 'asks user for work directory' do
      simulate_prompt_input("/project\n")

      input = subject.prompt_work_dir(default_dir)
      expect(input).to eq('/project')
    end

    context 'when user chooses default' do
      it 'returns default value' do
        simulate_prompt_input("\n")

        input = subject.prompt_work_dir(default_dir)
        expect(input).to eq(default_dir)
      end
    end
  end

  describe '#prompt_profile' do
    it 'asks user to select a saved profile' do
      simulate_prompt_keydown(2)

      input = subject.prompt_profile(%w[personal work others])
      expect(input).to eq('others')
    end
  end

  describe '#prompt_profile_name' do
    it 'asks user for a profile name' do
      simulate_prompt_input("personal\n")

      input = subject.prompt_profile_name
      expect(input).to eq('personal')
    end
  end

  describe '#prompt_user_info' do
    it 'asks for user name, email address and signing key' do
      name = 'John Doe'
      email = ' john@email.com'
      signing_key = 'ABCD1234'

      simulate_prompt_input([name, email, signing_key].join("\n"))

      input = subject.prompt_user_info
      expect(input[:name]).to eq(name)
      expect(input[:email]).to eq(email)
      expect(input[:signing_key]).to eq(signing_key)
    end
  end

  describe '#show' do
    it 'prints message' do
      message = "hello\nworld"
      expect(prompt).to receive(:say).with(message)

      subject.show(message)
    end
  end

  describe '#info' do
    it 'prints formatted success message' do
      message = 'success'
      expect(prompt).to receive(:ok).with(message)

      subject.info(message)
    end
  end

  def simulate_prompt_keydown(count)
    prompt.on(:keypress) do |event|
      prompt.trigger(:keydown) if event.value == 'j'
    end

    prompt.input << "#{'j' * count}\n"
    prompt.input.rewind
  end

  def simulate_prompt_input(input)
    prompt.input << input
    prompt.input.rewind
  end
end

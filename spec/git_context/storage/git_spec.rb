# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitContext::Storage::Git do
  subject { described_class.new(config) }

  let(:home) { Dir.mktmpdir }
  let(:gitcontext_dir) { File.join(home, '.gitcontext') }
  let(:config) { GitContext::ConfigData.new(home) }
  let(:gitconfig_path) { File.join(home, '.gitconfig') }

  before do
    Dir.mkdir(gitcontext_dir)
  end

  describe '#setup' do
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

    context 'with existing contexts file' do
      before do
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

  describe '#reset' do
    let(:context) { GitContext::Context.new('/foo', 'bar') }

    before do
      subject.setup

      config.contexts << context
      subject.save
    end

    it 'empties contexts file' do
      subject.reset

      expect(File.read(File.join(home, '.gitcontext/contexts'))).to be_empty
    end

    it 'empties profiles directory' do
      subject.reset

      expect(Dir.empty?(File.join(home, '.gitcontext/profiles'))).to be_truthy
    end
  end
end

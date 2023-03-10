# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakeGitCrypt do
  it 'has a version number' do
    expect(RakeGitCrypt::VERSION).not_to be_nil
  end

  describe 'define_standard_tasks' do
    context 'when instantiating RakeGitCrypt::TaskSets::Standard' do
      it 'passes the provided block' do
        opts = {}

        block = lambda do |t|
          t.directory = './lib'
        end

        allow(RakeGitCrypt::TaskSets::Standard).to(receive(:define))

        described_class.define_standard_tasks(opts, &block)

        expect(RakeGitCrypt::TaskSets::Standard)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
    end
  end
end

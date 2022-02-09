# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Leftovers::FileCollector do
  subject(:collector) do
    collector = described_class.new(ruby, file)
    collector.collect
    collector
  end

  before do
    Leftovers.reset
    with_temp_dir
  end

  after { Leftovers.reset }

  let(:path) { 'foo.slim' }
  let(:file) do
    temp_file(path, slim)
    Leftovers::File.new(Leftovers.pwd + path)
  end
  let(:slim) { '' }
  let(:ruby) { file.ruby }

  context 'with slim files' do
    let(:slim) do
      <<~SLIM
        a
      SLIM
    end

    it { is_expected.to have_no_definitions.and(have_calls_including(:a, :to_s)) }
  end

  context 'with invalid slim files' do
    let(:slim) do
      <<~SLIM
        a text
          a text
      SLIM
    end

    it 'outputs an error and collects nothing' do
      expect { subject }.to output(a_string_including(<<~STDERR)).to_stderr
        \e[2KSlim::Parser::SyntaxError: Illegal nesting: content can't be both given on the same line as a and nested within it. foo.slim:1
      STDERR
      expect(subject).to have_no_definitions.and(have_no_calls)
    end
  end

  context 'with unavailable slim gem' do
    before do
      allow(Leftovers).to receive(:try_require_cache).and_call_original
      allow(Leftovers).to receive(:try_require_cache).with('slim').and_return(false)
    end

    let(:slim) do
      <<~slim
        a text
      slim
    end

    it 'raises an error' do
      expect { collector }.to output(a_string_including(<<~OUTPUT)).to_stderr
        \e[2KSkipped parsing foo.slim, because the slim gem was not available
        `gem install slim`
      OUTPUT

      expect(collector).to have_no_definitions.and(have_no_calls)
    end
  end

  context 'with slim files with hidden scripts' do
    let(:slim) do
      <<~SLIM
        - a
      SLIM
    end

    it { is_expected.to have_no_definitions.and(have_calls_including(:a)) }
  end

  context 'with slim files string interpolation' do
    let(:slim) do
      <<~SLIM
        before\#{a}after
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:a))
        .and(have_calls_excluding(:before, :after))
    end
  end

  context 'with slim files with ruby blocks' do
    let(:slim) do
      <<~SLIM
        :ruby
          a(1)
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:a))
        .and(have_calls_excluding(:ruby))
    end
  end

  context 'with slim files with dynamic attributes' do
    let(:slim) do
      <<~slim
        div{id: a}
      slim
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:a))
        .and(have_calls_excluding(:id, :div))
    end
  end

  context 'with slim files with whitespace-significant blocks' do
    let(:slim) do
      <<~SLIM
        - foo.each do |bar|
          = bar
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:foo, :each))
        .and(have_calls_excluding(:bar))
    end
  end

  context 'with slim files with echoed whitespace-significant blocks' do
    let(:slim) do
      <<~SLIM
        = form_for(whatever) do |bar|
          = bar
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:form_for, :whatever))
        .and(have_calls_excluding(:bar))
    end
  end
end

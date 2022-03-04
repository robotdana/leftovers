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
  end

  after { Leftovers.reset }

  let(:path) { 'foo.slim' }
  let(:file) do
    Leftovers::File.new(Leftovers.pwd + path).tap { |f| allow(f).to receive_messages(read: slim) }
  end
  let(:slim) { '' }
  let(:ruby) { file.ruby }

  context 'with slim files' do
    let(:slim) do
      <<~SLIM
        = foo
      SLIM
    end

    it { is_expected.to have_no_definitions.and(have_calls_including(:foo, :to_s)) }
  end

  context 'with invalid slim files' do
    let(:slim) do
      <<~SLIM
        div text
        fake:
          invalid
      SLIM
    end

    it 'outputs an error and collects nothing' do
      expect { subject }.to output(a_string_including(<<~STDERR)).to_stderr
        \e[2KSlim::Parser::SyntaxError: foo.slim:2:5 Expected tag
      STDERR
      expect(subject).to have_no_definitions.and(have_no_calls)
    end
  end

  context 'with slim files with hidden scripts' do
    let(:slim) do
      <<~SLIM
        - foo
      SLIM
    end

    it { is_expected.to have_no_definitions.and(have_calls_including(:foo)) }
  end

  context 'with slim files with string interpolation' do
    let(:slim) do
      <<~SLIM
        div before\#{foo}after
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:foo))
        .and(have_calls_excluding(:before, :after))
    end
  end

  context 'with slim files with ruby blocks' do
    let(:slim) do
      <<~SLIM
        ruby:
          foo(1)
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:foo))
        .and(have_calls_excluding(:ruby))
    end
  end

  context 'with slim files with dynamic attributes' do
    let(:slim) do
      <<~SLIM
        div id=foo
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:foo))
        .and(have_calls_excluding(:id, :div))
    end
  end

  context 'with slim files with static attributes' do
    let(:slim) do
      <<~SLIM
        div id="foo"
      SLIM
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_excluding(:foo, :id, :div))
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

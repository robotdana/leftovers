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

  let(:path) { 'foo.haml' }
  let(:file) do
    temp_file(path, haml)
    Leftovers::File.new(Leftovers.pwd + path)
  end
  let(:haml) { '' }
  let(:ruby) { file.ruby }

  context 'with haml files' do
    let(:haml) do
      <<~HAML
        = a
      HAML
    end

    it { is_expected.to have_no_definitions.and(have_calls_including(:a, :to_s)) }
  end

  context 'with invalid haml files' do
    let(:haml) do
      <<~HAML
        %a text
          %a text
      HAML
    end

    it 'outputs an error and collects nothing' do
      expect { subject }.to output(a_string_including(<<~STDERR)).to_stderr
        \e[2KHaml::SyntaxError: foo.haml:1 Illegal nesting: content can't be both given on the same line as %a and nested within it.
      STDERR
      expect(subject).to have_no_definitions.and(have_no_calls)
    end
  end

  context 'with haml files with hidden scripts' do
    let(:haml) do
      <<~HAML
        - a
      HAML
    end

    it { is_expected.to have_no_definitions.and(have_calls_including(:a)) }
  end

  context 'with haml files string interpolation' do
    let(:haml) do
      <<~HAML
        before\#{a}after
      HAML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:a))
        .and(have_calls_excluding(:before, :after))
    end
  end

  context 'with haml files with ruby blocks' do
    let(:haml) do
      <<~HAML
        :ruby
          a(1)
      HAML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:a))
        .and(have_calls_excluding(:ruby))
    end
  end

  context 'with haml files with dynamic attributes' do
    let(:haml) do
      <<~HAML
        %div{id: a}
      HAML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:a))
        .and(have_calls_excluding(:id, :div))
    end
  end

  context 'with haml files with whitespace-significant blocks' do
    let(:haml) do
      <<~HAML
        - foo.each do |bar|
          = bar
      HAML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:foo, :each))
        .and(have_calls_excluding(:bar))
    end
  end

  context 'with haml files with echoed whitespace-significant blocks' do
    let(:haml) do
      <<~HAML
        = form_for(whatever) do |bar|
          = bar
      HAML
    end

    it do
      expect(subject).to have_no_definitions
        .and(have_calls_including(:form_for, :whatever))
        .and(have_calls_excluding(:bar))
    end
  end
end

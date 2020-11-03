# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'audited gem' do
  subject(:collector) do
    collector = ::Leftovers::FileCollector.new(ruby, file)
    collector.collect
    collector
  end

  before do
    Leftovers.reset
    Leftovers.config << :audited
  end

  after { Leftovers.reset }

  let(:path) { 'foo.rb' }
  let(:file) { ::Leftovers::File.new(Leftovers.pwd + path) }
  let(:ruby) { '' }

  context 'with current_user_method=' do
    let(:ruby) { 'Audited.current_user_method = :authenticated_user' }

    it do
      expect(subject).to have_no_definitions
        .and have_calls(:Audited, :current_user_method=, :authenticated_user)
    end
  end

  context 'with associated_with' do
    let(:ruby) { 'audited associated_with: :company' }

    it { is_expected.to have_no_definitions.and have_calls(:audited, :company) }
  end

  context 'with if' do
    let(:ruby) { 'audited if: :active?' }

    it { is_expected.to have_no_definitions.and have_calls(:audited, :active?) }
  end

  context 'with unless' do
    let(:ruby) { 'audited unless: :active?' }

    it { is_expected.to have_no_definitions.and have_calls(:audited, :active?) }
  end

  context 'with only:/except:' do
    let(:ruby) { 'audited only: :name, except: :password' }

    it { is_expected.to have_no_definitions.and have_calls(:audited) }
  end
end

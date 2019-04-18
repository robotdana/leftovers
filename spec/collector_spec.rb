require 'spec_helper'

RSpec.describe Forgotten::Collector do
  around { |example| with_temp_dir { example.run } }

  it 'collects method definitions' do
    temp_file 'foo.rb', 'def m(a) a end'

    subject.collect

    expect(subject.method_definitions).to match [start_with(:m)]
  end

  it 'collects method calls in optional arguments' do
    temp_file 'foo.rb', 'def m(a = b) a end'

    subject.collect

    expect(subject.method_definitions).to match [start_with(:m)]
    expect(subject.maybe_method_calls).to eq [:b]
  end

  it 'collects method calls that match a previously defined lvar' do
    temp_file 'foo.rb', 'def m(a) self.a end'

    subject.collect

    expect(subject.method_definitions).to match [start_with(:m)]
    expect(subject.maybe_method_calls).to eq [:a]
  end

  it 'collects method calls that match a previously defined lvar in a different context' do
    temp_file 'foo.rb', 'def m(a) nil end; a'

    subject.collect

    expect(subject.method_definitions).to match [start_with(:m)]
    expect(subject.maybe_method_calls).to eq [:a]
  end

  it 'collects constant references' do
    temp_file 'foo.rb', 'Whatever.new'

    subject.collect

    expect(subject.maybe_constant_references).to eq [:Whatever]
    expect(subject.constant_definitions).to be_empty
  end

  it 'collects class definitions' do
    temp_file 'foo.rb', 'class Whatever; end'

    subject.collect

    expect(subject.constant_definitions).to match [start_with(:Whatever)]
    expect(subject.maybe_constant_references).to be_empty
  end

  it 'collects class definitions and constant calls to the inheritance class' do
    temp_file 'foo.rb', 'class Whatever < SuperClass; end'

    subject.collect

    expect(subject.constant_definitions).to match [start_with(:Whatever)]
    expect(subject.maybe_constant_references).to eq [:SuperClass]
  end

  it 'collects module definitions' do
    temp_file 'foo.rb', 'module Whatever; end'

    subject.collect

    expect(subject.constant_definitions).to match [start_with(:Whatever)]
    expect(subject.maybe_constant_references).to be_empty
  end

  it 'collects constant assignment' do
    temp_file 'foo.rb', 'Whatever = Class.new'

    subject.collect

    expect(subject.constant_definitions).to match [start_with(:Whatever)]
    expect(subject.maybe_constant_references).to eq [:Class]
  end
end

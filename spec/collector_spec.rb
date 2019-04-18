require 'spec_helper'

RSpec::Matchers.define_negated_matcher :exclude, :include
RSpec.describe Forgotten::Collector do
  around { |example| with_temp_dir { example.run } }

  it 'collects method definitions' do
    temp_file 'foo.rb', 'def m(a) a end'

    subject.collect

    expect(subject.definitions).to match [start_with(:m)]
  end

  it 'collects method calls in optional arguments' do
    temp_file 'foo.rb', 'def m(a = b) a end'

    subject.collect

    expect(subject.definitions).to match [start_with(:m)]
    expect(subject.calls).to match [:b]
  end

  it 'collects method calls that match a previously defined lvar' do
    temp_file 'foo.rb', 'def m(a) self.a end'

    subject.collect

    expect(subject.definitions).to match [start_with(:m)]
    expect(subject.calls).to match [:a]
  end

  it 'collects method calls that match a previously defined lvar in a different context' do
    temp_file 'foo.rb', 'def m(a) nil end; a'

    subject.collect

    expect(subject.definitions).to match [start_with(:m)]
    expect(subject.calls).to match [:a]
  end

  it 'collects constant references' do
    temp_file 'foo.rb', 'Whatever.new'

    subject.collect

    expect(subject.calls).to contain_exactly :Whatever, :new
    expect(subject.definitions).to be_empty
  end

  it 'collects class definitions' do
    temp_file 'foo.rb', 'class Whatever; end'

    subject.collect

    expect(subject.definitions).to match [start_with(:Whatever)]
    expect(subject.calls).to be_empty
  end

  it 'collects class definitions and constant calls to the inheritance class' do
    temp_file 'foo.rb', 'class Whatever < SuperClass; end'

    subject.collect

    expect(subject.definitions).to match [start_with(:Whatever)]
    expect(subject.calls).to contain_exactly :SuperClass
  end

  it 'collects module definitions' do
    temp_file 'foo.rb', 'module Whatever; end'

    subject.collect

    expect(subject.definitions).to match [start_with(:Whatever)]
    expect(subject.calls).to be_empty
  end

  it 'collects constant assignment' do
    temp_file 'foo.rb', 'Whatever = Class.new'

    subject.collect

    expect(subject.definitions).to match [start_with(:Whatever)]
    expect(subject.calls).to contain_exactly :Class, :new
  end

  it 'collects haml files' do
    temp_file 'foo.haml', '= a'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a)
  end

  it 'collects haml files with hidden scripts' do
    temp_file 'foo.haml', '- a'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to contain_exactly :a
  end

  it 'collects haml files string interpolation' do
    temp_file 'foo.haml', 'before#{a}after'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a).and(exclude(:before, :after))
  end

  it 'collects haml files with ruby blocks' do
    temp_file 'foo.haml', <<~HAML
      :ruby
        a(1)
    HAML


    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a).and(exclude(:ruby))
  end

  it 'collects haml files with dynamic attributes' do
    temp_file 'foo.haml', '%div{id: a}'

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:a).and(exclude(:id, :div))
  end

  it 'collects haml files with whitespace-significant blocks' do
    temp_file 'foo.haml', <<~HAML
      - foo.each do |bar|
        = bar
    HAML

    subject.collect

    expect(subject.definitions).to be_empty
    expect(subject.calls).to include(:foo, :each).and(exclude(:bar))
  end

  it 'collects erb files' do
    temp_file 'foo.erb', '<a href="<%= whatever %>">label</a>'

    subject.collect

    expect(subject.definitions).to be_empty
    # the extra options are internal erb stuff and i don't mind
    expect(subject.calls).to include(:whatever).and(exclude(:a, :href, :label))
  end

  it 'collects erb files when newline trimmed' do
    temp_file 'foo.erb', <<~ERB
      <%- if foo.present? -%>
        <a href="<%= foo %>">label</a>
      <%- end -%>
    ERB

    subject.collect

    expect(subject.definitions).to be_empty
    # the extra options are internal erb stuff and i don't mind
    expect(subject.calls).to include(:foo, :present?).and(exclude(:a, :href, :label))
  end
end

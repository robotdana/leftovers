# frozen_string_literal: true

RSpec.describe Leftovers::AST::Node do
  let(:send_node) { Leftovers::Parser.parse_with_comments('foo()').first }
  let(:send_then_send_node) { Leftovers::Parser.parse_with_comments('foo().bar()').first }
  let(:const_then_send_node) { Leftovers::Parser.parse_with_comments('Foo.bar()').first }
  let(:csend_node) { Leftovers::Parser.parse_with_comments('true&.foo()').first }
  let(:send_then_csend_node) { Leftovers::Parser.parse_with_comments('foo()&.bar()').first }
  let(:true_node) { Leftovers::Parser.parse_with_comments('true').first }
  let(:false_node) { Leftovers::Parser.parse_with_comments('false').first }
  let(:nil_node) { Leftovers::Parser.parse_with_comments('nil').first }
  let(:str_node) { Leftovers::Parser.parse_with_comments('"foo"').first }
  let(:sym_node) { Leftovers::Parser.parse_with_comments(':foo').first }
  let(:constant_node) { Leftovers::Parser.parse_with_comments('FOO = true').first }
  let(:const_then_const_node) { Leftovers::Parser.parse_with_comments('Foo::Bar').first }
  let(:def_node) { Leftovers::Parser.parse_with_comments('def foo; end').first }
  let(:ivar_node) { Leftovers::Parser.parse_with_comments('@foo').first }
  let(:ivasgn_node) { Leftovers::Parser.parse_with_comments('@foo = true').first }
  let(:cvar_node) { Leftovers::Parser.parse_with_comments('@@foo').first }
  let(:cvasgn_node) { Leftovers::Parser.parse_with_comments('@@foo = true').first }
  let(:gvar_node) { Leftovers::Parser.parse_with_comments('$foo').first }
  let(:gvasgn_node) { Leftovers::Parser.parse_with_comments('$foo = true').first }
  let(:class_node) { Leftovers::Parser.parse_with_comments('class Foo; end').first }
  let(:module_node) { Leftovers::Parser.parse_with_comments('module Foo; end').first }
  let(:integer_node) { Leftovers::Parser.parse_with_comments('1').first }
  let(:float_node) { Leftovers::Parser.parse_with_comments('1.0').first }
  let(:proc_node) { Leftovers::Parser.parse_with_comments('proc {}').first }
  let(:lambda_node) { Leftovers::Parser.parse_with_comments('lambda {}').first }
  let(:do_end_lambda_node) { Leftovers::Parser.parse_with_comments('lambda do; end').first }
  let(:stabby_lambda_node) { Leftovers::Parser.parse_with_comments('-> {}').first }

  describe '#to_s' do
    it 'provides a string representation' do
      expect(send_node.to_s).to eq 'foo'
      expect(str_node.to_s).to eq 'foo'
      expect(sym_node.to_s).to eq 'foo'
      expect(csend_node.to_s).to eq 'foo'
      expect(true_node.to_s).to eq 'true'
      expect(false_node.to_s).to eq 'false'
      expect(nil_node.to_s).to eq ''
      expect(constant_node.to_s).to eq 'FOO'
      expect(const_then_const_node.to_s).to eq 'Bar'
      expect(def_node.to_s).to eq 'foo'
      expect(ivar_node.to_s).to eq '@foo'
      expect(ivasgn_node.to_s).to eq '@foo'
      expect(cvar_node.to_s).to eq '@@foo'
      expect(cvasgn_node.to_s).to eq '@@foo'
      expect(gvar_node.to_s).to eq '$foo'
      expect(gvasgn_node.to_s).to eq '$foo'
      expect(class_node.to_s).to eq 'Foo'
      expect(module_node.to_s).to eq 'Foo'
      expect(integer_node.to_s).to eq '1'
      expect(float_node.to_s).to eq '1.0'
      expect(proc_node.to_s).to eq ''
    end
  end

  describe '#to_sym' do
    it 'provides a sym' do
      expect(send_node.to_sym).to eq :foo
      expect(str_node.to_sym).to eq :foo
      expect(sym_node.to_sym).to eq :foo
      expect(csend_node.to_sym).to eq :foo
      expect(true_node.to_sym).to eq :true
      expect(false_node.to_sym).to eq :false
      expect(nil_node.to_sym).to eq :nil
      expect(constant_node.to_sym).to eq :FOO
      expect(def_node.to_sym).to eq :foo
      expect(ivar_node.to_sym).to eq :@foo
      expect(ivasgn_node.to_sym).to eq :@foo
      expect(cvar_node.to_sym).to eq :@@foo
      expect(cvasgn_node.to_sym).to eq :@@foo
      expect(gvar_node.to_sym).to eq :$foo
      expect(gvasgn_node.to_sym).to eq :$foo
      expect(class_node.to_sym).to eq :Foo
      expect(module_node.to_sym).to eq :Foo
      expect(integer_node.to_sym).to eq :'1'
      expect(float_node.to_sym).to eq :'1.0'
      expect(proc_node.to_sym).to eq :''
    end
  end

  describe '#name' do
    it 'provides a name if it makes sense to do so' do
      expect(send_node.name).to eq :foo
      expect(csend_node.name).to eq :foo
      expect(true_node.name).to be_nil
      expect(false_node.name).to be_nil
      expect(nil_node.name).to be_nil
      expect(str_node.name).to eq :foo
      expect(sym_node.name).to eq :foo
      expect(constant_node.name).to eq :FOO
      expect(def_node.name).to eq :foo
      expect(ivar_node.name).to eq :@foo
      expect(ivasgn_node.name).to eq :@foo
      expect(cvar_node.name).to eq :@@foo
      expect(cvasgn_node.name).to eq :@@foo
      expect(gvar_node.name).to eq :$foo
      expect(gvasgn_node.name).to eq :$foo
      expect(class_node.name).to eq :Foo
      expect(module_node.name).to eq :Foo
      expect(integer_node.name).to be_nil
      expect(float_node.name).to be_nil
    end
  end

  describe '#to_scalar_value' do
    it 'provides a scalar value if it makes sense to do so' do
      expect(send_node.to_scalar_value).to be_nil
      expect(csend_node.to_scalar_value).to be_nil
      expect(true_node.to_scalar_value).to be true
      expect(false_node.to_scalar_value).to be false
      expect(nil_node.to_scalar_value).to be_nil
      expect(str_node.to_scalar_value).to eq 'foo'
      expect(sym_node.to_scalar_value).to eq :foo
      expect(constant_node.to_scalar_value).to be_nil
      expect(def_node.to_scalar_value).to be_nil
      expect(ivar_node.to_scalar_value).to be_nil
      expect(ivasgn_node.to_scalar_value).to be_nil
      expect(cvar_node.to_scalar_value).to be_nil
      expect(cvasgn_node.to_scalar_value).to be_nil
      expect(gvar_node.to_scalar_value).to be_nil
      expect(gvasgn_node.to_scalar_value).to be_nil
      expect(class_node.to_scalar_value).to be_nil
      expect(module_node.to_scalar_value).to be_nil
      expect(integer_node.to_scalar_value).to eq 1
      expect(float_node.to_scalar_value).to eq 1.0
    end
  end

  describe '#scalar?' do
    it 'responds to scalar?' do
      expect(send_node).not_to be_scalar
      expect(csend_node).not_to be_scalar
      expect(true_node).to be_scalar
      expect(false_node).to be_scalar
      expect(nil_node).to be_scalar
      expect(str_node).to be_scalar
      expect(sym_node).to be_scalar
      expect(constant_node).not_to be_scalar
      expect(def_node).not_to be_scalar
      expect(ivar_node).not_to be_scalar
      expect(ivasgn_node).not_to be_scalar
      expect(cvar_node).not_to be_scalar
      expect(cvasgn_node).not_to be_scalar
      expect(gvar_node).not_to be_scalar
      expect(gvasgn_node).not_to be_scalar
      expect(class_node).not_to be_scalar
      expect(module_node).not_to be_scalar
      expect(integer_node).to be_scalar
      expect(float_node).to be_scalar
    end
  end

  describe '#proc?' do
    it 'responds to proc?' do
      expect(proc_node).to be_proc
      expect(lambda_node).to be_proc
      expect(do_end_lambda_node).to be_proc
      expect(stabby_lambda_node).to be_proc
      expect(send_node).not_to be_proc
    end
  end

  describe 'receiver' do
    it 'responds to receiver', :aggregate_failures do
      expect(true_node.receiver).to be_nil
      expect(send_node.receiver).to be_nil
      expect(const_then_send_node.receiver.name).to eq :Foo
      expect(const_then_const_node.receiver.name).to eq :Foo
      expect(send_then_send_node.receiver.name).to eq :foo
      expect(send_then_csend_node.receiver.name).to eq :foo
    end
  end
end

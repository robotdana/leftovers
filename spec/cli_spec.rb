# frozen_string_literal: true

require_relative '../lib/leftovers/cli'
require 'parallel'

RSpec.describe Leftovers::CLI, type: :cli do
  describe 'leftovers' do
    before { with_temp_dir }

    context 'with no files' do
      it 'runs' do
        run
        expect(stdout).to have_output <<~STDOUT
          checked 0 files, collected 0 calls, 0 definitions
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 0
      end

      it 'outputs the version when --version' do
        run '--version'
        expect(stdout).to have_output <<~STDOUT
          #{Leftovers::VERSION}
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 0
      end

      it 'outputs no files when --dry-run' do
        run '--dry-run'
        expect(stdout.string).to be_empty
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 0
      end

      it 'outputs the files when --help' do
        run '--help'
        expect(stdout).to have_output <<~STDOUT
          Usage: leftovers [options]
                  --[no-]parallel              Run in parallel or not, default --parallel
                  --[no-]progress              Show progress counts or not, default --progress
              -v, --version                    Returns the current version
                  --dry-run                    Output files that will be looked at
              -h, --help                       Shows this message
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 0
      end
    end

    context 'with files with linked config' do
      before do
        temp_file '.leftovers.yml', <<~YML
          rules:
            - name: test_method
              defines:
                argument: 1
                linked_transforms:
                  - original
                  - add_suffix: '?'
        YML

        temp_file 'app/foo.rb', <<~RUBY
          test_method :test
        RUBY
      end

      it 'runs' do
        run

        expect(stdout).to have_output <<~STDOUT
          checked 1 files, collected 1 calls, 1 definitions
          \e[31mNot directly called at all:\e[0m
          \e[36mapp/foo.rb:1:12\e[0m test, test? \e[2mtest_method \e[33m:test\e[0;2m\e[0m
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 1
      end
    end

    context 'with files with unused methods' do
      before do
        temp_file('app/foo.rb', <<~RUBY)
          attr_reader :foo

          def unused_method
            @bar = true
          end
        RUBY
      end

      it 'runs' do
        expect(Parallel).to receive(:each).once.and_call_original # parallel by default

        run

        expect(stdout).to have_output <<~STDOUT
          checked 1 files, collected 2 calls, 3 definitions
          \e[31mNot directly called at all:\e[0m
          \e[36mapp/foo.rb:1:12\e[0m foo \e[2mattr_reader \e[33m:foo\e[0;2m\e[0m
          \e[36mapp/foo.rb:3:4\e[0m unused_method \e[2mdef \e[33munused_method\e[0;2m\e[0m
          \e[36mapp/foo.rb:4:2\e[0m @bar \e[2m\e[33m@bar\e[0;2m = true\e[0m
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 1
      end

      it 'runs with --no-parallel' do
        expect(Parallel).to receive(:each).exactly(0).times

        run('--no-parallel')

        expect(stdout).to have_output <<~STDOUT
          checked 1 files, collected 2 calls, 3 definitions
          \e[31mNot directly called at all:\e[0m
          \e[36mapp/foo.rb:1:12\e[0m foo \e[2mattr_reader \e[33m:foo\e[0;2m\e[0m
          \e[36mapp/foo.rb:3:4\e[0m unused_method \e[2mdef \e[33munused_method\e[0;2m\e[0m
          \e[36mapp/foo.rb:4:2\e[0m @bar \e[2m\e[33m@bar\e[0;2m = true\e[0m
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 1
      end

      it 'runs with --parallel' do
        expect(Parallel).to receive(:each).once.and_call_original

        run('--parallel')

        expect(stdout).to have_output <<~STDOUT
          checked 1 files, collected 2 calls, 3 definitions
          \e[31mNot directly called at all:\e[0m
          \e[36mapp/foo.rb:1:12\e[0m foo \e[2mattr_reader \e[33m:foo\e[0;2m\e[0m
          \e[36mapp/foo.rb:3:4\e[0m unused_method \e[2mdef \e[33munused_method\e[0;2m\e[0m
          \e[36mapp/foo.rb:4:2\e[0m @bar \e[2m\e[33m@bar\e[0;2m = true\e[0m
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 1
      end

      it 'outputs the version when --version' do
        run '--version'
        expect(stdout).to have_output <<~STDOUT
          #{Leftovers::VERSION}
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 0
      end

      it 'outputs the files when --dry-run' do
        run '--dry-run'
        expect(stdout).to have_output <<~STDOUT
          app/foo.rb
        STDOUT
        expect(stderr.string).to be_empty
        expect(exitstatus).to be 0
      end

      context 'with tests' do
        before do
          temp_file 'spec/foo.rb', <<~RUBY
            expect(unused_method).to eq foo
            self.instance_variable_get(:@bar) == true
          RUBY
        end

        it 'runs' do
          run('--no-parallel') # so i get consistent order

          expect(stdout.string).to eq <<~STDOUT
            \e[2Kchecked 1 files, collected 2 calls, 3 definitions\r\e[2Kchecked 2 files, collected 10 calls, 3 definitions\r\e[2Kchecked 2 files, collected 10 calls, 3 definitions\r
            \e[2K\e[31mOnly directly called in tests:\e[0m
            \e[2K\e[36mapp/foo.rb:1:12\e[0m foo \e[2mattr_reader \e[33m:foo\e[0;2m\e[0m
            \e[2K\e[36mapp/foo.rb:3:4\e[0m unused_method \e[2mdef \e[33munused_method\e[0;2m\e[0m
            \e[2K\e[36mapp/foo.rb:4:2\e[0m @bar \e[2m\e[33m@bar\e[0;2m = true\e[0m
          STDOUT
          expect(stderr.string).to be_empty
          expect(exitstatus).to be 1
        end

        it 'runs with suppressed progress' do
          run('--no-parallel --no-progress')

          expect(stdout.string).to eq <<~STDOUT
            \e[2Kchecked 2 files, collected 10 calls, 3 definitions\r
            \e[2K\e[31mOnly directly called in tests:\e[0m
            \e[2K\e[36mapp/foo.rb:1:12\e[0m foo \e[2mattr_reader \e[33m:foo\e[0;2m\e[0m
            \e[2K\e[36mapp/foo.rb:3:4\e[0m unused_method \e[2mdef \e[33munused_method\e[0;2m\e[0m
            \e[2K\e[36mapp/foo.rb:4:2\e[0m @bar \e[2m\e[33m@bar\e[0;2m = true\e[0m
          STDOUT
          expect(stderr.string).to be_empty
          expect(exitstatus).to be 1
        end
      end
    end
  end
end

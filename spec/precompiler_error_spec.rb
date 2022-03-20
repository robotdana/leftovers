# frozen-string-literal: true

::RSpec.describe ::Leftovers::PrecompileError do
  describe '#warn' do
    before do
      ::Leftovers.reset
    end

    it 'can include a line and column' do
      error = described_class.new('the message', line: 1, column: 5)
      expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
        \e[2KLeftovers::PrecompileError: whatever.jpg:1:5 the message
      MESSAGE
    end

    it 'can include a line' do
      error = described_class.new('the message', line: 1)
      expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
        \e[2KLeftovers::PrecompileError: whatever.jpg:1 the message
      MESSAGE
    end

    it "doesn't print the column with no line" do
      error = described_class.new('the message', column: 1)
      expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
        \e[2KLeftovers::PrecompileError: whatever.jpg the message
      MESSAGE
    end

    it 'can be given no line or column' do
      error = described_class.new('the message')
      expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
        \e[2KLeftovers::PrecompileError: whatever.jpg the message
      MESSAGE
    end

    it 'prints the cause class instead if there is one' do
      error = begin
        begin
          raise ::ArgumentError, 'bad times'
        rescue ::ArgumentError
          raise described_class.new('the message', line: 1, column: 5)
        end
      rescue described_class => e
        e
      end
      expect { error.warn(path: 'whatever.jpg') }.to output(<<~MESSAGE).to_stderr
        \e[2KArgumentError: whatever.jpg:1:5 the message
      MESSAGE
    end
  end
end

# frozen_string_literal: true

module ExpectsOutput
  def expects_output!
    @expects_output = true
  end
end

::RSpec.configure do |c|
  c.include ExpectsOutput

  c.before { ::Leftovers.reset }

  c.after do
    next if defined?(@expects_output) && @expects_output

    expect(::Leftovers.stderr.string).to be_empty
    expect(::Leftovers.stdout.string).to be_empty
  end
end

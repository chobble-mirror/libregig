# https://github.com/tailwindlabs/tailwindcss/discussions/6738

module SassCompressorMonkeypatch
  def call_processor(processor, input)
    super
  rescue SassC::SyntaxError
    raise unless processor == Sprockets::SassCompressor
    metadata = (input[:metadata] || {}).dup
    metadata[:data] = input[:data]
    metadata
  end
end

Sprockets::Base.prepend(SassCompressorMonkeypatch)

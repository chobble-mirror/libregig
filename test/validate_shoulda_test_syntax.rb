module ValidateShouldaTestSyntax
  def self.validate(test_case)
    test_methods = test_case.methods.grep(/^test_/)
    test_methods.each do |method|
      unless /test_: /.match?(method.to_s)
        raise <<~MSG
          Test '#{method}' does not use shoulda context and should blocks. Please
          rewrite it using shoulda syntax.
        MSG
      end
    end
  end
end

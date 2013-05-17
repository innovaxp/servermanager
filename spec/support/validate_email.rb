module Validateemail
  class Matcher
    def initialize(attribute)
      @attribute = attribute
    end

    def matches?(model)
      @model = model
      
      return @model.send(@attribute) =~ /[a-z0-9_\-\.]+?@[a-z0-9_\-]+?(\.[a-z0-9_\-]*)+/i

    end

    def failure_message
      "#{@model.class} failed to validate: #{@attribute}"
    end

    def negative_failure_message
      "#{@model.class} unexpected validation: #{@attribute}"
    end

    def description
      "validate numericality of #{@attribute}"
    end
  end

  def validate_email(attribute)
    Matcher.new(attribute)
  end
end

RSpec.configure do |config|
  config.include Validateemail
end
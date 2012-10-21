module TraceMatcher
  def trace(list)
    list = [list] unless list.is_a?(Array)
    TraceMatcher::Matcher.new(list)
  end
  
  class Matcher
    def initialize(list)
      @expected = list
    end
    
    def matches?(actual)
      @actual = actual
      matches = @expected.map do |e|
        @actual['workitem']['fields']['trace'].include?(e)
      end
      
      !matches.any? { |x| x == false }
    end
    
    def failure_message
      "Expected #{@actual['workitem']['fields']} to execute all of #{@expected}"
    end
    
    def negative_failure_message
      "Expected #{@actual['workitem']['fields']} to not execute any of #{@expected}"
    end
  end
end

RWorld(TraceMatcher)

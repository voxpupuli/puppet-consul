# Used for testing the hiera consul backend implementation.
# It is difficult to test the puppet ruby function
# because it requires an Puppet::LookupContext object.
#
# These mocks allow for the testing of the lookup_key function without
# requiring the whole puppet environment.

class FakeFunction
  def self.dispatch(*); end
end

module Puppet
  module Functions
    #
    # Mocks the create_function that is used for creating
    # ruby functions and loads the specification into FakeFunction.
    #
    def self.create_function(_name, &block)
      FakeFunction.class_eval(&block)
    end
  end
end

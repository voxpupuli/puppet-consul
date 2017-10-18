# Used for testing the hiera consul backend implementation.
# It is difficult to test the puppet ruby function
# because it requires an Puppet::LookupContext object.
#
# These mocks allow for the testing of the lookup_key function without
# requiring the whole puppet environment.

class FakeFunction
  def self.dispatch(_name); end
end

module Puppet
  module Functions
    @monkey_patch_enabled = false
    @old_require = Puppet::Functions.method(:create_function)
    #
    # Mocks the create_function that is used for creating
    # ruby functions and loads the specification into FakeFunction.
    #
    # This behaviour can be switched on and off by using
    # start_monkey_patch and stop_monkey_patch.
    #
    def self.create_function(name, function_base = Function, &block)
      if @monkey_patch_enabled
        FakeFunction.class_eval(&block)
      else
        @old_require.call(name, function_base, &block)
      end
    end

    def self.start_monkey_patch
      @monkey_patch_enabled = true
    end

    def self.stop_monkey_patch
      @monkey_patch_enabled = false
    end
  end
end

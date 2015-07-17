require 'spec_helper'

describe 'consul_sorted_json' do
  it { should run.with_params({'foo' => :undef}).and_return("{}") }
  it { should run.with_params({'b' => 1, 'a' => 2, 'c' => 3}).and_return('{"a":2,"b":1,"c":3}')}
  it { should run.with_params({
    'w' => -1,
    'x' => '8500',
    'y' => '-8656',
    'z' => 'foo bar 123 4 5 6',
    }).and_return('{"w":-1,"x":8500,"y":-8656,"z":"foo bar 123 4 5 6"}')
  }
end

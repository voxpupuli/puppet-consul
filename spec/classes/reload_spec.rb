require 'spec_helper'

describe 'consul::reload' do
  it {
    should contain_exec('consul reload') \
      .with_command('consul reload')
      .with_refreshonly(true)
  }
end

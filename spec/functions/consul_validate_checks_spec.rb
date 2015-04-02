require 'spec_helper'

describe 'consul_validate_checks' do

  describe 'validate script and http' do
    it {should run.with_params([
      {
        'http'    => 'localhost',
        'script' => 'true'
      }
    ]).and_raise_error(Exception) }
  end

  describe 'validate script check' do
    it {should run.with_params([
      {
        'interval'    => '30s',
        'script' => 'true'
      }
    ])}
  end

  describe 'validate script missing interval' do
    it {should run.with_params([
      {
        'script' => 'true'
      }
    ]).and_raise_error(Exception) }
  end

  describe 'validate http missing interval' do
    it {should run.with_params([
      {
        'http' => 'localhost'
      }
    ]).and_raise_error(Exception) }
  end

  describe 'validate script and ttl' do
    it {should run.with_params([
      {
        'script' => 'true',
        'ttl' => 'true'
      }
    ]).and_raise_error(Exception) }
  end

  describe 'validate http and ttl' do
    it {should run.with_params([
      {
        'http' => 'localhost',
        'ttl' => 'true'
      }
    ]).and_raise_error(Exception) }
  end
end

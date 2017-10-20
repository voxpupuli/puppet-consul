require 'puppet_x/consul/cache'
require 'json'

def fetch_cache_file_name(directory, key, idx)
  md5 = Digest::MD5.hexdigest(key.to_s).to_s
  "#{directory}/#{md5}-#{idx}.cache"
end

describe 'PuppetX::Consul::Cache' do
  let(:tmpdir) { Dir.mktmpdir }
  
  after(:each) {
    PuppetX::Consul::Cache.clear
    FileUtils.rm_r tmpdir
  }

  context 'Basic functionality' do
    it 'store a key and retrieve it' do
      c = PuppetX::Consul::Cache.new(tmpdir)
      c.store_cache('12', 35, 'test data')

      expect(c.key_exists('12', 35)).to eql(true)
      expect(c.retrieve_cache('12')).to eql('test data')
      # expect a lock and cache file
      expect(Dir.glob("#{tmpdir}/*").length).to eql(2)
    end

    it 'store multiple version/keys and retrieve the right one' do
      c = PuppetX::Consul::Cache.new(tmpdir)
      c.store_cache('12', 35, 'test data')
      c.store_cache('12', 30, 'test data latest')

      c.store_cache('50', 30, '50 test data')
      c.store_cache('50', 35, '50 test data latest')

      expect(c.key_exists('12', 35)).to eql(false)
      expect(c.key_exists('12', 30)).to eql(true)

      expect(c.key_exists('50', 30)).to eql(false)
      expect(c.key_exists('50', 35)).to eql(true)

      expect(c.retrieve_cache('12')).to eql('test data latest')
      expect(c.retrieve_cache('50')).to eql('50 test data latest')

      # expect a lock and cache file
      expect(Dir.glob("#{tmpdir}/*").length).to eql(4)
    end
  end


  context 'After restart use FileCache to fill InMemorycache' do
    it 'when multiple versions of a cache object exists.' do
      File.open(fetch_cache_file_name(tmpdir, '12', 40), 'w') do |file|
        file.write('test data'.to_json)
      end
      File.open(fetch_cache_file_name(tmpdir, '14', 46), 'w') do |file|
        file.write('test data'.to_json)
      end
      # wait for a little so that the ctime is different
      sleep(1)
      File.open(fetch_cache_file_name(tmpdir, '12', 45), 'w') do |file|
        file.write(['newer test data'].to_json)
      end
      File.open(fetch_cache_file_name(tmpdir, '14', 42), 'w') do |file|
        file.write(['14 newer test data'].to_json)
      end

      c = PuppetX::Consul::Cache.new(tmpdir)

      # this is all done from the fs
      expect(c.key_exists('12', 40)).to eql(true)
      expect(c.key_exists('12', 45)).to eql(true)
      expect(c.key_exists('14', 46)).to eql(true)
      expect(c.key_exists('14', 42)).to eql(true)

      # by fetching the data we also delete any old keys
      expect(c.retrieve_cache('12')).to eql(['newer test data'])
      expect(c.retrieve_cache('14')).to eql(['14 newer test data'])

      # it should now be cleaned and in the inmemory cache
      expect(c.key_exists('12', 40)).to eql(false)
      expect(c.key_exists('12', 45)).to eql(true)
      expect(c.key_exists('14', 46)).to eql(false)
      expect(c.key_exists('14', 42)).to eql(true)

      # expect only cache files for two keys
      expect(Dir.glob("#{tmpdir}/*").length).to eql(2)
    end

    it 'try to fetch nonexisting cache keys' do 
      c = PuppetX::Consul::Cache.new(tmpdir)
      expect(c.retrieve_cache('14')).to eql(nil)
    end
  end
end

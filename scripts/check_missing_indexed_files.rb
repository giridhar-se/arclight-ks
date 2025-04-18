# check_missing_indexed_files.rb
require 'rsolr'

# Setup Solr connection
solr = RSolr.connect url: ENV['SOLR_URL'] || 'http://solr:8983/solr/blacklight-core'

# 1. Get list of eadid values indexed in Solr
puts "Fetching all eadid values from Solr..."
response = solr.get 'select', params: {
  q: '*:*',
  fl: 'ead_ssi',
  rows: 100000 # adjust if needed
}
indexed_eadids = response['response']['docs'].map { |doc| doc['ead_ssi'] }.compact.to_set

# 2. Get list of local EAD XML files
ead_files = Dir.glob('/opt/app-root/finding-aid-data/*.xml')
local_eadids = ead_files.map do |file|
  content = File.read(file)
  if content =~ /<eadid[^>]*>([^<]+)<\/eadid>/
    $1.strip
  end
end.compact.to_set

# 3. Find missing files that are not indexed
missing = local_eadids - indexed_eadids
missing.each { |id| puts "  - #{id}" }

puts "\n Total missing from Solr: #{missing.size}"

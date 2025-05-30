# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

# Read the repository configuration
repo_config = YAML.safe_load_file('./config/repositories.yml')

namespace :seed do
  # Seed Test EAD Data (From spec/fixtures/*)
  # Based on https://github.com/projectblacklight/arclight/blob/master/tasks/arclight.rake
  # ==============================
  desc 'Index EAD file fixtures into Solr for testing'
  task fixtures: [:'arclight:destroy_index_docs'] do
    puts 'Seeding index with data from spec/fixtures/ead...'
    Dir.glob('spec/fixtures/ead/*.xml').each do |file|
      system("FILE=#{file} rake dul_arclight:index") # no REPOSITORY_ID
    end
    Dir.glob('spec/fixtures/ead/*').each do |dir|
      next unless File.directory?(dir)

      system("REPOSITORY_ID=#{File.basename(dir)} " \
             'REPOSITORY_FILE=./config/repositories.yml ' \
             "DIR=#{dir} " \
             'rake dul_arclight:index_dir')
    end
  end

  # Seed Sample EAD Data (From sample-ead/*)
  # Based on https://github.com/sul-dlss/arclight-demo/blob/master/Rakefile
  # ==============================
  desc 'Index sample EAD files into Solr'
  task samples: [:'arclight:destroy_index_docs'] do
    puts 'Seeding index with data from sample-ead directory...'
    # Identify the configured repos
    repo_config.each_key do |repository|
      # Index a directory with a given repository ID that matches its filename
      system("DIR=./sample-ead/ead/#{repository} REPOSITORY_ID=#{repository} rake dul_arclight:index_dir")
    end
  end
end

namespace :dul_arclight do
  # =========================================================================
  # DELETE from the index using the EADID slug (repository irrelevant)
  # =========================================================================
  desc 'Delete one finding aid and all its components from the index, use EADID=<eadid>'
  task delete: :environment do
    raise 'Please specify your EAD slug, ex. EADID=<eadid>' unless ENV['EADID']

    puts "Deleting all documents from index with ead_ssi = #{ENV.fetch('EADID', nil)}"
    DeleteFindingAidJob.perform_now(ENV.fetch('EADID', nil))
    puts "Deleted #{ENV.fetch('EADID', nil)}"
  end

  desc 'Re-build the Solr suggester data'
  task build_suggest: :environment do
    BuildSuggestJob.perform_later
    puts 'BuildSuggestJob enqueued.'
  end

  # rubocop:disable Lint/SuppressedException
  begin
    require 'rspec/core/rake_task'
    namespace :test do
      RSpec::Core::RakeTask.new(accessibility: ['seed:fixtures', 'db:reset']) do |t, _|
        t.rspec_opts = '--tag accessibility'
      end

      RSpec::Core::RakeTask.new(default: ['seed:fixtures', 'db:reset']) do |t, _|
        t.rspec_opts = '--tag ~accessibility'
      end
    end
  rescue LoadError => _e
  end
  # rubocop:enable Lint/SuppressedException
end

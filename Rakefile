task :default => ['local:clean', 's3:fetch', 's3:upload']
task :regen   => ['local:clean', 's3:fetch']

load 'lib/config.rb'
load 'lib/templates.rb'

task :test do
  ruby 'lib/test.rb'
end

namespace :local do

  desc 'Delete cached files in the staging area.'
  task :clean do
    ruby 'lib/clean.rb'
  end

end

namespace :s3 do

  desc 'Upload files in the output directory to S3.'
  task :upload do
    ruby 'lib/upload.rb'
  end

  desc 'Retrieve usage statistics and generate local output'
  task :fetch do
    ruby 'lib/fetch.rb'
  end

end


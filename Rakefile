task :default => ['local:clean', 'local:generate', 's3:upload']
task :regen   => ['local:clean', 'local:generate']

load 'lib/config.rb'
load 'lib/templates.rb'

task :test do
  ruby 'lib/test.rb'
end

namespace :local do

  desc 'Generate static files and prepare static assets.'
  task :generate do
    ruby 'lib/generate.rb'
  end

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

end


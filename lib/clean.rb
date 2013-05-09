require 'fileutils'

puts 'Clearing old output cache...'

FileUtils.rm_r Dir['output/*']

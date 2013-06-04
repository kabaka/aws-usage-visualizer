require 'fileutils'

puts 'Clearing old output...'

FileUtils.rm_r Dir['output/*']

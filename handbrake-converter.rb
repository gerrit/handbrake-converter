#!/usr/bin/env ruby
#handbrake-converter.rb
PROGRAM_VERSION = 0.1

require 'rubygems'
require 'configatron'
require File.expand_path(File.dirname(__FILE__) + "/lib/choice.rb")

puts 'Lauching handbrake-converter.rb...'
puts ''

puts 'Loading configuration file...'
@@config = configatron.configure_from_yaml(File.expand_path(File.dirname(__FILE__) + "/config/config.yml"))
puts 'Configuration file loaded...'
puts ''

if Choice.choices[:use_dvd] == 'true'
  puts 'Using the DVD player as the video source...'
  src_dir_contents = [ 'DVD.DVD' ]
else
  puts 'Scanning source directory...'
  src_dir_contents = Dir.glob(File.join(Choice.choices[:source], '*.'+Choice.choices[:type]))
  puts 'Source directory scanned...'
  puts ''
  puts "Processing files in the directory " + 
     Choice.choices[:source] + 
     " with extensions '" + 
     Choice.choices[:type] + 
     "' and putting them in destination directory " + 
     Choice.choices[:destination] + " ..."
end
puts ''

filetype_length = Choice.choices[:type].length

src_dir_contents.each do |movie_to_convert|
  filename = movie_to_convert.split(".")
  movie_name = filename[0]
  
  if Choice.choices[:use_dvd] == 'true'
    source = @@config['dvd_location']
  else
    filename_length = movie_to_convert.length
    if filename_length > filetype_length
      length_offset = movie_to_convert.length - filetype_length
      if movie_to_convert.slice(length_offset, filetype_length) == Choice.choices[:type]
        source = File.join(Choice.choices[:source], movie_to_convert)
      end
    end
  end
  
  conversion_instruction = [
    "HandBrakeCLI -i #{source}",
    " -o #{Choice.choices[:destination]}/#{movie_name}",
    @@config['handrake_presets'][Choice.choices[:conversion]]
  ].join
  
  puts 'Starting to process ' + movie_to_convert + '...'
  puts conversion_instruction
  system conversion_instruction
  if Choice.choices[:remove] == 'true' && Choice.choices[:use_dvd] != 'true'
    File.rm File.join(Choice.choices[:source], movie_to_convert)
  end
  puts 'Finished processing ' + movie_to_convert + '...'
  
end

puts 'Completed conversions...'

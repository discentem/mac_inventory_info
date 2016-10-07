require 'plist'

file_name = 'parse_profiler.rb'

def parse_system_profiler(datatype: 'SPStorageDataType',
                          output_file: 'system_profiler_output.plist')

  output_file += '.plist' unless output_file.include? '.plist'

  # save plist
  `system_profiler -xml #{datatype} >> #{output_file}`

  # parse plist
  result = Plist.parse_xml(output_file)
  `rm #{output_file}`
  result.class
  result = result[0]
  result
end

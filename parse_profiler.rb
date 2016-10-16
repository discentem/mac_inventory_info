require 'Plist'
def parse(datatype: 'SPHardwareDataType')
  result = `system_profiler -xml #{datatype}`
  result = Plist.parse_xml(result)
  result.class
  result = result[0]
  result
end

parse['_items'].each do |key|
  puts key['physical_memory']
end

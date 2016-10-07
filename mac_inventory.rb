require './parse_profiler.rb'

def computer_name
  # returns ComputerName as a string
  `scutil --get ComputerName`.strip
end

def hardware_data
  # returns all of SPHardwareDataType as a hash
  parse_system_profiler(datatype: 'SPHardwareDataType')
end

def storage_data
  # returns all of SPStorageDataType as a hash
  parse_system_profiler(datatype: 'SPStorageDataType')
end

def software_data
  # returns all of SPSoftwareDataType as a hash
  parse_system_profiler(datatype: 'SPSoftwareDataType')
end

def machine_model
  # returns machine_model, ex. MacBookPro11,1
  hardware_data['_items'][0]['machine_model']
end

def network_interfaces
  # returns a list of network interfaces and related data
  parse_system_profiler(datatype: 'SPNetworkDataType')['_items']
end

def mac_addresses(all_interfaces: FALSE)
  interfaces = {}
  network_interfaces.each do |interface|
    # each interface from 'SPNetworkDataType'[_items]
    begin
      interfaces[interface['_name']] = interface['Ethernet']['MAC Address']
    rescue
      # if the interface does not have a MAC address
      interfaces[interface['_name']] = 'empty' if all_interfaces
      # skips interfaces that don't have a MAC address if all_interfaces = FALSE
      next
    end
  end
  # returns hash of interfaces by name with val of MAC Address, if it exists
  interfaces
end

def serial_number
  # returns machine serial_number
  hardware_data['_items'][0]['serial_number']
end

def os_version
  # returns os_version
  software_data['_items'][0]['os_version']
end

def processor
  # returns cpu_type and current_processor_speed
  [hardware_data['_items'][0]['cpu_type'],
   hardware_data['_items'][0]['current_processor_speed']]
end

def physical_memory
  # returns physical_memory
  hardware_data['_items'][0]['physical_memory']
end

def volume_name
  # returns volume_name
  storage_data['_items'][0]['_name']
end

def disk_space
  storage_data['_items'][0]
end

def inventory_hash
  inventory = {}
  inventory['computer_name'] = computer_name
  inventory['machine_model'] = machine_model
  inventory['network_interfaces'] = mac_addresses
  inventory['serial_number'] = serial_number
  inventory['os_version'] = os_version
  inventory['processor'] = processor
  inventory['physical_memory'] = physical_memory
  inventory['volume_name'] = volume_name
  # add disk space info
  inventory
end

puts inventory_hash

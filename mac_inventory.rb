begin
  gem 'plist'
rescue Gem::LoadError
  `gem install plist`
end

require 'plist'

# stuff
class Inventory
  def parse(datatype: 'SPStorageDataType')
    result = `system_profiler -xml #{datatype}`
    result = Plist.parse_xml(result)
    result.class
    result = result[0]
    result
  end

  def initialize
    @root_data = {
      'SPHardwareDataType' => parse(datatype: 'SPHardwareDataType'),
      'SPStorageDataType' => parse(datatype: 'SPStorageDataType'),
      'SPSoftwareDataType' => parse(datatype: 'SPSoftwareDataType'),
      'SPNetworkDataType' => parse(datatype: 'SPNetworkDataType')
    }
    @data = {}
  end

  def hardware_facts
    cpu_type = @root_data['SPHardwareDataType']['_items'][0]['cpu_type']
    processor_speed =
      @root_data['SPHardwareDataType']['_items'][0]['current_processor_speed']

    @data = {
      'computer_name' => `scutil --get ComputerName`.strip,
      'machine_model' => @root_data['SPHardwareDataType']['_items'][0]['machine_model'],
      'serial_number' => @root_data['SPHardwareDataType']['_items'][0]['serial_number'],
      'physical_memory' =>
        @root_data['SPHardwareDataType']['_items'][0]['physical_memory'],

      'processor' => {
        'cpu_type' => cpu_type,
        'processor_speed' => processor_speed
      }

    }
  end

  def gather
    hardware_facts
    software_facts
    mac_addresses
    storage_facts
  end

  def software_facts
    @data['os_version'] = @root_data['SPSoftwareDataType']['_items'][0]['os_version']
  end

  def storage_facts
    @data['volume_name'] = @root_data['SPStorageDataType']['_items'][0]['_name']
  end

  def mac_addresses(all_interfaces: FALSE)
    interfaces = {}
    @root_data['SPNetworkDataType']['_items'].each do |interface|
      begin
        interfaces[interface['_name']] = interface['Ethernet']['MAC Address']
      rescue
        # if the interface does not have a MAC address
        # skips interfaces that don't have a MAC address if all_interfaces = FALSE
        interfaces[interface['_name']] = 'empty' if all_interfaces
        next
      end
    end
    # returns hash of interfaces by name with val of MAC Address, if it exists
    @data['network_interfaces'] = interfaces
  end

  def hash
    @data
  end
end

inventory = Inventory.new
inventory.gather
puts inventory.hash

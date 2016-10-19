require 'plist'

# Inventory Object. <instance>.gather is a hash of Inventory
#   information about the Mac this script is run on
class Inventory
  def parse(datatype: 'SPStorageDataType')
    result = `system_profiler -xml #{datatype}`
    result = Plist.parse_xml(result)
    result.class
    result = result[0]
    result
  end

  def initialize
    @hash = {}
    @xml_data = {
      'SPHardwareDataType' => parse(datatype: 'SPHardwareDataType'),
      'SPStorageDataType' => parse(datatype: 'SPStorageDataType'),
      'SPSoftwareDataType' => parse(datatype: 'SPSoftwareDataType'),
      'SPNetworkDataType' => parse(datatype: 'SPNetworkDataType')
    }
  end

  def gather
    @hash['computer_name'] = `scutil --get ComputerName`.strip
    # gets machine_model, screen_size, serial_number, and physical_memory in the hash
    hardware_facts
    # gets cpu_type and processor_speed in the hash
    processor_facts
    # gets os_version into hash
    software_facts
    # gets each interface and corresponding MAC address in the hash
    mac_addresses
    # gets volume_name into hash
    storage_facts
  end

  def hardware_facts
    @hash['machine_model'] = @xml_data['SPHardwareDataType']['_items'][0]['machine_model']
    @hash['screen_size'] = `python screen_size.py`.strip
    @hash['serial_number'] = @xml_data['SPHardwareDataType']['_items'][0]['serial_number']
    @hash['physical_memory'] =
      @xml_data['SPHardwareDataType']['_items'][0]['physical_memory']
  end

  def processor_facts
    @hash['processor'] = {
      'cpu_type' => @xml_data['SPHardwareDataType']['_items'][0]['cpu_type'],
      'processor_speed' =>
        @xml_data['SPHardwareDataType']['_items'][0]['current_processor_speed']
    }
  end

  def software_facts
    @hash['os_version'] = @xml_data['SPSoftwareDataType']['_items'][0]['os_version']
  end

  def storage_facts
    @hash['volume_name'] = @xml_data['SPStorageDataType']['_items'][0]['_name']
  end

  def mac_addresses(all_interfaces: FALSE)
    interfaces = {}
    @xml_data['SPNetworkDataType']['_items'].each do |interface|
      begin
        interfaces[interface['_name']] = interface['Ethernet']['MAC Address']
      # if the interface does not have a MAC address
      rescue
        # skips empty interfaces if all_interfaces = FALSE
        interfaces[interface['_name']] = 'empty' if all_interfaces
        next
      end
    end
    # returns hash of interfaces by name with val of MAC Address, if it exists
    @hash['mac_addresses'] = interfaces
  end

  def show
    # returns hash
    @hash
  end
end

inventory = Inventory.new
inventory.gather
puts inventory.show

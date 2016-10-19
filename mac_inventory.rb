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
    @hash['machine_model'] = @xml_data['SPHardwareDataType']['_items'][0]['machine_model']
    @hash['screen_size'] = `python screen_size.py`.strip
    @hash['serial_number'] = @xml_data['SPHardwareDataType']['_items'][0]['serial_number']

    @hash['physical_memory'] =
      @xml_data['SPHardwareDataType']['_items'][0]['physical_memory']

    @hash['processor'] = {
      'cpu_type' => @xml_data['SPHardwareDataType']['_items'][0]['cpu_type'],
      'processor_speed' =>
        @xml_data['SPHardwareDataType']['_items'][0]['current_processor_speed']
    }

    @hash['os_version'] = @xml_data['SPSoftwareDataType']['_items'][0]['os_version']
    @hash['mac_addresses'] = mac_addresses

    @hash['volume_name'] = @xml_data['SPStorageDataType']['_items'][0]['_name']
  end

  def mac_addresses(all_interfaces: FALSE)
    interfaces = {}
    @xml_data['SPNetworkDataType']['_items'].each do |interface|
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
    interfaces
  end

  def show
    @hash
  end
end

inventory = Inventory.new
inventory.gather
puts inventory.show

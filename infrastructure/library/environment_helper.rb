# Get the hosts OS.
def get_host_os
    os = case RbConfig::CONFIG['host_os']
        when /mswin|mingw/
            'Windows'
        when /darwin|mac os/
            'Mac OS X'
        when /linux/
            'Linux'
        else
            'unknown'
        end
end

# Detect paravirtualisation provider
def get_paravirt_provider
    case get_host_os
        when 'Windows'
            'default'
        when 'Mac OS X'
            'default'
        when 'Linux'
            'kvm'
    end
end

# Count logical processors of the host machine.
def get_logical_processor_count

    # Use different count methods based on the OS.
    count = case get_host_os

        when 'Windows'

            require 'win32ole'
            result_set = WIN32OLE.connect("winmgmts://").ExecQuery("select NumberOfLogicalProcessors from Win32_Processor")
            result_set.to_enum.collect(&:NumberOfLogicalProcessors).reduce(:+)

        when 'Mac OS X'

            IO.popen("/usr/sbin/sysctl --values hw.logicalcpu").read.to_i

        when 'Linux'

            IO.popen("grep --count ^processor /proc/cpuinfo").read.to_i

        end

    # Fallback to one processor if the count result is false.
    return count < 1 ? 1 : count
end

# Count physical processors of the host machine.
def get_physical_processor_count

     # Use different count methods based on the OS.
    count = case get_host_os

        when 'Windows'

            require 'win32ole'
            result_set = WIN32OLE.connect("winmgmts://").ExecQuery("select NumberOfCores from Win32_Processor")
            result_set.to_enum.collect(&:NumberOfCores).reduce(:+)

        when 'Mac OS X'

            IO.popen("/usr/sbin/sysctl --values hw.physicalcpu").read.to_i

        when 'Linux'

            IO.popen("grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}'").read.to_i

        end

    # Fallback to one processor if the count result is false.
    return count < 1 ? 1 : count
end


# Count physical memory of the host machine.
def physical_memory_count

    # Use different count methods based on the OS.
    count = case get_host_os

        when 'Windows'

             require 'win32ole'
             capacity = WIN32OLE.connect("winmgmts://").ExecQuery("select Capacity from Win32_PhysicalMemory")
             capacity.to_enum.collect(&:Capacity).map{|string| string.to_i}.inject(:+) / 1024 / 1024

        when 'Mac OS X'

            `sysctl -n hw.memsize`.to_i / 1024 / 1024

        when 'Linux'

            `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
    end
end

# Output the details of the environment in which Vagrant is currently running.
def output_vagrant_runtime_environment_details()

    if (!['up', 'status'].include? ARGV[0])
        return
    end

    $stdout.puts [
            'Detected ' + get_host_os.to_s + ' OS with ',
            get_physical_processor_count.to_s  + ' physical cores and ',
            get_logical_processor_count.to_s  + ' logical processors, ',
        ].join('')

    $stdout.puts [
        physical_memory_count.to_s + ' MB RAM and "',
        get_paravirt_provider + '" as virtualisation provider.',
    ].join('')

end

# We inherit from Vagrant::Errors::VagrantError so that Vagrant
# handles this error like other VagrantErrors but we override the
# VagrantError#initialize method to avoid i18n translations.
class MissingSSHKeyError < Vagrant::Errors::VagrantError
    def initialize(message = 'No error message')
        error_message = "MissingSSHKeyError: #{message}"
        StandardError.instance_method(:initialize).bind(self).call(error_message)
    end
end

def get_vagrant_ssh_private_key()

    vagrant_ssh_private_key_location = "#{ENV['HOME']}/.vagrant.d/insecure_private_key"

    if (!File.exists?(vagrant_ssh_private_key_location))
        raise MissingSSHKeyError.new(
            "File '#{vagrant_ssh_private_key_location}' does not exist, aborting..."
        )
    end

    return File.read(vagrant_ssh_private_key_location)
end

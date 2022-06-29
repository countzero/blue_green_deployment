require_relative '../library/environment_helper'

MACHINE_CONFIGURATIONS = [
    {
        :name => 'blue-green-deployment',
        :ip_v4_address => '10.0.0.50',
        :forwarded_ports => [
            {
                :id => 'application',
                :guest => 80,
                :host => 8080,
            },
        ],
        :is_primary => true,
        :starts_on_vagrant_up => true,
        :has_gui => false,
        :cpus => get_physical_processor_count,
        :memory => 1024,
        :para_virtualization_provider => get_paravirt_provider,
        :shell_inline_provisioning => <<-SHELL,

            echo "Copying SSH config file to '/home/vagrant/.ssh/config'..."
            install -o vagrant -g vagrant -m 644 /home/vagrant/provisioning/ssh.config /home/vagrant/.ssh/config

            echo "Copying vagrant private SSH key to '/home/vagrant/.ssh'..."
            echo "#{get_vagrant_ssh_private_key()}" > /home/vagrant/.ssh/id_rsa
            chmod 600 /home/vagrant/.ssh/id_rsa
            chown vagrant:vagrant /home/vagrant/.ssh/id_rsa

            echo "Creating symbolic link '/home/vagrant/ansible.cfg'..."
            ln -s /home/vagrant/provisioning/ansible.cfg /home/vagrant/ansible.cfg
            chown vagrant:vagrant /home/vagrant/ansible.cfg

            echo "Adding official Ansible PGP key to '/usr/share/keyrings/ansible-archive-keyring.gpg'..."
            curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93c4a3fd7bb9c367" | \
            gpg --dearmor -o /usr/share/keyrings/ansible-archive-keyring.gpg

            echo "Adding official Ansible repository to '/etc/apt/sources.list.d/ansible.list'..."
            echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" > /etc/apt/sources.list.d/ansible.list

            echo "Installing latest 'ansible' and 'python3-apt' for the current Debian distribution..."
            apt-get --allow-releaseinfo-change update && apt-get --yes install ansible python3-apt

            echo "Adding ssh-agent to '/home/vagrant/.profile'..."
            echo 'eval "$(ssh-agent -s)"' >> /home/vagrant/.profile

        SHELL
        :shell_inline_always => <<-SHELL,

            echo "Provisioning all development hosts..."
            time ansible-playbook --inventory="./provisioning/inventory/development" ./provisioning/playbook/site.yml

        SHELL
    },
]

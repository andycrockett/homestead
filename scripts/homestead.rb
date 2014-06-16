class Homestead
  def Homestead.configure(config, settings)

    # Configure hostmanager
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true # requires password during setup if true
    config.hostmanager.ignore_private_ip = false # visit your sites without specifying the port (:8000)
    config.hostmanager.include_offline = true

    config.vm.define "homestead" do |node|

      # Configure The Box
      node.vm.box = "laravel/homestead"
      node.vm.hostname = "homestead"

      # Configure A Private Network IP
      node.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

      # Define aliases variable to pass to hostmanager later
      aliases = ""

      # Configure A Few VirtualBox Settings
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
        vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      # Configure Port Forwarding To The Box
      node.vm.network "forwarded_port", guest: 80, host: 8000
      node.vm.network "forwarded_port", guest: 3306, host: 33060
      node.vm.network "forwarded_port", guest: 5432, host: 54320

      # Configure The Public Key For SSH Access
      node.vm.provision "shell" do |s|
        s.inline = "echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end

      # Copy The SSH Private Keys To The Box
      settings["keys"].each do |key|
        node.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end

      # Copy The Bash Aliases
      node.vm.provision "shell" do |s|
        s.inline = "cp /vagrant/aliases /home/vagrant/.bash_aliases"
      end

      # Register All Of The Configured Shared Folders
      settings["folders"].each do |folder|
        node.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil
      end


      # Install All The Configured Nginx Sites
      settings["sites"].each do |site|
        node.vm.provision "shell" do |s|
            s.inline = "bash /vagrant/scripts/serve.sh $1 \"$2\" $3"
            s.args = [site["name"], site['map'], site["to"]]
        end
        # record all site mappings for hostmanager
        aliases << " " + site["map"]
      end

      # Configure All Of The Server Environment Variables
      if settings.has_key?("variables")
        settings["variables"].each do |var|
          node.vm.provision "shell" do |s|
              s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php5/fpm/php-fpm.conf && service php5-fpm restart"
              s.args = [var["key"], var["value"]]
          end
        end
      end

      # pass aliases to hostmanagers
      node.hostmanager.aliases = aliases
      
      # ensure hostmanager is run
      node.vm.provision :hostmanager
    end
  end
end

# make sure hostmanager is installed
unless Vagrant.has_plugin?("vagrant-hostmanager")
  raise 'Missing required plugin "vagrant-hostmanager". To install, run "vagrant plugin install vagrant-hostmanager" and then try again.'
end

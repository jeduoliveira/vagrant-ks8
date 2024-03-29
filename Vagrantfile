# to make sure the k8s-1 node is created before the other nodes, we
# have to force a --no-parallel execution.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

require 'ipaddr'

number_of_master_nodes = 1
number_of_worker_nodes = 2
first_master_node_ip  = '10.11.0.101'
first_worker_node_ip  = '10.11.0.201'
pod_network_cidr      = '10.12.0.0/16'
service_cidr          = '10.13.0.0/16'  # default is 10.96.0.0/12
service_dns_domain    = 'vagrant.local' # default is cluster.local
master_node_ip_addr = IPAddr.new first_master_node_ip
worker_node_ip_addr = IPAddr.new first_worker_node_ip

Vagrant.configure(2) do |config|
  config.vm.box = 'generic/ubuntu1804'

  config.vm.synced_folder ".", "/vagrant", disabled: false

  config.vm.provider 'virtualbox' do |vb|
    vb.linked_clone = true
    vb.cpus = 4
  end

  (1..number_of_master_nodes).each do |n|
    name = "ks8m#{n}"
    fqdn = "#{name}.example.test"
    ip = master_node_ip_addr.to_s; master_node_ip_addr = master_node_ip_addr.succ

    config.vm.define name do |config|      
      config.vm.provider 'virtualbox' do |vb|
        vb.memory = 2*1024
      end
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip
      config.vm.provision 'shell', path: 'provision-base.sh', args: ['master']
      config.vm.provision 'shell', path: 'provision-docker.sh', privileged: true
      config.vm.provision 'shell', path: 'provision-kubernetes-tools.sh', args: [ip]
      config.vm.provision 'shell', path: 'provision-kubernetes-master.sh', args: [ip, pod_network_cidr, service_cidr, service_dns_domain]
    end
  end

  (1..number_of_worker_nodes).each do |n|
    name = "ks8w#{n}"
    fqdn = "#{name}.example.test"
    ip = worker_node_ip_addr.to_s; worker_node_ip_addr = worker_node_ip_addr.succ

    config.vm.define name do |config|      
      config.vm.provider 'virtualbox' do |vb|
        vb.memory = 2*1024
      end
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip
      config.vm.provision 'shell', path: 'provision-base.sh', args: ['worker']
      config.vm.provision 'shell', path: 'provision-docker.sh'
      config.vm.provision 'shell', path: 'provision-kubernetes-tools.sh', args: [ip]
      config.vm.provision 'shell', path: 'provision-kubernetes-worker.sh'
    end
  end
end
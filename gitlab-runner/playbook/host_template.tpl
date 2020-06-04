all:
  hosts:
    default:
      host_key_checking: false
      ansible_host: ${vm_ip}
      ansible_user: ${ansible_user}
      ansible_port: 22
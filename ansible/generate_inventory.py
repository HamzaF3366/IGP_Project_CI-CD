import json

j = json.load(open('terraform_outputs.json'))
master_ip = j['master_public_ip']['value']
worker_ips = j['worker_public_ips']['value']

worker_entries = "\n".join([f"{ip} ansible_user=ubuntu" for ip in worker_ips])

inv = f"""[master]
{master_ip} ansible_user=ubuntu

[workers]
{worker_entries}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
"""

with open('ansible/inventory.ini', 'w') as f:
    f.write(inv)

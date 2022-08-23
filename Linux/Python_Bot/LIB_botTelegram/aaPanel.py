from paramiko import SSHClient

def installAaPanel(ip, user, password):
    client = SSHClient()
    #client.load_system_host_keys()
    #client.load_host_keys('~/.ssh/known_hosts')
    #client.set_missing_host_key_policy(AutoAddPolicy())
    client.connect(ip, user, password)
    
    # Detect OS
    stdin, stdout, stderr = client.exec_command('cat /etc/os-release | egrep ^ID=')
    for line in stdout:
        print(line.strip('\n'))

    # stdin, stdout, stderr = client.exec_command('yum install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh aapanel')


    # Because they are file objects, they need to be closed
    stdin.close()
    stdout.close()
    stderr.close()
    client.close()
    return 0

installAaPanel("103.200.22.145","root","Vietnix@2022@@")


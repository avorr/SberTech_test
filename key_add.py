#!/usr/bin/python3.7
import paramiko
from sys import argv
import time

def once_command(command:str, hostname:str):
    try:
        sshtransport = paramiko.Transport((hostname, 22))
        id_rsa=paramiko.RSAKey.from_private_key(open(argv[3]))
        sshtransport.connect(username = 'root', pkey=id_rsa)
        session = sshtransport.open_channel(kind='session')
        output = []                
        session.exec_command(str(command))
        while True:
            if session.recv_ready():
                output.append(session.recv(3000).decode('ascii'))
            if session.recv_stderr_ready():
                output.append(session.recv_stderr(3000).decode('ascii'))
            if session.exit_status_ready():
                break
        return ''.join(output)
    except paramiko.ssh_exception.AuthenticationException as e:
        print(str(e))
    except paramiko.ssh_exception.SSHException as e:
        print(str(e))
    except EOFError as e:
        print(str(e))
    session.close()
    sshtransport.close()

out_Master_key = once_command('salt-key', argv[1])
print(out_Master_key)

count_key_add = 0
while True:
    count_key_add += 1
    time.sleep(10)
    out_Master = once_command('salt-key', argv[1])
    print(out_Master)
    if 'Minion' in out_Master and 'Master-Minion' in out_Master:
        out_Master = once_command('salt-key -A -y', argv[1])
        print(out_Master)
        time.sleep(5)
        break
    elif count_key_add == 7:
        out_Master = once_command('salt-master -d', argv[1])
        print(out_Master)
    else:
        out_Minion = once_command('salt-minion -d', argv[2])
        print(out_Minion)
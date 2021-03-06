#!/bin/python
import os
# configuration for nagios-a


def install_nagios_server_packages():
    os.system('yum -y install nagios')
    os.system('yum -y install httpd')
    os.system('yum -y install nrpe')
    os.system('yum -y install nagios-plugins-all')
    os.system('yum -y install nagios-plugins-nrpe')


def start_nagios_server_services():
    os.system('setenforce 0')  # required for Nagios to function correctly
    os.system('systemctl enable nagios && systemctl start nagios')
    os.system('systemctl enable httpd && systemctl start httpd')
    os.system('systemctl enable nrpe && systemctl start nrpe')


def set_nagios_dashboard_password():
    # checks signal used to close to command to reprompt password if necessary
    while os.system('htpasswd -c /etc/nagios/passwd nagiosadmin') == 768:
        print("\n\n*** Please type a new password again. ***\n\n")


def check_nrpe_plugin_client(internal_ip):
    '''
    Checks the nrpe plugin on the client using the supplied internal IP
    '''
    print("the output of running the check_nrpe plugin is: ")
    os.system('/usr/lib64/nagios/plugins/check_nrpe -H' + internal_ip)


if __name__ == "__main__":
    install_nagios_server_packages()
    start_nagios_server_services()
    set_nagios_dashboard_password()
    print("*** you must run the code on client-a first for the check_nrpe command to connect ***")
    internal_ip = raw_input("Please enter the internal ip address of client-a to run the check_nrpe plugin: ")
    check_nrpe_plugin_client(internal_ip)

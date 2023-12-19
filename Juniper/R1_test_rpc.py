from jnpr.junos import Device
from lxml import etree
import jcs
# from jnpr.junos.utils.config import Config

# def load_prefix_list(dev)
#     cu = Config(dev)
#     # Define the prefix list name and prefixes
#     prefix_list_name = 'STATIC_MITI'
#     prefixes = ['10.0.0.0/24', '192.168.0.0/16']

#     # Create the prefix list configuration
#     prefix_list_config = 'policy-options {\n'
#     prefix_list_config += '    prefix-list ' + prefix_list_name + ' {\n'
#     for prefix in prefixes:
#         prefix_list_config += '        ' + prefix + ';\n'
#     prefix_list_config += '    }\n'
#     prefix_list_config += '}\n'

#     # Load the prefix list configuration
#     print(prefix_list_config)
#     cu.load(prefix_list_config, format='text')

#     cu.commit()
#     cu.close()

def create_json_prefix_list(dev):
    # Define the prefix list name and prefixes
    prefix_list_name = 'STATIC_MITI'
    prefixes = ['10.0.0.0/24', '192.168.0.0/16']

    # Create the prefix list configuration
    prefix_list_config = 'policy-options {\n'
    prefix_list_config += '    prefix-list ' + prefix_list_name + ' {\n'
    for prefix in prefixes:
        prefix_list_config += '        ' + prefix + ';\n'
    prefix_list_config += '    }\n'
    prefix_list_config += '}\n'

def list_prefix_list(dev):
    # Get the prefix list information for "my-prefix-list"
    rpc_response = dev.rpc.get_prefix_list_information(prefix_list_name='STATIC_MITI')
    print(rpc_response.text)
    # rpc = dev.rpc.get_prefix_list_information(prefix_list_name='STATIC_MITI')
    # prefix_list = rpc['prefix-list-information'][0]['prefix-list']

    # # Print the prefix list entries
    # for entry in prefix_list:
    #     print(f"{entry['prefix']} (exact: {entry['exact']}, or-longer: {entry['orlonger']})")
    # dev.rpc.get_config(filter_xml=etree.XML('<configuration><policy-options><prefix-list/></policy-options></configuration>'))
    print(dev.cli('show configuration policy-options prefix-list STATIC_MITI'))
    with Config(dev, mode="private") as config:
        # if args.d!=None:
        #     for p in args.d:
        #         try:
        #             config.load("delete policy-options prefix-list %s %s" % (args.l, p), format="set")
        #         except ConfigLoadError, e:
        #             if (e.rpc_error['severity']=='warning'):
        #                 print "Warning: %s" % e.message
        #             else:
        #                 raise
        # if args.a!=None:
        #     for p in args.a:
        #         try:
        #             config.load("set policy-options prefix-list %s %s" % (args.l, p), format="set")
        #         except ConfigLoadError, e:
        #             if (e.rpc_error['severity']=='warning'):
        #                 print "Warning: %s" % e.message
        #             else:
        #                 raise
        # diff = config.diff()
        # if (diff!=None):
        #     print diff
        # config.commit()
        config = config.get_config()
        print(config)
        config.close()


def main():
    # Connect to the Junos device
    dev = Device(host='192.168.0.65', user='netbot', password='NGM4NmNmYzcwZjFmYWY2N2U1')
    dev.open()

    # Start a configuration session
    # rsp = dev.rpc.get_interface_information()
    # rsp = dev.rpc.get_prefix_list_information(prefix_list_name='STATIC_MITI')
    # print (etree.tostring(rsp, encoding='unicode'))

    prefix_list_config = """
    {
    "configuration" : { 
        "policy-options" : {
            "prefix-list" : [
            {
                "name" : "STATIC_MITI", 
                "prefix-list-item" : [
                {
                    "name" : "172.16.31.0/24"
                }
                ]
            }
            ]
        }
    }
}
"""

    # Load the prefix list configuration
    rpc_reply = dev.rpc.load_config(contents=prefix_list_config, format='json', context='private')
    commit_reply = dev.rpc.commit_configuration()
    print(commit_reply)

    # list_prefix_list(dev)
    # output = dev.cli('show configuration policy-options prefix-list STATIC_MITI')
    # print(output)


    # Commit the configuration
    # cu.commit_check()
    # cu.commit()

    # Close the configuration session and disconnect from the device

    dev.close()

main()
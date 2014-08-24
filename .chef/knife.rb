cookbook_path    ["cookbooks", "common-cookbooks", "site-cookbooks"]
node_path        "nodes"
role_path        "roles"
environment_path "environments"
data_bag_path    "data_bags"
ssl_verify_mode  :verify_peer
#encrypted_data_bag_secret "data_bag_key"

knife[:berkshelf_path] = "cookbooks"

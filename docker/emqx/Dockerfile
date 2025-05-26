FROM emqx/emqx-enterprise:5.9.0

# EMQX config file
COPY emqx/config/emqx.conf /opt/emqx/etc/emqx.conf

# ACL config file
COPY emqx/config/acl.conf /opt/emqx/etc/acl.conf

# The vm.args file configures the Erlang Virtual Machine (VM) that runs EMQX
# COPY docker/emqx/config/vm.args /opt/emqx/etc/vm.args

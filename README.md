# SOON\_ FM Salt States

This repository holds the salt states required for running SOON\_ FM.

## Running Locally

You can run a Salt Master and Salt Minion locally via Vagrant.

1. `vagrant up` will spawn a new Vagrant machine with a Salt Master and Minion installed
2. You **MUST** create a file called `/etc/salt/docker-registries.yaml`.  This should contain
   Docker credentials for docker registries we wish to pull containers from. For example:

   ``` yaml
   docker-registries:
     index.docker.io:
       username: <username>
       password: <password>
       email: <email>
     quay.io:
       username: <username>
       password: <password>
       email: <email>
   ```
3. Now you can run a `salt '*' state.highstate`.

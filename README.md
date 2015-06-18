# Usage

- Edit `data/user-data` to suit your needs
  - At the very least, replace my SSH key with yours
- Run `./build.sh <instance-id>`, where `instance-id` is the `cloud-init` instance ID you want to use
  - Note that an existing instance will re-init only if the `instance-id` changes
- Mount `out/<instance-id>.iso` on your cloud-init-powered VM

# cloud-fwaas

A Cloud Firewall as a Services by Suricata and Elasticsearch/Opensearch

# Deploy

it depends on `packer` and `terraform` for build AMI and deploy infrastruct, please refer their documents:
- [Install Packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

run the `deploy.sh` script to create the AMI and deploy firewall VPC/ASG/GWLB/Endpoint

# ToDo

- [ ] logstash
- [ ] opensearch & dashboard
- [ ] config manage
- [ ] please open an issue

# Credits

- for IDS, it use [Suricata](https://github.com/OISF/suricata)
- for dashboard, it use [Opensearch Dashboard/Kibana](https://github.com/opensearch-project)
- for deployment, it is recommand to use GENEVE protocol and achieve high available

Any question you can open an issue or connect me directly, thanks for star it.


## Terraform Environment Variables
- https://www.terraform.io/cli/config/environment-variables

## azcli
### vm image list
- Publisher: The organization that created the image. Examples: Canonical, RedHat, OpenLogic
- Offer: The name of a group of related images created by a publisher. Examples: UbuntuServer, RHEL, CentOS
- SKU: An instance of an offer, such as a major release of a distribution. Examples: 16.04-LTS, 7-RAW, 7.5
- Version: The version number of an image SKU.
```
az vm image list -f CentOS -p OpenLogic -s 7 -l koreacentral --all
```
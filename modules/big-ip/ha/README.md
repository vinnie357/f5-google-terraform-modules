# BIG-IP instance module

This module encapsulates the creation of BIG-IP HA cluster.

*Note:* This module is unsupported and not an official F5 product.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| google | >= 3.19 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_secret\_manager\_key | The Secret Manager key for BIG-IP admin password; during initialisation, the<br>BIG-IP admin account's password will be changed to the value retreived from GCP<br>Secret Manager using this key.<br><br>NOTE: if the secret does not exist, is misidentified, or if the VM cannot read<br>the secret value associated with this key, then the BIG-IP onboarding will fail<br>to complete, and onboarding will require manual intervention. | `string` | n/a | yes |
| allow\_phone\_home | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | `true` | no |
| allow\_usage\_analytics | Allow the BIG-IP VMs to send anonymous statistics to F5 to help us determine how<br>to improve our solutions (default). If set to false no statistics will be sent. | `bool` | `true` | no |
| as3\_payloads | An optional, but recommended, list of AS3 JSON files that can be used to setup<br>the BIG-IP instances. If left empty (default), the module will use a simple<br>no-op AS3 declaration. | `list(string)` | `[]` | no |
| automatic\_restart | Determines if the BIG-IP VMs should be automatically restarted if terminated by<br>GCE. Defaults to true to match expected GCE behaviour. | `bool` | `true` | no |
| default\_gateway | Set this to the value to use as the default gateway for BIG-IP instances. This<br>could be an IP address or environment variable to use at run-time. If left blank,<br>the onboarding script will use the gateway for nic0.<br><br>Default value is '$EXT\_GATEWAY' which will match the run-time upstream gateway<br>for nic0.<br><br>NOTE: this string will be inserted into the boot script as-is; it can | `string` | `"$EXT_GATEWAY"` | no |
| delete\_disk\_on\_destroy | Set this flag to false if you want the boot disk associated with the launched VMs<br>to survive when instances are destroyed. The default value of true will ensure the<br>boot disk is destroyed when the instance is destroyed. | `bool` | `true` | no |
| description | An optional description that will be applied to the instances. Default value is<br>an empty string, which will be replaced by a generated description at run-time. | `string` | `""` | no |
| disk\_size\_gb | Use this flag to set the boot volume size in GB. If left at the default value<br>the boot disk will have the same size as specified in 'bigip\_image'. | `number` | `null` | no |
| disk\_type | The boot disk type to use with instances; can be 'pd-ssd' (default), or<br>'pd-standard'.<br>\*Note:\* Choosing 'pd-standard' will reduce operating cost, but at the expense of<br>network performance. | `string` | `"pd-ssd"` | no |
| do\_payloads | The Declarative Onboarding contents to apply to the instances. This<br>module has migrated to use of Declarative Onboarding for module activation,<br>licensing, NTP, DNS, and other<br>basic configurations. Sample payloads are in the examples folder.<br><br>Note: if left empty, the module will use a simple JSON that sets NTP and DNS,<br>and enables LTM module, and configures a sync-group with active-standby failover<br>among the instances. | `list(string)` | `[]` | no |
| enable\_os\_login | Set to true to enable OS Login on the VMs. Default value is false as BIG-IP does<br>not support in OS Login mode currently.<br>NOTE: this value will override an 'enable-oslogin' key in `metadata` map. | `bool` | `false` | no |
| enable\_serial\_console | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| external\_subnetwork | The fully-qualified self-link of the subnet that will be used for external ingress<br>(2+ NIC deployment), or for all traffic in a 1NIC deployment. | `string` | n/a | yes |
| external\_subnetwork\_network\_ips | A required list of IP addresses to assign to BIG-IP instances on their external<br>interface. | `list(string)` | n/a | yes |
| external\_subnetwork\_tier | The network tier to set for external subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the external interface is<br>permitted to have a public IP address (see `provision_external_public_ip`) | `string` | `"PREMIUM"` | no |
| external\_subnetwork\_vip\_cidrs | An optional list of VIP CIDRs to assign to the *active* BIG-IP instances on its<br>external interface. E.g. to assign two CIDR blocks as VIPs:-<br><br>external\_subnetwork\_vip\_cidrs = [<br>  "10.1.0.0/16",<br>  "10.2.0.0/24",<br>] | `list(string)` | `[]` | no |
| image | The self-link URI for a BIG-IP image to use as a base for the VM cluster. This<br>can be an official F5 image from GCP Marketplace, or a customised image. | `string` | n/a | yes |
| instance\_name\_template | A format string that will be used when naming instance, that should include a<br>format token for including ordinal number. E.g. 'bigip-%d', such that %d will<br>be replaced with the ordinal of each instance. Default value is 'bigip-%d'. | `string` | `"bigip-%d"` | no |
| internal\_subnetwork\_network\_ips | Alist of lists of IP addresses to assign to BIG-IP instances on their internal<br>interfaces. Required if the instances have 3+ networks defined.<br><br>E.g. to assign addresses to two internal networks:-<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "10.0.0.4", # first internal nic<br>    "10.0.1.4", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    "10.0.0.5",<br>    "10.0.1.5",<br>  ],<br>  ...<br>] | `list(list(string))` | `[]` | no |
| internal\_subnetwork\_tier | The network tier to set for internal subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the internal interface is<br>permitted to have a public IP address (see `provision_internal_public_ip`) | `string` | `"PREMIUM"` | no |
| internal\_subnetwork\_vip\_cidrs | An optional list of CIDRs to assign to *active* BIG-IP instance as VIPs on its<br>internal interface. E.g. to assign two CIDR blocks as VIPs:-<br><br>internal\_subnetwork\_vip\_cidrs = [<br>  "10.1.0.0/16",<br>  "10.2.0.0/24",<br>] | `list(string)` | `[]` | no |
| internal\_subnetworks | An optional list of fully-qualified subnet self-links that will be assigned as<br>internal traffoc on NICs eth[2-8]. | `list(string)` | `[]` | no |
| labels | An optional map of *labels* to add to the instance template. | `map(string)` | `{}` | no |
| license\_type | A BIG-IP license type to use with the BIG-IP instance. Must be one of "byol" or<br>"payg", with "byol" as the default. If set to "payg", the image must be a PAYG<br>image from F5's official project or the instance will fail to onboard correctly. | `string` | `"byol"` | no |
| machine\_type | The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,<br>or a customised VM ('custom-VPCUS-MEM\_IN\_MB'). Default value is 'n1-standard-4'.<br>\*Note:\* machine\_type is highly-correlated with network bandwidth and performance;<br>an N2 or N2D machine type will give better performance but has limited availability. | `string` | `"n1-standard-4"` | no |
| management\_subnetwork | An optional fully-qualified self-link of the subnet that will be used for<br>management access (2 or 3 NIC deployment). | `string` | `null` | no |
| management\_subnetwork\_network\_ips | A list of IP addresses to assign to BIG-IP instances on their management<br>interface. Required if there are 2+ NICs defined for instances. | `list(string)` | `[]` | no |
| management\_subnetwork\_tier | The network tier to set for management subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the management interface is<br>permitted to have a public IP address (see `provision_management_public_ip`) | `string` | `"PREMIUM"` | no |
| management\_subnetwork\_vip\_cidrs | An optional list of CIDRs to assign to *active* BIG-IP instance as VIPs on its<br>management interface. E.g. to assign two CIDR blocks as VIPs:-<br><br>management\_subnetwork\_vip\_cidrs = [<br>  "10.1.0.0/16",<br>  "10.2.0.0/24",<br>] | `list(string)` | `[]` | no |
| metadata | An optional map of metadata values that will be applied to the instances. | `map(string)` | `{}` | no |
| min\_cpu\_platform | An optional constraint used when scheduling the BIG-IP VMs; this value prevents<br>the VMs from being scheduled on hardware that doesn't meet the minimum CPU<br>microarchitecture. Default value is 'Intel Skylake'. | `string` | `"Intel Skylake"` | no |
| num\_instances | The number of BIG-IP instances to provision in HA cluster. Default value is 2. | `number` | `2` | no |
| preemptible | If set to true, the BIG-IP instances will be deployed on preemptible VMs, which<br>could be terminated at any time, and have a maximum lifetimne of 24 hours. Default<br>value is false. | `string` | `false` | no |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| provision\_external\_public\_ip | If this flag is set to true (default), a publicly routable IP address WILL be<br>assigned to the external interface of instances. If set to false, the BIG-IP<br>instances will NOT have a public IP address assigned to the extenral interface. | `bool` | `true` | no |
| provision\_internal\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the internal interfaces of instances. If set to false (default), the BIG-IP<br>instances will NOT have a public IP address assigned to the internal interfaces. | `bool` | `false` | no |
| provision\_management\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the management interface of instances. If set to false (default), the BIG-IP<br>instances will NOT have a public IP address assigned to the management interface. | `bool` | `false` | no |
| service\_account | The service account that will be used for the BIG-IP VMs. | `string` | n/a | yes |
| ssh\_keys | An optional set of SSH public keys, concatenated into a single string. The keys<br>will be added to instance metadata. Default is an empty string.<br><br>See also `enable_os_login`. | `string` | `""` | no |
| tags | An optional list of *network tags* to add to the instance template. | `list(string)` | `[]` | no |
| use\_cloud\_init | If this value is set to true, cloud-init will be used as the initial<br>configuration approach; false (default) will fall-back to a standard shell<br>script for boot-time configuration.<br><br>Note: the BIG-IP version must support Cloud Init on GCP for this to function<br>correctly. E.g. v15.1+. | `bool` | `false` | no |
| zone | The compute zone which will host the BIG-IP VMs. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| external\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the external<br>NIC. |
| external\_public\_ips | A list of the public IP addresses assigned to instances on the external NIC. |
| external\_vips | A list of IP CIDRs asssigned to the active instance on its external NIC. |
| instance\_addresses | A map of instance name to assigned IP addresses and alias CIDRs. |
| internal\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the internal<br>NICs, if present. |
| internal\_public\_ips | A list of the public IP addresses assigned to instances on the internal NICs,<br>if present. |
| management\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the<br>management NIC, if present. |
| management\_public\_ips | A list of the public IP addresses assigned to instances on the management NIC,<br>if present. |
| self\_links | A list of self-links of the BIG-IP instances. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

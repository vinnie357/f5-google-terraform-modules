variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "zone" {
  type        = string
  description = <<EOD
The compute zone which will host the BIG-IP VMs.
EOD
}

variable "num_instances" {
  type        = number
  default     = 2
  description = <<EOD
The number of BIG-IP instances to provision in HA cluster. Default value is 2.
EOD
}

variable "instance_name_template" {
  type        = string
  default     = "bigip-%d"
  description = <<EOD
A format string that will be used when naming instance, that should include a
format token for including ordinal number. E.g. 'bigip-%d', such that %d will
be replaced with the ordinal of each instance. Default value is 'bigip-%d'.
EOD
}

variable "description" {
  type        = string
  default     = ""
  description = <<EOD
An optional description that will be applied to the instances. Default value is
an empty string, which will be replaced by a generated description at run-time.
EOD
}

variable "metadata" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of metadata values that will be applied to the instances.
EOD
}
variable "labels" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of *labels* to add to the instance template.
EOD
}

variable "tags" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of *network tags* to add to the instance template.
EOD
}

variable "min_cpu_platform" {
  type        = string
  default     = "Intel Skylake"
  description = <<EOD
An optional constraint used when scheduling the BIG-IP VMs; this value prevents
the VMs from being scheduled on hardware that doesn't meet the minimum CPU
microarchitecture. Default value is 'Intel Skylake'.
EOD
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-4"
  description = <<EOD
The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,
or a customised VM ('custom-VPCUS-MEM_IN_MB'). Default value is 'n1-standard-4'.
*Note:* machine_type is highly-correlated with network bandwidth and performance;
an N2 or N2D machine type will give better performance but has limited availability.
EOD
}

variable "service_account" {
  type = string
  validation {
    condition     = can(regex("(\\.iam|developer)\\.gserviceaccount\\.com$", var.service_account))
    error_message = "The service_account variable must be a valid GCP service account email address."
  }
  description = <<EOD
The service account that will be used for the BIG-IP VMs.
EOD
}

variable "automatic_restart" {
  type        = bool
  default     = true
  description = <<EOD
Determines if the BIG-IP VMs should be automatically restarted if terminated by
GCE. Defaults to true to match expected GCE behaviour.
EOD
}

variable "preemptible" {
  type        = string
  default     = false
  description = <<EOD
If set to true, the BIG-IP instances will be deployed on preemptible VMs, which
could be terminated at any time, and have a maximum lifetimne of 24 hours. Default
value is false.
EOD
}

variable "ssh_keys" {
  type        = string
  default     = ""
  description = <<EOD
An optional set of SSH public keys, concatenated into a single string. The keys
will be added to instance metadata. Default is an empty string.

See also `enable_os_login`.
EOD
}

variable "enable_os_login" {
  type        = bool
  default     = false
  description = <<EOD
Set to true to enable OS Login on the VMs. Default value is false as BIG-IP does
not support in OS Login mode currently.
NOTE: this value will override an 'enable-oslogin' key in `metadata` map.
EOD
}

variable "enable_serial_console" {
  type        = bool
  default     = false
  description = <<EOD
Set to true to enable serial port console on the VMs. Default value is false.
EOD
}

variable "image" {
  type = string
  validation {
    condition     = can(regex("^(https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/[a-z]([a-z0-9-]*[a-z0-9])?", var.image))
    error_message = "The image variable must be a fully-qualified URI."
  }
  description = <<EOD
The self-link URI for a BIG-IP image to use as a base for the VM cluster. This
can be an official F5 image from GCP Marketplace, or a customised image.
EOD
}

variable "delete_disk_on_destroy" {
  type        = bool
  default     = true
  description = <<EOD
Set this flag to false if you want the boot disk associated with the launched VMs
to survive when instances are destroyed. The default value of true will ensure the
boot disk is destroyed when the instance is destroyed.
EOD
}

variable "disk_type" {
  type        = string
  default     = "pd-ssd"
  description = <<EOD
The boot disk type to use with instances; can be 'pd-ssd' (default), or
'pd-standard'.
*Note:* Choosing 'pd-standard' will reduce operating cost, but at the expense of
network performance.
EOD
}

variable "disk_size_gb" {
  type        = number
  default     = null
  description = <<EOD
Use this flag to set the boot volume size in GB. If left at the default value
the boot disk will have the same size as specified in 'bigip_image'.
EOD
}

variable "external_subnetwork" {
  type = string
  validation {
    condition     = can(regex("^https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]*[a-z0-9])?$", var.external_subnetwork))
    error_message = "The external_subnetwork variable must be a fully-qualified self-link URI."
  }
  description = <<EOD
The fully-qualified self-link of the subnet that will be used for external ingress
(2+ NIC deployment), or for all traffic in a 1NIC deployment.
EOD
}

variable "provision_external_public_ip" {
  type        = bool
  default     = true
  description = <<EOD
If this flag is set to true (default), a publicly routable IP address WILL be
assigned to the external interface of instances. If set to false, the BIG-IP
instances will NOT have a public IP address assigned to the extenral interface.
EOD
}

variable "external_subnetwork_tier" {
  type    = string
  default = "PREMIUM"
  validation {
    condition     = contains(list("PREMIUM", "STANDARD"), var.external_subnetwork_tier)
    error_message = "The external_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for external subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the external interface is
permitted to have a public IP address (see `provision_external_public_ip`)
EOD
}

variable "external_subnetwork_network_ips" {
  type        = list(string)
  description = <<EOD
A required list of IP addresses to assign to BIG-IP instances on their external
interface.
EOD
}

variable "external_subnetwork_vip_cidrs" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of VIP CIDRs to assign to the *active* BIG-IP instances on its
external interface. E.g. to assign two CIDR blocks as VIPs:-

external_subnetwork_vip_cidrs = [
  "10.1.0.0/16",
  "10.2.0.0/24",
]
EOD
}

variable "management_subnetwork" {
  type    = string
  default = null
  validation {
    condition     = var.management_subnetwork == null || var.management_subnetwork == "" || can(regex("^https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]*[a-z0-9])?$", var.management_subnetwork))
    error_message = "The management_subnetwork variable must be a fully-qualified self-link URI."
  }
  description = <<EOD
An optional fully-qualified self-link of the subnet that will be used for
management access (2 or 3 NIC deployment).
EOD
}

variable "provision_management_public_ip" {
  type        = bool
  default     = false
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the management interface of instances. If set to false (default), the BIG-IP
instances will NOT have a public IP address assigned to the management interface.
EOD
}

variable "management_subnetwork_tier" {
  type    = string
  default = "PREMIUM"
  validation {
    condition     = contains(list("PREMIUM", "STANDARD"), var.management_subnetwork_tier)
    error_message = "The management_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for management subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the management interface is
permitted to have a public IP address (see `provision_management_public_ip`)
EOD
}

variable "management_subnetwork_network_ips" {
  type        = list(string)
  default     = []
  description = <<EOD
A list of IP addresses to assign to BIG-IP instances on their management
interface. Required if there are 2+ NICs defined for instances.
EOD
}

variable "management_subnetwork_vip_cidrs" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of CIDRs to assign to *active* BIG-IP instance as VIPs on its
management interface. E.g. to assign two CIDR blocks as VIPs:-

management_subnetwork_vip_cidrs = [
  "10.1.0.0/16",
  "10.2.0.0/24",
]
EOD
}

variable "internal_subnetworks" {
  type    = list(string)
  default = []
  validation {
    condition     = length(var.internal_subnetworks) < 7
    error_message = "A maximum of 6 internal subnetworks can be added to a VM."
  }
  validation {
    condition     = length(join("", [for url in var.internal_subnetworks : can(regex("^https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]*[a-z0-9])?$", url)) ? "x" : ""])) == length(var.internal_subnetworks)
    error_message = "Each internal_subnetworks value must be a fully-qualified self-link URI."
  }
  description = <<EOD
An optional list of fully-qualified subnet self-links that will be assigned as
internal traffoc on NICs eth[2-8].
EOD
}

variable "provision_internal_public_ip" {
  type        = bool
  default     = false
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the internal interfaces of instances. If set to false (default), the BIG-IP
instances will NOT have a public IP address assigned to the internal interfaces.
EOD
}

variable "internal_subnetwork_tier" {
  type    = string
  default = "PREMIUM"
  validation {
    condition     = contains(list("PREMIUM", "STANDARD"), var.internal_subnetwork_tier)
    error_message = "The internal_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for internal subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the internal interface is
permitted to have a public IP address (see `provision_internal_public_ip`)
EOD
}

variable "internal_subnetwork_network_ips" {
  type        = list(list(string))
  default     = []
  description = <<EOD
Alist of lists of IP addresses to assign to BIG-IP instances on their internal
interfaces. Required if the instances have 3+ networks defined.

E.g. to assign addresses to two internal networks:-

internal_subnetwork_network_ips = [
  # Will be assigned to first instance
  [
    "10.0.0.4", # first internal nic
    "10.0.1.4", # second internal nic
  ],
  # Will be assigned to second instance
  [
    "10.0.0.5",
    "10.0.1.5",
  ],
  ...
]
EOD
}

variable "internal_subnetwork_vip_cidrs" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of CIDRs to assign to *active* BIG-IP instance as VIPs on its
internal interface. E.g. to assign two CIDR blocks as VIPs:-

internal_subnetwork_vip_cidrs = [
  "10.1.0.0/16",
  "10.2.0.0/24",
]
EOD
}

variable "allow_usage_analytics" {
  type        = bool
  default     = true
  description = <<EOD
Allow the BIG-IP VMs to send anonymous statistics to F5 to help us determine how
to improve our solutions (default). If set to false no statistics will be sent.
EOD
}

variable "allow_phone_home" {
  type        = bool
  default     = true
  description = <<EOD
Allow the BIG-IP VMs to send high-level device use information to help F5
optimize development resources. If set to false the information is not sent.
EOD
}

variable "license_type" {
  type        = string
  default     = "byol"
  description = <<EOD
A BIG-IP license type to use with the BIG-IP instance. Must be one of "byol" or
"payg", with "byol" as the default. If set to "payg", the image must be a PAYG
image from F5's official project or the instance will fail to onboard correctly.
EOD
}

variable "default_gateway" {
  type        = string
  default     = "$EXT_GATEWAY"
  description = <<EOD
Set this to the value to use as the default gateway for BIG-IP instances. This
could be an IP address or environment variable to use at run-time. If left blank,
the onboarding script will use the gateway for nic0.

Default value is '$EXT_GATEWAY' which will match the run-time upstream gateway
for nic0.

NOTE: this string will be inserted into the boot script as-is; it can
EOD
}

variable "use_cloud_init" {
  type        = bool
  default     = false
  description = <<EOD
If this value is set to true, cloud-init will be used as the initial
configuration approach; false (default) will fall-back to a standard shell
script for boot-time configuration.

Note: the BIG-IP version must support Cloud Init on GCP for this to function
correctly. E.g. v15.1+.
EOD
}

variable "admin_password_secret_manager_key" {
  type        = string
  description = <<EOD
The Secret Manager key for BIG-IP admin password; during initialisation, the
BIG-IP admin account's password will be changed to the value retreived from GCP
Secret Manager using this key.

NOTE: if the secret does not exist, is misidentified, or if the VM cannot read
the secret value associated with this key, then the BIG-IP onboarding will fail
to complete, and onboarding will require manual intervention.
EOD
}

variable "as3_payloads" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional, but recommended, list of AS3 JSON files that can be used to setup
the BIG-IP instances. If left empty (default), the module will use a simple
no-op AS3 declaration.
EOD
}

variable "do_payloads" {
  type        = list(string)
  default     = []
  description = <<EOD
The Declarative Onboarding contents to apply to the instances. This
module has migrated to use of Declarative Onboarding for module activation,
licensing, NTP, DNS, and other
basic configurations. Sample payloads are in the examples folder.

Note: if left empty, the module will use a simple JSON that sets NTP and DNS,
and enables LTM module, and configures a sync-group with active-standby failover
among the instances.
EOD
}

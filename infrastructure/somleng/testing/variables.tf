locals {
  region           = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  use_nat_instance = lower(var.use_nat_instance) == "y"
}

variable "use_nat_instance" {
  description = "Use the NAT instance? y or n"
  type        = string
  validation {
    condition     = can(regex("^[yYnN]$", var.use_nat_instance))
    error_message = "You must enter 'y' or 'n'."
  }
}

linux_vm = {
  vm01 = {
    rgname     = "monalrg"
    location   = "westus"
    pipname    = "monal-ip"
    subnetname = "monal-subnet"
    vnetname   = "monal-vnet"
    nicname    = "frontendnic"
    vmname     = "monalvm"
    size       = "Standard_DS1_v2"
    username   = "adminuser"
    password   = "admin@123456"

  }
}
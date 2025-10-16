# main.tf
provider "local" {}

resource "local_file" "example" {
  content  = "Mini Toolchain Terraform output!"
  filename = "${path.module}/output.txt"
}

resource "local_file" "dir" {
  content  = ""
  filename = "${path.module}/mini-dir/placeholder.txt"  # Creates a directory implicitly
}

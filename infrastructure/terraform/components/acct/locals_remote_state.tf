locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket = local.terraform_state_bucket

    key = format(
      "%s/%s/%s/%s/bootstrap.tfstate",
      var.project,
      var.aws_account_id,
      "eu-west-2",
      "bootstrap"
    )

    region = "eu-west-2"
  }
}

locals {
  bootstrap = data.terraform_remote_state.bootstrap.outputs
  acct      = data.terraform_remote_state.acct.outputs
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

data "terraform_remote_state" "acct" {
  backend = "s3"

  config = {
    bucket = local.terraform_state_bucket

    key = format(
      "%s/%s/%s/%s/acct.tfstate",
      var.project,
      var.aws_account_id,
      "eu-west-2",
      var.parent_acct_environment
    )

    region = "eu-west-2"
  }
}

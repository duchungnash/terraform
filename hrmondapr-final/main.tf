module "final-hrm-main" {
  source = "../hrmondapr"
  env = "main"
  rg_location    = "centralus"
  rg_name     = "hrmondapr"
}

module "final-hrm-release" {
  source = "../hrmondapr"
  env = "release"
  rg_location    = "centralus"
  rg_name     = "hrmondapr"
}
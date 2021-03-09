resource "aws_ecrpublic_repository" "somleng" {
  repository_name = "somleng"
  provider = aws.us-east-1

  catalog_data {
    about_text        = "Somleng"
    architectures     = ["Linux"]
    description       = "Somleng's offical Docker registry"
    logo_image_blob   = filebase64("../../../public/website/images/somleng_logo.png")
  }
}

resource "aws_chime_voice_connector" "this" {
  name               = "somleng"
  require_encryption = false
  aws_region         = "us-east-1"
  provider          = aws.us-east-1
}

resource "aws_chime_voice_connector_termination" "this" {
  cidr_allow_list    = ["13.250.230.15/32"]
  calling_regions    = ["KH"]
  voice_connector_id = aws_chime_voice_connector.this.id
}

resource "aws_chime_voice_connector_origination" "this" {
  voice_connector_id = aws_chime_voice_connector.this.id

  route {
    host     = "52.74.4.205"
    port     = 5060
    protocol = "UDP"
    priority = 1
    weight   = 1
  }
}

resource "aws_chime_voice_connector_logging" "this" {
  enable_sip_logs    = true
  voice_connector_id = aws_chime_voice_connector.this.id
}

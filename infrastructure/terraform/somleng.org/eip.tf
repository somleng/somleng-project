# resource "aws_eip" "freeswitch" {
#   vpc = true
#
#   tags {
#     Name = "FreeSWITCH Public IP"
#   }
# }
#
# resource "aws_eip_association" "freeswitch" {
#   instance_id   = "${element(module.somleng_freeswitch_webserver.instances, 0)}"
#   allocation_id = "${aws_eip.freeswitch.id}"
# }

module "associate_eip" {
  source = "../modules/associate_eip"
}

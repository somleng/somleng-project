resource "aws_iam_user" "samnang" {
  name = "samnang"
}

resource "aws_iam_user" "dwilkie" {
  name = "dwilkie"
}

resource "aws_iam_group" "readonly_admin" {
  name = "readonly-admin"
}

resource "aws_iam_group_policy_attachment" "readonly_admin" {
  group      = aws_iam_group.readonly_admin.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "billing" {
  group      = aws_iam_group.readonly_admin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

resource "aws_iam_user_group_membership" "samnang" {
  user = aws_iam_user.samnang.name

  groups = [
    aws_iam_group.readonly_admin.name,
  ]
}

resource "aws_iam_user_group_membership" "dwilkie" {
  user = aws_iam_user.dwilkie.name

  groups = [
    aws_iam_group.readonly_admin.name,
  ]
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_users-self-manage-mfa-and-creds.html
resource "aws_iam_policy" "enforce_mfa" {
  name = "enforce_mfa"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowViewAccountInfo",
      "Effect":"Allow",
      "Action": [
        "iam:ListVirtualMFADevices",
        "iam:ListUsers"
      ],
      "Resource":"*"
    },
    {
      "Sid":"AllowManageOwnVirtualMFADevice",
      "Effect":"Allow",
      "Action":[
        "iam:CreateVirtualMFADevice"
      ],
      "Resource":"arn:aws:iam::*:mfa/*"
    },
    {
      "Sid":"DenyAllExceptListedIfNoMFA",
      "Effect":"Deny",
      "NotAction":[
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ListUsers",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource":"*",
      "Condition":{
        "BoolIfExists":{
          "aws:MultiFactorAuthPresent":"false"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "enforce_mfa" {
  group      = aws_iam_group.readonly_admin.name
  policy_arn = aws_iam_policy.enforce_mfa.arn
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
resource "aws_iam_policy" "manage_access_keys_dwilkie" {
  name = "manage_access_keys_dwilkie"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"CreateOwnAccessKeys",
      "Effect":"Allow",
      "Action":[
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:GetAccessKeyLastUsed",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:UpdateAccessKey",
        "iam:TagUser"
      ],
      "Resource":[
        "${aws_iam_user.dwilkie.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "manage_access_keys_dwilkie" {
  user       = aws_iam_user.dwilkie.name
  policy_arn = aws_iam_policy.manage_access_keys_dwilkie.arn
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
resource "aws_iam_policy" "manage_access_keys_samnang" {
  name = "manage_access_keys_samnang"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"CreateOwnAccessKeys",
      "Effect":"Allow",
      "Action":[
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:GetAccessKeyLastUsed",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:UpdateAccessKey",
        "iam:TagUser"
      ],
      "Resource":[
        "${aws_iam_user.samnang.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "manage_access_keys_samnang" {
  user       = aws_iam_user.samnang.name
  policy_arn = aws_iam_policy.manage_access_keys_samnang.arn
}

resource "aws_iam_policy" "manage_mfa_device_dwilkie" {
  name = "manage_mfa_device_dwilkie"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowManageOwnUserMFA",
      "Effect":"Allow",
      "Action":[
        "iam:DeactivateMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:GetMFADevice",
        "iam:ListMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource":[
        "${aws_iam_user.dwilkie.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "manage_mfa_device_dwilkie" {
  user       = aws_iam_user.dwilkie.name
  policy_arn = aws_iam_policy.manage_mfa_device_dwilkie.arn
}

resource "aws_iam_policy" "manage_mfa_device_samnang" {
  name = "manage_mfa_device_samnang"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowManageOwnUserMFA",
      "Effect":"Allow",
      "Action":[
        "iam:DeactivateMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:GetMFADevice",
        "iam:ListMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource":[
        "${aws_iam_user.samnang.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "manage_mfa_device_samnang" {
  user       = aws_iam_user.samnang.name
  policy_arn = aws_iam_policy.manage_mfa_device_samnang.arn
}
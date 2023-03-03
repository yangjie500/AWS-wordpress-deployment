locals {
  file_path = {
    file1 = {
      path = "../ansible/roles/wordpress/vars/tf_ansible_vars_file.yaml",
      name = "ansible/roles/wordpress/vars/tf_ansible_vars_file.yaml"
    }
    file2 = {
      path = "../ansible/roles/lb_url/vars/tf_ansible_vars_file.yaml",
      name = "ansible/roles/lb_url/vars/tf_ansible_vars_file.yaml"
    }
  }
}
resource "local_file" "tf_ansible_vars_file" {
  for_each = local.file_path
  content = <<-DOC
    tf_rds_endpoint: ${aws_db_instance.my_rds.address}
    tf_username: ${aws_db_instance.my_rds.username}
    tf_database_name: ${aws_db_instance.my_rds.db_name}
    tf_password: ${var.db_password}
    tf_lb_domain: http://${aws_lb.my_lb.dns_name}
  DOC
  filename = each.value.path
  depends_on = [
    aws_db_instance.my_rds,
    aws_lb.my_lb
  ]

  provisioner "local-exec" {
    command = "aws s3 cp ${each.value.path} s3://${aws_s3_bucket.my_s3_bucket.id}/${each.value.name} --profile=admin"
  }
}

resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = var.S3_name
}

resource "aws_s3_object" "ansible_playbook" {
  for_each = fileset("../", "ansible/**")
  bucket = aws_s3_bucket.my_s3_bucket.bucket
  key = each.value
  source = "../${each.value}"
  etag = filemd5("../${each.value}")

}

# resource "aws_s3_object" "dynamic_generated_ansible_playbook" {
#   for_each = local.file_path
#   bucket = aws_s3_bucket.my_s3_bucket.bucket
#   key = each.value
#   source = local_file.tf_ansible_vars_file[each.key].source
# }

data "aws_iam_policy_document" "allow_SSM_read_write_S3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.my_s3_bucket.arn}",
      "${aws_s3_bucket.my_s3_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "SSMInstanceProfileS3Policy" {
  name = "MY-SSMInstanceProfileS3Policy"
  policy = data.aws_iam_policy_document.allow_SSM_read_write_S3.json
}

data "aws_iam_policy_document" "allow_SSM_assume_role" {
  statement {
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    effect = "Allow"
  }
}

resource "aws_iam_role" "AssumeEC2Role" {
  name = "AssumeEC2Role"
  assume_role_policy = data.aws_iam_policy_document.allow_SSM_assume_role.json
}

locals {
  policy = {
    one = "${aws_iam_policy.SSMInstanceProfileS3Policy.arn}"
    two = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    three = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
  }
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  for_each = local.policy

  role = aws_iam_role.AssumeEC2Role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "my-instance-profile"
  role = aws_iam_role.AssumeEC2Role.name
}

# output "test1" {
#   value = aws_iam_instance_profile.my_instance_profile[*].arn
# }
# output "test2" {
#   value = aws_iam_instance_profile.my_instance_profile[*].name
# }

locals {
  source_info = {
    path = "https://${aws_s3_bucket.my_s3_bucket.bucket_domain_name}/ansible/"
  }
}

output "test" {
  value = "${jsonencode(local.source_info)}"
}

resource "aws_ssm_association" "my_ssm_association" {
  name = "AWS-ApplyAnsiblePlaybooks"
  association_name = "my-ansible-playbook-sm"

  parameters = {
    SourceType = "S3"
    SourceInfo = "${jsonencode(local.source_info)}"
    InstallDependencies = "True"
    PlaybookFile = "playbook.yaml"
    Check = "False"
    Verbose = "-vvvv"
  }

  output_location {
    s3_bucket_name = aws_s3_bucket.my_s3_bucket.bucket
    s3_key_prefix = "output"
  }

  targets {
    key = "tag:Type"
    values = ["My-ASG"]
  }
  depends_on = [
    aws_s3_object.ansible_playbook,
    local_file.tf_ansible_vars_file
  ]
}
output "dev_ip" {
    value= aws_instance.new-ec2.public_ip 
}
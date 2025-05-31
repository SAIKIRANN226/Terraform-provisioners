resource "aws_instance" "web" {
  ami           = "ami-03265a0778a880afb"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.roboshop-all.id]
  tags = {
    Name = "provisioner"
  }

  provisioner "local-exec" {
    command = "echo this will execute at the time of creation, you can trigger other system like send email and alerts"
  } # The above is just a provisioner syntax block example.

  provisioner "local-exec" {
    command = "echo ${self.private_ip} > inventory" # Self is a keyword which provisioners will unable, that means instead of using "aws_instance.web.private_ip". So now it is with in the resource and we can use self keyword that is, self = aws_instance.web ; this IP_address will be stored in inventory ; local exec will only run one time, to run again we need to destroy and then try. So what terraform will do ? terraform will run this command which is in local-exec as soon as after creation of instance and it will print the server ip_address which is private_ip, so provisioners are useful to integrate terraform with configuration management tools like ansible to get end-end automation.
  }

  # provisioner "local-exec" {
  #   command = "ansible-playbook -i inventory web.yaml" # self = aws_instance.web
  # } This is used to integrate terraform and ansible it will be used in roboshop project later.

  provisioner "local-exec" { # It is for local exec
    when = destroy     # It is a keyword
    command = "echo this will execute at the time of destroy, you can trigger other system like email and sending alerts"
  }

  connection { # This block is to connect to remote servers which is remote exec.
    type     = "ssh"
    user     = "centos"
    password = "DevOps321"
    host     = self.public_ip
  }        

  provisioner "remote-exec" {
    inline = [
      "echo 'this is from remote exec' > /tmp/remote.txt",  # After successful connection to the remote instance then this command will run inside the server and save it in tmp/remote.txt, generally this will be useful when you want to install like sudo commands or other commands also if you want.
      "sudo yum install nginx -y",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_security_group" "roboshop-all" { # We need securitygroup for secure connection which is ssh 22 to connect to remote-exec
    name        = "provisioner"

    ingress {
        description      = "Allow All ports"
        from_port        = 22 
        to_port          = 22 
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description      = "Allow All ports" # Why we added this rule 80 because we installed nginx in remote machine which is in line 36
        from_port        = 80 
        to_port          = 80 
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
        Name = "provisioner"
    }
}


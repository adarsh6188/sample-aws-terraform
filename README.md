# sample-aws-terraform

 This sample code is used to create new VPC and subnets and a t2.micro ec2 instance with apache installed (specified in the user data)
 You need to add the **access key** and **secret key** in the **[main.tf](https://github.com/adarsh6188/sample-aws-terraform/blob/main/main.tf)** file
 also please specify the **`key_name`**  for the ec2 instace under `aws_instance`resource section.
 
![alt text](https://user-images.githubusercontent.com/52464718/110127240-4f709000-7dbd-11eb-924a-523e7ffa9661.png)

This will shows the output of the associated elastic ip to the server once the code execution is completed.

![alt_text](https://user-images.githubusercontent.com/52464718/110127940-213f8000-7dbe-11eb-8333-8b8038111548.png)


`terraform apply` is the command to execute the code and craete the resources

`terraform destroy`is used to destroy all the resorces that are created by terraform

# SRE Code Challenge - Go Outyet Webservice

This Terraform config deploys the outyet webservice infrastructure. It's a webservice that tells you if a version of golang has been released. The webservice is designed to be highly available in a single AWS region

## Prerequisites
- AWS account with CLI access keys
- Cloudflare free account with CLI access token
- Terraform 0.12
- TLS cert pre-created on AWS ACM
- DNS zone pre-created on Cloudflare

## How This Works

The Terraform config creates an Application Load Balancer (with target groups, listeners, etc), EC2 Autoscaling Group (with EC2 Instances, launch configs, etc), NAT Gateways for each backend subnet, Internet Gateway, VPC, frontend and backend subnets for 3 availability zones (one subnet of each type per AZ). It also creates a CloudFlare CNAME record to alias to the ALB's public record


## Predeployment Steps

NOTE: 
 - This guide assumes that Terraform 0.12 is installed
 - This guide assumes that AWS CLI is already installed and access keys configured in the default profile
 - This guide assumes that you've already created a Cloudflare token to be used by Terraform with the following permissions applied to the appropriate zone:
```
 Zone.Zone Read
 Zone.DNS  Edit
```

Step 0: Clone this repo: `git clone git@github.com:mujahidhemani/terraform-aws-srecc-outyet.git`

### Setup a Cloudflare Zone

NOTE: You will need to use a domain you already own for this.

1. Login to your Cloudflare account at https://dash.cloudflare.com
2. From Home, click on Add Site
3. Enter your domain and click Add site
4. Select the Free plan level and click Confirm plan
5. Cloudflare will scan to see if there are any DNS records to import; if this is an empty zone create a TXT record, with the record name `demo` and value `test` and click Continue
6. The page will now display your nameserver records. In your domain registrar's portal, update the NS records to the ones from Cloudflare. This mnay take some time to propogate to DNS servers globally. 

Once you have finished adding your zone to Cloudflare, return to Cloudflare Home at https://dash.cloudflare.com

### Configure Cloudflare Zone

1. From Home, click on the domain tile you have just added.
2. You are now in the management portal for your domain. Click on SSL/TLS icon
3. Change the SSL/TLS setting to Off (not secure). We will be doing TLS termination on the ALB as configured by Terraform.
4. Click on Overview. Scroll down until you see Zone ID on the right side. Make note of the Zone ID as you will need this to configure the .tfvars file in the next steps

### Create TLS Certificate in AWS ACM

1. Login to your Amazon AWS account at https://console.aws.amazon.com
2. Go to the Certificate Manager service
3. Click on Request a certificate
4. Ensure you have selected Request a public certificate and click the Request a certificate button
5. Type the wildcard name of the domain you already added to Cloudflare, ex: `*.outyet.info`. If you'd like to secure other sites with the same certificate, such a development zone/environment you can also add this, ex: `*.dev.outyet.info`, `outyet.info`, etc. Click next once you've added sites
6. Select DNS Validation and click Review. With this method, ACM will query your DNS zone to validate you are the legitimate owner
7. Ensure the information in the review screen is correct. Click Confirm and request
8. On the validation screen, you will see CNAME records that will need to exist in your Cloudflare zone you created earlier. Add these records to your Cloudflare zone through https://dash.cloudflare.com. As long as these records exist in DNS, ACM will be able issue new certificates.
9. Once you've added the DNS records to your Cloudflare zone, click Continue.
10. You will be returned to the dashboard to view your TLS certificate. The status will change from Pending Validation to Issued once ACM validates the ownership of the domain. Make note of the ARN in a text file as we will need this to configure the .tfvars file in the next steps

## Deployment Steps

1. In the root of the cloned repo, create a .tfvars file, ex `touch outyet.tfvars`
2. Open the .tfvars file in your favourite text editor, and ensure its populated, substituting:
```hcl
cloudflare_dns_record_name = "<Name of DNS record to alias the load balancer, ex. 'go'"
cloudflare_zone_id         = "<Cloudflare Zone ID recorded earlier from Configure Cloudflare Zone>"
tls_cert_arn               = "<ARN value of TLS cert recorded earlier from Create TLS Certificate in AWS ACM>"
```
3. Ensure you've set your Cloudflare token as an environment variable `export CLOUDFLARE_API_TOKEN=<Cloudflare API token>`
4. Ensure you've set the AWS region to us-east-1 as an environment variable `export AWS_REGION=us-east-1`
5. Initialize Terraform: `terraform init`
6. Run Terraform plan: `terraform plan -var-file=outyet.tfvars`
7. Run Terraform apply: `terraform apply -var-file=outyet.tfvars` and Enter `yes` to proceed with plan
8. Once Terraform has finshed applying, you should be able to curl your DNS record: ex `curl -L go.outyet.info` and receive a response:

```
<!DOCTYPE html><html><body><center>
	<h2>Is Go 1.4 out yet?</h2>
	<h1>
	
		<a href="https://go.googlesource.com/go/&#43;/go1.4">YES!</a>
	
	</h1>
</center></body></html>
```
 

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloudflare\_dns\_record\_name | Name of the CNAME record to alias to the public load balancer record | string | n/a | yes |
| cloudflare\_zone\_id | Zone ID of the Cloudflare zone where record will be created | string | n/a | yes |
| tls\_cert\_arn | The ARN of the TLS certificate to attach to the load balancer listeners | string | n/a | yes |


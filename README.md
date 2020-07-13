# test-case-ADM


Hello!

How long did you spend on the coding test?
-- Approximately 5-6 hours and 1 day on tests

What would you add to your solution if you had more time?
-- More clean code. Encription for Database password

Why did you choose the language you used for the coding test?
-- I use terraform hcl because it is most convenient to work with AWS

What was the most useful feature that was added to the latest version of your chosen language?
-- New syntax :)

Why did you choose this Kubernetes service you used for the test?
-- EKS is a native service for AWS and terraform has very convenient modules

Sorry for long time, but at friday I decide to rewrite all code from terraform + ansible to complete terraform and switch on usage of native AWS services


Now it is very simple.

I try to create logical structure

"_config.tf" - It describes main configuration for terraform and providers

"database.tf" - Describes multy-AZ RDS

"irsa.tf, kubecluster.tf" - Describes kubernetes and IAM roles for service account for cluster-autoscaler

"network.tf, security-groups.tf" - Describes networks VPC an SG.

of cource .gitignore for terrafom state files and modules

# How to Use this solution.

Requirements

AWS account, "ADMIN" IAM role

Installed terrafom, helm3, kubectl.

Let's start

1. Checkout repo

       git@github.com:denis-khokhriakov/test-case-ADM.git

2. go to test-case-ADM/terraform and just do

       terraform init
       terraform plan
       terraform apply

Approximately in 10-15 minutes infrastructure Will be completly setted up.

After successfuly completed tasks you will have outputs on screen with accountID, cluster name, cluster endpoint, and kubeconfig.
Cubeconfig will be also stored in working directory

3. Then type

        alias ktest=export\ KUBECONFIG=<"Path to repo">test-case-ADM/terraform/kubeconfig_test-kubecluster

4. Then type

        ktest

Congatulations, you have k8s cluster and access to it.

Then we need to configure autoscaling.

5. Move to level up directory and use Helm

        helm repo add stable https://kubernetes-charts.storage.googleapis.com/

6. Edit cluster-autoscaler.yml and replace "<ACCOUNTID>" on ID of your AWS account(Shown in terraform outputs)

7. Then

        helm install cluster-autoscaler stable/cluster-autoscaler --values=cluster-autoscaler.yml --namespace kube-system

8. Then check logs of pod

        kubectl logs "autoscaler-pod-name" -n kube-system

9. Then we need to install WordPress

Add repo with WP

        helm repo add bitnami https://charts.bitnami.com/bitnami

10. Install WP by helm

        helm install wordpress bitnami/wordpress \
        --set mariadb.enabled=false \
        --set externalDatabase.host=test-mysql.c39j6npahvpk.eu-central-1.rds.amazonaws.com \
        --set externalDatabase.user=admin \
        --set externalDatabase.password="YourDbPassword" \
        --set externalDatabase.database=testwpdb \
        --set externalDatabase.port=3306

11. After installation

To access your WordPress site from outside the cluster follow the steps below:

  1. Get the WordPress URL by running these commands:

    NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace default -w wordpress'

    export SERVICE_IP=$(kubectl get svc --namespace default wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
    echo "WordPress URL: http://$SERVICE_IP/"
    echo "WordPress Admin URL: http://$SERVICE_IP/admin"

  2. Open a browser and access WordPress using the obtained URL.

  3. Login with the following credentials below to see your blog:

    echo Username: user
    echo Password: $(kubectl get secret --namespace default wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)

Thats all.

If you have any questions, feel free to ask.

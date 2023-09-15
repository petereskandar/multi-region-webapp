# Multi-Region Web App to Manage Disaster Recovery

Terraform Project is used to Setup a Multi-Region Web APP deployed using AWS ECS Fargate and exposed publicly using an Application Load Balancer.

The DR Infrastructure is based on Route53 Health Checks which will swtich to the **Secondary Region** in case of a **Primary Region** Failure.

The below Diagram describes the App Infrastructure :

![plot](./img/infra.jpg)


<!-- blank line -->
-  **Inputs :**

The following inputs should be added to the **metadata.yml** 

| **Input** 	| **Mandatory** 	|            **Default Value**            	|
|:---------------:	|------------	|:-----------------------------------:	|
|       domain_name      	| TRUE 	| Null 	|
|       domain_name_suffix      	| FALSE 	| webapp 	|
|       vpc_cidr      	| FALSE 	| 10.0.0.0/16 	|



## Azure DevOps Service Account

`kubectl apply -f serviceAccount.yml`

Once, this resource has been created, run the following commands, to get the K8s ServiceAccount secret value for the Azure DevOps `Service Connection`.

Create a new Service Connection, of type Kubernetes, and use the following commands to get the values.

To get the Server Url:
```
kubectl config view --minify -o jsonpath={.clusters[0].cluster.server}
```


Get the json value of the secret, then run:
```
kubectl get secret $(kubectl get serviceAccounts azure-devops -n default -o=jsonpath={.secrets[*].name}) -n default -o json
```
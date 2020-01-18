## Dashboard URL

`https://192.168.12.50:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy`

## Admin Token

`kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')`
# Orientando on Kubernetes

### Deploy postgresql

Creamos el deployment y el servicio

```
kubectl create -f deployments/postgres.yml
kubectl create -f services/postgres.yml
```

Comprobamos que todo ha sido creado correctamente

```
kubectl get pods
kubectl describe services
```

Podemos conectar a postgresql ya

```
psql -U orientando -h XXXXX -p XXXXX
```

Hacemos lo mismo con redis

```
kubectl create -f deployments/redis.yml
kubectl create -f services/redis.yml
redis-cli -h XXXXX -p XXXXX
```

Todo está accesible, aunque nginx no responde todavía.

Desplegamos orientando, pero para ello primero hay que crear la imagen a partir del dockerfile y los secretos necesarios

```
docker build -t orientando:v4 . (dentro de minikube, en la carpeta del proyecto)
kubectl create secret generic orientando --from-literal=secret-token=XXXXXX
kubectl create -f deployments/orientando.yml
kubectl create -f services/orientando.yml
```

Por último, nginx

```
kubectl create -f deployments/nginx.yml
kubectl create -f services/nginx.yml
```

Oh, parece que falla

```
kubectl describe pods XXXXX
```

Ajá, falta por crear el configmap:

```
kubectl create configmap orientando-nginx --from-file=files/etc/nginx/conf.d/orientando.conf
```

Nginx ya funciona pero no se ven los ficheros css, y esto es porque las reglas de nginx no las he modificado, y al no estar los assets en el mismo host que nginx ya no es capaz de servirlo. Habría que usar un volumen compartido entre los contenedores de la app rails y nginx para poder solventar este problema. De momento, con editar la configuración de nginx para quitar las reglas problemáticas nos basta.

```
kubectl edit configmap orientando-nginx
kubectl delete -f deployments/nginx.yml
kubectl delete -f services/nginx.yml
kubectl create -f deployments/nginx.yml
kubectl create -f services/nginx.yml
```

Cómo puedo aumentar la cantidad de servidores de un tipo? Añadamos una nueva instancia de nginx. Cambiamos el número de instancias en el yaml del deployment y `kubectl apply -f deployments/nginx.yml`.

Más cosas a probar: ver el log de un pod de nginx y matarlo. Comprobar que no se pierde servicio.

O cambiar la imagen de orientando y hacer un rollout.

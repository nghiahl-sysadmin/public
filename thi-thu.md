1. Create deployment name deploy-nginx, image nginx:1.16 va replica=2 with record version. Then upgrade to version nginx:1.17 with record version. After that roll back to nginx:1.16 version. (20d) 
2. Backup etcd, dat ten db backup la ten_hoc_vien.db
3. Given a error deployment. Find and correct errors.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  replicas: 5
  selector:
    matchLabels:
      app: hello-world-5
  template:
    metadata:
      labels:
        app: hello-world-5
    spec:
      containers:
      - name: hello-world
        image: gcr.io/google-samples/hello-ap:1.0
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /index.html
            port: 8081
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            memory: 64M
            cpu: 10m
          limits:
            memory: 64M
            cpu: 10m
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-5
spec:
  selector:
    app: hello-world
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
```
4. Using JsonPath query to restrieve the osImage of all the nodes and store it in a file /opt/output/yourname.txt. The osImage are under the nodeInfo section under status of each node.
5. Create a static pod named static-busybox on the master node that uses the busybox images and the commnad sleep 1000.
6. Create a persistent volume, with the given specification: volume name: pv-storage; storage: 100Mi; AccessMode: ReadWriteMany; HostPath: /pv/pv-storage
7. Create a pod called multi-container with two containers.
  - Container 1 name: alpha, image: nginx
  - Container 2 name: beta, image: busybox, command: sleep 4800
  - Environment Variables:
  - container 1:
    - name: alpha
  - container 2:
    - name: beta 
   
8. Create a pod called non-root-pod, image redis: alpine; runAsUser: 1000; fsGroup: 2000

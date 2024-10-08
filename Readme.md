# 笔试题回复

## 文件内容

所有文件在主目录 `Harvey-housesigma-interview`

1. 第一题脚本内容为 `backup.sh`

2. 第二题配置文件为 `nginx.conf`

3. 第三题排查思路方案记录在 `troubleshooting.md`

4. 第四题代码在 `k8s` 目录下, 其中包含:
   - 持久存储卷 `pv.yaml`
   - 自签发证书 `frontend-tls.yaml`
   - 前端服务 `frontend.yaml`
   - 后端服务 `backend.yaml`
   - 数据库服务 `database.yaml`
   - 数据库认证信息 `secret.yaml`

5. `frontend.yaml` 其中包含前端服务 `deployment`, `service`, `ingress`, `HPA`

6. `backend.yaml` 其中包含中间层服务 `deployment`, `service`, `NetworkPolicy`

7. `database.yaml` 其中包含数据库服务 `statefulset`, `service`, `NetworkPolicy`

## 第四题部署说明

1. 替换 `DB_NAME` 和 `secret.yaml` 为实际数据库信息

2. 根据实际情况使用正确的值修改 `yaml` 文件中 `image` 内容, 使用正确的镜像

3. 确保 `pv.yaml` 中的 `NFS_SERVER` 路径存在, 或修改为其他存储提供方案, 如 `host-path`

4. 使用 `helm` 部署 `nginx ingress controller`, 参考[nginx-ingress](https://kubernetes.github.io/ingress-nginx/deploy/):
   ```
   helm upgrade --install ingress-nginx ingress-nginx \
   --repo https://kubernetes.github.io/ingress-nginx \
   --namespace ingress-nginx --create-namespace
   ```

5. 使用 `helm` 部署 `cert-manager`, 参考[cert-manager](https://cert-manager.io/docs/installation/helm/):
   - `helm repo add jetstack https://charts.jetstack.io --force-update`
   - ```
     helm install cert-manager jetstack/cert-manager \
       --namespace application --create-namespace \
       --version v1.15.3 \
       --set crds.enabled=true
     ```

6. 部署服务:
   - 使用 `kubectl apply -f k8s/pv.yaml` 部署持久存储卷
   - 使用 `kubectl apply -f k8s/secret.yaml` 部署数据库认证信息
   - 使用 `kubectl apply -f k8s/frontend-tls.yaml` 部署自签发证书
   - 使用 `kubectl apply -f k8s/database.yaml` 部署数据库服务
   - 使用 `kubectl apply -f k8s/backend.yaml` 部署中间层服务
   - 使用 `kubectl apply -f k8s/frontend.yaml` 部署前端服务

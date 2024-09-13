# 笔试题回复

## 文件目录结构

所有文件在主目录 `Harvey-housesigma-interview`

1. 第一题脚本内容为 `backup.sh`

2. 第二题配置文件为 `nginx.conf`

3. 第三题排查思路方案记录在 `troubleshooting.md`

4. 第四题代码在 `k8s` 目录下, 其中包含:
   - 前端服务 `frontend.yaml`
   - 后端服务 `backend.yaml`
   - 数据库服务 `database.yaml`

## 第四题部署说明

1. 替换 <your-frontend-image> 和 <your-backend-image> 为实际的镜像地址。

2. 替换 <db-name>, <db-user>, <db-pass> 为实际的数据库信息。

3. 替换 <root-password> 为 MySQL root 用户的密码。

4. 如果使用了自签名证书，请确保创建了相应的 frontend-tls-secret。
   <your-storage-class> 应替换为您 Kubernetes 集群中实际存在的 StorageClass 名称。

5. 部署使用 `kubectl apply -f k8s/*`
## 故障描述

应用程序通过 Haproxy 来读取 Mysql Slave 集群，但是偶尔会产生 SQLSTATE[HY000]: General error: 2006 MySQL server has gone away

## 故障排查

这个错误通常表示客户端尝试与 MySQL 服务器通信时，连接已经断开。鉴于已经检查过网络正常, 数据库正常无压力, 可以从以下几个方面进行排查：

1. HAProxy 配置检查
   - 检查 HAProxy 的配置，确保连接前后端设置正确
   - 检查 timeout 设置合理，不会导致连接被 HAProxy 意外关闭
   - 确保 HAProxy 中的 health check 配置正确，不会错误地标记 Slave 为不可用, 可以通过修改 inter 和 timeout 选项来配置健康检查的频率和超时

2. MySQL 服务器设置
   - 检查 MySQL 服务器的 wait_timeout，确保非交互连接不会超时
   - 检查 MySQL 服务器的 interactive_timeout, 确保交互连接不会超时
   - 检查 MySQL 服务器的 max_connections，确保连接数不会超过最大值
   - 检查 MySQL 服务器的 Max_used_connections, 确保服务器可以响应最大连接数

3. 客户端连接长时间没有活动
   - 检查程序是否使用连接池和线程池, 确认连接池的连接回收机制是否正常工作
   - 检查程序代码使用交互还是非交互连接, 确保超时设置合理
   - 检查程序代码是否使用长连接,多次连接数据库但是使用的是同一个连接,是否有重新启动或保持连接动作
   - 程序在执行完成后有没有正确关闭连接, 新进程是否启动新连接

4. 客户端是否使用太大的数据包。造成这样的原因可能是 sql 操作的时间过长，或者是传送的数据太大
   - 通过修改 max_allowed_packed 的配置参数提高数据包大小
   - 在程序中将数据分批插入(使用mysql limit进行分页，循环分批处理数据)

# 在线聊天室系统

一个基于Java Servlet的在线聊天室系统，包含原始聊天室和私聊版聊天室两种模式。

## 🌐 在线演示

- **原始聊天室**：简单的公共聊天室，所有消息公开可见
- **私聊版聊天室**：支持一对一私聊功能，私聊消息仅双方可见

## ✨ 功能特性

### 原始聊天室
- 🗣️ 简单的公共聊天室
- 👥 实时在线用户列表
- 🔄 自动消息刷新（每3秒）
- 📱 响应式设计，支持移动端
- ⏰ 用户活动监控与自动清理
- 🔢 中文用户编号（用户一、用户二等）

### 私聊版聊天室
- 🔒 私聊功能，一对一私聊
- 🌐 公共聊天和私聊两种模式
- 👁️ 私聊消息仅发送者和接收者可见
- 👤 用户点击选择私聊对象
- 📝 用户加入/离开系统通知
- 🎨 更精美的UI设计
- 📊 实时在线用户计数

## 🏗️ 技术架构

### 后端技术栈
- **Java Servlet 5.0** (Jakarta EE 9)
- **JSP 3.0** - 前端页面渲染
- **ServletContext** - 应用级数据存储
- **会话管理** - 基于HttpSession的用户管理
- **过滤器** - 字符编码和跨域处理
- **监听器** - 会话生命周期管理

### 前端技术栈
- **HTML5/CSS3** - 页面结构和样式
- **JavaScript (ES6)** - 动态交互
- **响应式设计** - 适配各种屏幕尺寸
- **AJAX** - 异步数据加载
- **Fetch API** - 现代HTTP请求

### 线程安全与并发
- **ConcurrentHashMap** - 线程安全的用户管理
- **CopyOnWriteArrayList** - 线程安全的消息列表
- **AtomicInteger** - 原子用户ID生成
- **同步块** - 关键代码段的线程安全

## 📁 项目结构

```
chatroom-system/
├── src/main/java/com/example/demo4/
│   ├── HelloServlet.java                 # 原始聊天室Servlet
│   ├── PrivateChatServlet.java           # 私聊版聊天室Servlet
│   ├── CharacterEncodingFilter.java      # 字符编码过滤器
│   ├── OriginalChatSessionListener.java  # 原始聊天室会话监听器
│   └── ChatSessionListener.java          # 私聊版会话监听器
├── src/main/webapp/
│   ├── index.jsp                         # 首页（聊天室选择）
│   ├── original-chat.jsp                 # 原始聊天室前端
│   ├── private-chat.jsp                  # 私聊版聊天室前端
│   └── chat.css                          # 通用样式文件
└── README.md
```

## 🚀 快速开始

### 环境要求
- **JDK 8+** (推荐JDK 11或17)
- **Apache Tomcat 10+** (支持Servlet 5.0)
- **Maven 3.6+** (用于构建)

### 部署步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/yourusername/chatroom-system.git
   cd chatroom-system
   ```

2. **构建项目**
   ```bash
   mvn clean package
   ```
   或直接使用IDE（如IntelliJ IDEA、Eclipse）导入Maven项目

3. **部署到Tomcat**
   - 将生成的WAR文件复制到Tomcat的`webapps`目录
   - 启动Tomcat服务器
   - 访问：`http://localhost:8080/chatroom/`

4. **直接运行（开发模式）**
   ```bash
   # 在项目根目录运行
   mvn tomcat7:run
   # 或使用嵌入式Tomcat
   mvn spring-boot:run
   ```

## 📖 使用指南

### 1. 访问首页
访问应用根路径，选择要进入的聊天室：
- **原始聊天室**：简单的公共聊天，适合群聊
- **私聊版聊天室**：支持私聊功能，适合一对一交流

### 2. 原始聊天室使用
1. 进入原始聊天室后自动分配用户编号
2. 在输入框中输入消息并发送
3. 右侧显示当前在线用户列表
4. 系统每3秒自动刷新消息

### 3. 私聊版聊天室使用
1. 进入私聊版聊天室后自动分配用户编号
2. 左侧选择要私聊的用户（点击用户头像）
3. 勾选"私聊模式"切换到私聊
4. 输入消息发送（私聊消息仅双方可见）
5. 系统显示用户加入/离开通知

## 🔧 技术细节

### 消息存储机制
- **原始聊天室**：使用`ServletContext`存储`List<ChatMessage>`
- **私聊版聊天室**：使用`ServletContext`存储`List<ChatMessage>`和`ConcurrentHashMap<String, User>`
- **消息限制**：最多存储100条消息，防止内存溢出

### 用户管理
- **用户标识**：基于Session ID
- **中文编号**：自动转换为中文数字（用户一、用户二等）
- **活动跟踪**：记录最后活动时间，30秒无活动自动清理
- **在线状态**：实时监控用户在线状态

### 私聊消息隔离
- **消息过滤**：私聊消息只在`toHtml()`方法中显示给相关用户
- **目标标记**：每条消息记录发送者和目标接收者
- **显示控制**：前端根据当前用户ID过滤显示内容

### 会话管理
- **会话超时**：30分钟无活动自动销毁会话
- **资源清理**：会话销毁时自动清理用户数据
- **离开通知**：用户离开时发送系统消息

## 🧪 测试与调试

### 多用户测试
1. 打开多个浏览器窗口或隐身窗口
2. 每个窗口视为一个独立用户
3. 观察消息同步和用户列表更新

### 调试信息
系统在服务器控制台输出详细日志：
- 用户加入/离开
- 消息发送记录
- 系统状态监控
- 会话生命周期事件

查看日志：
```bash
# Linux/Mac
tail -f /path/to/tomcat/logs/catalina.out

# Windows
type "C:\tomcat\logs\catalina.out"
```

## ⚙️ 配置选项

### 超时设置
在代码中可调整的参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `SESSION_TIMEOUT` | 30秒 | 用户不活跃超时时间 |
| `MAX_MESSAGES` | 100条 | 最大消息存储数量 |
| `自动刷新间隔` | 3秒 | 消息自动刷新间隔 |
| `用户列表刷新` | 10秒 | 在线用户列表刷新间隔 |

### 修改配置
编辑对应的Java文件中的常量：
```java
// 在HelloServlet.java或PrivateChatServlet.java中
private static final long SESSION_TIMEOUT = 30 * 1000; // 修改超时时间
private static final int MAX_MESSAGES = 100; // 修改最大消息数
```

## 🐛 故障排除

### 常见问题

1. **中文乱码**
   - 确保服务器使用UTF-8编码
   - 检查CharacterEncodingFilter是否生效

2. **用户列表不更新**
   - 检查JavaScript控制台是否有错误
   - 确认AJAX请求是否成功
   - 查看服务器日志是否有异常

3. **私聊消息对方收不到**
   - 确认目标用户ID正确
   - 检查私聊模式是否开启
   - 查看服务器日志中的消息发送记录

4. **会话频繁断开**
   - 增加会话超时时间
   - 检查浏览器Cookie设置
   - 确保网络连接稳定

### 调试技巧
1. 开启浏览器开发者工具（F12）
2. 查看网络请求和响应
3. 监控JavaScript控制台输出
4. 查看服务器控制台日志

## 📈 性能优化

### 内存优化
- 限制消息存储数量
- 定期清理不活跃用户
- 使用合适的数据结构（ConcurrentHashMap）

### 网络优化
- 消息自动刷新间隔合理设置
- 使用轻量级数据格式
- 减少不必要的数据传输

### 并发优化
- 使用线程安全集合类
- 关键操作使用同步控制
- 避免长时间的阻塞操作


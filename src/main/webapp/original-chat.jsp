<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>原始聊天室</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Arial', 'Microsoft YaHei', sans-serif;
            background-color: #f5f5f5;
            line-height: 1.6;
            color: #333;
            padding: 20px;
        }

        .original-chat-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            gap: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .original-chat-main {
            flex: 3;
            display: flex;
            flex-direction: column;
        }

        .original-chat-sidebar {
            flex: 1;
            min-width: 250px;
            background-color: #f8f9fa;
        }

        .original-chat-header {
            background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }

        .original-chat-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .original-chat-header div {
            font-size: 14px;
            opacity: 0.9;
        }

        .original-chat-status-bar {
            background-color: #f8f9fa;
            padding: 10px 20px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
        }

        .original-chat-status-indicator {
            display: flex;
            align-items: center;
        }

        .original-chat-status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 8px;
        }

        .original-chat-status-dot.connected {
            background-color: #4CAF50;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }

        .original-chat-status-dot.disconnected {
            background-color: #f44336;
        }

        .original-chat-user-count {
            background-color: #e3f2fd;
            color: #1976d2;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 500;
            font-size: 14px;
        }

        .original-chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background-color: #fafafa;
            min-height: 400px;
            max-height: 500px;
        }

        .original-chat-message {
            margin-bottom: 15px;
            padding: 12px 15px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border-left: 4px solid #4CAF50;
        }

        .original-chat-message.system {
            border-left-color: #2196F3;
            background-color: #e3f2fd;
        }

        .original-chat-message .sender {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
        }

        .original-chat-message .sender::before {
            content: '';
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: #4CAF50;
            margin-right: 8px;
        }

        .original-chat-message.system .sender::before {
            background-color: #2196F3;
        }

        .original-chat-message .time {
            font-size: 11px;
            color: #888;
            margin-left: 5px;
        }

        .original-chat-message .content {
            color: #333;
            line-height: 1.5;
        }

        .original-chat-input-area {
            padding: 20px;
            background-color: #f8f9fa;
            border-top: 1px solid #e9ecef;
        }

        .original-chat-message-form {
            display: flex;
            gap: 10px;
        }

        #original-chat-input {
            flex: 1;
            padding: 12px 15px;
            border: 2px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        #original-chat-input:focus {
            outline: none;
            border-color: #4CAF50;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }

        #original-chat-submit {
            padding: 12px 25px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            font-size: 14px;
            transition: background-color 0.2s;
        }

        #original-chat-submit:hover {
            background-color: #45a049;
        }

        .original-chat-sidebar-header {
            padding: 15px 20px;
            background-color: #4CAF50;
            color: white;
            text-align: center;
        }

        .original-chat-sidebar-header h3 {
            margin: 0;
            font-size: 16px;
        }

        .original-chat-user-list {
            padding: 15px;
            max-height: 400px;
            overflow-y: auto;
        }

        .original-chat-user-item {
            display: flex;
            align-items: center;
            padding: 10px 12px;
            margin-bottom: 8px;
            background-color: white;
            border-radius: 6px;
            border: 1px solid #e9ecef;
            transition: all 0.2s;
        }

        .original-chat-user-item:hover {
            background-color: #f8f9fa;
            transform: translateX(3px);
        }

        .original-chat-user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: #2196F3;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 10px;
        }

        .original-chat-user-info {
            flex: 1;
        }

        .original-chat-user-name {
            font-weight: 500;
            color: #333;
        }

        .original-chat-user-status {
            font-size: 11px;
            color: #666;
        }

        .original-chat-user-status.online {
            color: #4CAF50;
        }

        .original-chat-user-status.online::before {
            content: '●';
            margin-right: 4px;
            font-size: 8px;
            vertical-align: middle;
        }

        .original-chat-empty-state {
            text-align: center;
            padding: 30px 20px;
            color: #666;
        }

        .original-chat-empty-state h4 {
            margin-bottom: 10px;
            color: #333;
        }

        .original-chat-error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 10px 15px;
            border-radius: 6px;
            margin: 10px;
            border-left: 4px solid #f44336;
        }

        .original-chat-loading {
            text-align: center;
            padding: 20px;
            color: #666;
        }

        .original-chat-debug-info {
            background-color: #f8f9fa;
            padding: 10px 20px;
            border-top: 1px solid #e9ecef;
            font-size: 12px;
            color: #666;
            display: flex;
            justify-content: space-between;
        }

        @media (max-width: 768px) {
            .original-chat-container {
                flex-direction: column;
            }

            .original-chat-sidebar {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<div class="original-chat-container">
    <div class="original-chat-main">
        <div class="original-chat-header">
            <h1>原始聊天室</h1>
            <div>简单、快速的公共聊天室</div>
        </div>

        <div class="original-chat-status-bar">
            <div class="original-chat-status-indicator">
                <div class="original-chat-status-dot" id="original-status-dot"></div>
                <span id="original-connection-status">正在连接...</span>
            </div>
            <div>
                消息刷新: <span id="original-refresh-status">开启</span>
            </div>
        </div>

        <div class="original-chat-messages" id="original-chat-body">
            <div class="original-chat-loading" id="original-messages-loading">正在加载消息...</div>
        </div>

        <div class="original-chat-input-area">
            <form id="original-chat-form" class="original-chat-message-form">
                <input type="text" id="original-chat-input" name="message" placeholder="请输入消息..." required autocomplete="off">
                <button type="submit" id="original-chat-submit">发送</button>
            </form>
        </div>

        <div class="original-chat-debug-info">
            <div>服务器状态: <span id="original-server-status">正常</span></div>
            <div>消息数: <span id="original-message-count">0</span></div>
        </div>
    </div>

    <div class="original-chat-sidebar">
        <div class="original-chat-sidebar-header">
            <h3>在线用户 <span id="original-online-count">(0)</span></h3>
        </div>

        <div class="original-chat-user-list" id="original-user-list">
            <div class="original-chat-loading" id="original-users-loading">正在加载用户列表...</div>
        </div>
    </div>
</div>

<script>
    class OriginalChat {
        constructor() {
            this.sessionId = null;
            this.userId = null;
            this.userName = null;
            this.autoRefreshInterval = null;
            this.userRefreshInterval = null;
            this.messageCount = 0;

            this.init();
        }

        init() {
            console.log('原始聊天室初始化...');
            this.generateSessionId();
            this.bindEvents();
            this.updateStatus('正在连接到服务器...', 'connecting');

            // 初始加载
            setTimeout(() => {
                this.loadMessages();
                this.loadUsers();
                this.startAutoRefresh();
                this.updateStatus('已连接', 'connected');
            }, 100);
        }

        generateSessionId() {
            try {
                // 使用更简单的方式生成会话ID
                this.sessionId = 'original_' + Date.now();
                console.log('生成会话ID:', this.sessionId);
            } catch (error) {
                console.error('生成会话ID失败:', error);
                this.sessionId = 'fallback_' + Date.now();
            }
        }

        bindEvents() {
            // 发送消息
            const chatForm = document.getElementById('original-chat-form');
            if (chatForm) {
                chatForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.sendMessage();
                });
            }

            // 输入框快捷键
            const chatInput = document.getElementById('original-chat-input');
            if (chatInput) {
                chatInput.addEventListener('keypress', (e) => {
                    if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        this.sendMessage();
                    }
                });
            }

            // 页面可见性变化
            document.addEventListener('visibilitychange', () => {
                if (document.hidden) {
                    this.stopAutoRefresh();
                    const refreshStatus = document.getElementById('original-refresh-status');
                    if (refreshStatus) refreshStatus.textContent = '暂停';
                } else {
                    this.startAutoRefresh();
                    this.loadMessages();
                    this.loadUsers();
                    const refreshStatus = document.getElementById('original-refresh-status');
                    if (refreshStatus) refreshStatus.textContent = '开启';
                }
            });

            // 页面卸载前清理
            window.addEventListener('beforeunload', () => {
                this.stopAutoRefresh();
            });
        }

        async loadMessages() {
            try {
                const response = await fetch('hello-servlet?t=' + Date.now());

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} ${response.statusText}`);
                }

                const html = await response.text();
                const chatBody = document.getElementById('original-chat-body');
                const messagesLoading = document.getElementById('original-messages-loading');

                if (chatBody) {
                    chatBody.innerHTML = html;

                    // 滚动到底部
                    setTimeout(() => {
                        chatBody.scrollTop = chatBody.scrollHeight;
                    }, 100);

                    // 更新消息计数
                    this.messageCount = (chatBody.querySelectorAll('.original-chat-message').length || 0);
                    const messageCountElement = document.getElementById('original-message-count');
                    if (messageCountElement) {
                        messageCountElement.textContent = this.messageCount;
                    }
                }

                if (messagesLoading) {
                    messagesLoading.style.display = 'none';
                }

            } catch (error) {
                console.error('加载消息失败:', error);
                this.showError('消息加载失败，正在重试...');

                // 重试机制
                setTimeout(() => this.loadMessages(), 3000);
            }
        }

        async loadUsers() {
            try {
                const response = await fetch('hello-servlet?action=getUsers&t=' + Date.now());

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} ${response.statusText}`);
                }

                const users = await response.json();
                this.renderUserList(users);

                // 更新在线人数显示
                const onlineCountElement = document.getElementById('original-online-count');
                if (onlineCountElement) {
                    onlineCountElement.textContent = '(' + users.length + ')';
                }

            } catch (error) {
                console.error('加载用户列表失败:', error);
                this.renderUserList([]);

                const userList = document.getElementById('original-user-list');
                if (userList) {
                    userList.innerHTML = '<div class="original-chat-error-message">用户列表加载失败: ' + error.message + '</div><div class="original-chat-empty-state"><h4>无法加载用户列表</h4><p>请稍后刷新页面重试</p></div>';
                }
            }
        }

        renderUserList(users) {
            const userList = document.getElementById('original-user-list');
            const usersLoading = document.getElementById('original-users-loading');

            if (!userList) return;

            if (usersLoading) {
                usersLoading.style.display = 'none';
            }

            if (users.length === 0) {
                userList.innerHTML = '<div class="original-chat-empty-state"><h4>暂无其他用户</h4><p>等待其他用户加入...</p></div>';
                return;
            }

            let html = '';
            users.forEach(user => {
                let displayName = '用户';
                if (user.chineseNum) {
                    displayName += user.chineseNum;
                } else if (user.name) {
                    displayName = user.name;
                }

                // 获取用户首字母作为头像
                const initial = this.getInitial(displayName);

                // 使用字符串拼接，避免模板字符串
                html += '<div class="original-chat-user-item">';
                html += '<div class="original-chat-user-avatar">' + initial + '</div>';
                html += '<div class="original-chat-user-info">';
                html += '<div class="original-chat-user-name">' + displayName + '</div>';
                html += '<div class="original-chat-user-status online">在线</div>';
                html += '</div></div>';
            });

            userList.innerHTML = html;
        }

        async sendMessage() {
            const chatInput = document.getElementById('original-chat-input');
            const message = chatInput ? chatInput.value.trim() : '';

            if (!message) {
                this.showError('请输入消息内容');
                return;
            }

            const params = new URLSearchParams();
            params.append('message', message);

            try {
                const response = await fetch('hello-servlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: params.toString()
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} ${response.statusText}`);
                }

                // 清空输入框
                if (chatInput) {
                    chatInput.value = '';
                    chatInput.focus();
                }

                // 重新加载消息和用户列表
                this.loadMessages();
                this.loadUsers();

                this.showSuccess('消息发送成功');

            } catch (error) {
                console.error('发送消息失败:', error);
                this.showError('发送失败: ' + error.message);
            }
        }

        updateStatus(message, status) {
            const statusElement = document.getElementById('original-connection-status');
            const statusDot = document.getElementById('original-status-dot');

            if (statusElement) {
                statusElement.textContent = message;
            }

            if (statusDot) {
                statusDot.className = 'original-chat-status-dot';
                if (status === 'connected') {
                    statusDot.classList.add('connected');
                } else {
                    statusDot.classList.add('disconnected');
                }
            }
        }

        startAutoRefresh() {
            // 清理现有定时器
            this.stopAutoRefresh();

            // 消息每3秒刷新一次
            this.autoRefreshInterval = setInterval(() => {
                this.loadMessages();
            }, 3000);

            // 用户列表每8秒刷新一次
            this.userRefreshInterval = setInterval(() => {
                this.loadUsers();
            }, 8000);

            console.log('自动刷新已启动');

            const refreshStatus = document.getElementById('original-refresh-status');
            if (refreshStatus) refreshStatus.textContent = '开启';
        }

        stopAutoRefresh() {
            if (this.autoRefreshInterval) {
                clearInterval(this.autoRefreshInterval);
                this.autoRefreshInterval = null;
            }

            if (this.userRefreshInterval) {
                clearInterval(this.userRefreshInterval);
                this.userRefreshInterval = null;
            }

            console.log('自动刷新已停止');

            const refreshStatus = document.getElementById('original-refresh-status');
            if (refreshStatus) refreshStatus.textContent = '暂停';
        }

        showError(message) {
            this.showMessage(message, 'error');
        }

        showSuccess(message) {
            this.showMessage(message, 'success');
        }

        showMessage(message, type) {
            const chatBody = document.getElementById('original-chat-body');
            if (!chatBody) return;

            const messageDiv = document.createElement('div');
            messageDiv.className = type === 'error' ? 'original-chat-error-message' : 'original-chat-message system';
            messageDiv.textContent = message;
            messageDiv.style.margin = '10px';

            // 添加到消息容器顶部
            chatBody.insertBefore(messageDiv, chatBody.firstChild);

            // 3秒后移除
            setTimeout(() => {
                if (messageDiv.parentNode === chatBody) {
                    chatBody.removeChild(messageDiv);
                }
            }, 3000);
        }

        getInitial(name) {
            if (!name || name.length === 0) return '?';

            // 提取中文或英文首字母
            const chineseMatch = name.match(/用户(.)/);
            if (chineseMatch && chineseMatch[1]) {
                return chineseMatch[1];
            }

            return name.charAt(0);
        }
    }

    // 页面加载完成后初始化
    document.addEventListener('DOMContentLoaded', () => {
        new OriginalChat();
    });
</script>
</body>
</html>
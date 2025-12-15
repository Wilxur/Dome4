<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>在线聊天室 - 私聊版</title>
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

        .private-chat-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .private-chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }

        .private-chat-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .private-chat-header .subtitle {
            font-size: 14px;
            opacity: 0.9;
        }

        .private-chat-main-content {
            display: flex;
            min-height: 500px;
        }

        .private-chat-sidebar {
            width: 250px;
            background-color: #f8f9fa;
            border-right: 1px solid #e9ecef;
            padding: 20px;
        }

        .private-chat-chat-area {
            flex: 1;
            padding: 20px;
            display: flex;
            flex-direction: column;
        }

        .private-chat-user-list {
            flex: 1;
            overflow-y: auto;
        }

        .private-chat-user-list h3 {
            color: #495057;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #e9ecef;
        }

        .private-chat-user-item {
            display: flex;
            align-items: center;
            padding: 10px 15px;
            margin-bottom: 8px;
            background-color: white;
            border: 1px solid #e9ecef;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .private-chat-user-item:hover {
            background-color: #f8f9fa;
            border-color: #dee2e6;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .private-chat-user-item.selected {
            background-color: #e3f2fd;
            border-color: #2196F3;
            color: #1976d2;
        }

        .private-chat-user-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: #4CAF50;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 10px;
        }

        .private-chat-user-name {
            font-weight: 500;
        }

        .private-chat-messages-container {
            flex: 1;
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
            overflow-y: auto;
            border: 1px solid #e9ecef;
        }

        .private-chat-message {
            margin-bottom: 12px;
            padding: 10px 15px;
            border-radius: 8px;
            background-color: white;
            border-left: 4px solid transparent;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }

        .private-chat-message.public {
            border-left-color: #4CAF50;
        }

        .private-chat-message.private {
            border-left-color: #9c27b0;
            background-color: #f3e5f5;
        }

        .private-chat-message.system {
            border-left-color: #2196F3;
            background-color: #e3f2fd;
            text-align: center;
            font-size: 12px;
            color: #1565c0;
        }

        .private-chat-message-header {
            display: flex;
            align-items: center;
            margin-bottom: 5px;
        }

        .private-chat-message-sender {
            font-weight: bold;
            color: #333;
            margin-right: 8px;
        }

        .private-chat-message-target {
            color: #9c27b0;
            font-size: 12px;
            background-color: #f3e5f5;
            padding: 2px 6px;
            border-radius: 4px;
            margin-left: 5px;
        }

        .private-chat-message-time {
            font-size: 11px;
            color: #666;
            margin-left: auto;
        }

        .private-chat-message-content {
            color: #333;
            line-height: 1.4;
        }

        .private-chat-input-area {
            background-color: white;
            padding: 20px;
            border-top: 1px solid #e9ecef;
        }

        .private-chat-mode-selector {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 6px;
        }

        .private-chat-mode-selector label {
            display: flex;
            align-items: center;
            cursor: pointer;
            margin-right: 20px;
            font-weight: 500;
        }

        .private-chat-mode-selector input[type="checkbox"] {
            margin-right: 8px;
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        #private-target-display {
            color: #9c27b0;
            font-weight: 500;
            background-color: #f3e5f5;
            padding: 4px 10px;
            border-radius: 4px;
        }

        .private-chat-message-form {
            display: flex;
            gap: 10px;
        }

        #private-message-input {
            flex: 1;
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        #private-message-input:focus {
            outline: none;
            border-color: #4CAF50;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }

        #private-send-button {
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

        #private-send-button:hover {
            background-color: #45a049;
        }

        .private-chat-status-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e9ecef;
            font-size: 12px;
            color: #666;
        }

        .private-chat-status-indicator {
            display: flex;
            align-items: center;
        }

        .private-chat-status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 6px;
        }

        .private-chat-status-dot.connected {
            background-color: #4CAF50;
        }

        .private-chat-status-dot.disconnected {
            background-color: #f44336;
        }

        .private-chat-user-count-badge {
            background-color: #e3f2fd;
            color: #1976d2;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
        }

        .private-chat-session-info {
            background-color: #fff3e0;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 11px;
            color: #ef6c00;
            margin-top: 10px;
            word-break: break-all;
        }

        .private-chat-loading {
            text-align: center;
            color: #666;
            padding: 20px;
        }

        .private-chat-empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }

        .private-chat-empty-state h4 {
            margin-bottom: 10px;
            color: #333;
        }

        .private-chat-error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            border-left: 4px solid #f44336;
        }

        .private-chat-success-message {
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 10px 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            border-left: 4px solid #4CAF50;
        }

        @media (max-width: 768px) {
            .private-chat-main-content {
                flex-direction: column;
            }

            .private-chat-sidebar {
                width: 100%;
                border-right: none;
                border-bottom: 1px solid #e9ecef;
            }

            .private-chat-messages-container {
                height: 300px;
            }
        }
    </style>
</head>
<body>
<div class="private-chat-container">
    <div class="private-chat-header">
        <h1>私聊版聊天室</h1>
        <div class="subtitle">支持一对一私聊和公开聊天</div>
    </div>

    <div class="private-chat-main-content">
        <div class="private-chat-sidebar">
            <div class="private-chat-user-list">
                <h3>在线用户 <span id="private-user-count" class="private-chat-user-count-badge">(0)</span></h3>
                <div id="private-user-list-content">
                    <div class="private-chat-loading">加载用户中...</div>
                </div>
            </div>

            <div class="private-chat-session-info">
                <div>会话ID: <span id="private-session-id-display"></span></div>
            </div>
        </div>

        <div class="private-chat-chat-area">
            <div class="private-chat-messages-container" id="private-messages-container">
                <div class="private-chat-loading" id="private-messages-loading">加载消息中...</div>
            </div>

            <div class="private-chat-input-area">
                <div class="private-chat-mode-selector">
                    <label>
                        <input type="checkbox" id="private-mode">
                        私聊模式
                    </label>
                    <span id="private-target-display">请选择聊天对象</span>
                </div>

                <form id="private-message-form" class="private-chat-message-form">
                    <input type="text" id="private-message-input" placeholder="输入消息..." autocomplete="off">
                    <button type="submit" id="private-send-button">发送</button>
                </form>

                <div class="private-chat-status-bar">
                    <div class="private-chat-status-indicator">
                        <div class="private-chat-status-dot" id="private-status-dot"></div>
                        <span id="private-connection-status">未连接</span>
                    </div>
                    <div>
                        在线人数: <span id="private-online-count">0</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    class PrivateChat {
        constructor() {
            this.selectedUserId = null;
            this.sessionId = null;
            this.autoRefreshInterval = null;
            this.userRefreshInterval = null;
            this.userName = null;
            this.userId = null;
            this.messageCount = 0;

            this.init();
        }

        init() {
            console.log('私聊聊天室初始化...');
            this.generateSessionId();
            this.bindEvents();
            this.updateStatus('正在连接到服务器...', 'connecting');

            // 初始加载
            setTimeout(() => {
                this.loadUsers();
                this.loadMessages();
                this.startAutoRefresh();
                this.updateStatus('已连接', 'connected');
            }, 100);
        }

        generateSessionId() {
            try {
                // 尝试从URL参数获取sessionId
                const urlParams = new URLSearchParams(window.location.search);
                const urlSessionId = urlParams.get('sessionId');

                if (urlSessionId) {
                    this.sessionId = urlSessionId;
                    console.log('从URL参数获取会话ID:', this.sessionId);
                } else {
                    // 尝试从localStorage获取
                    let storedId = localStorage.getItem('privateChatSessionId');
                    if (storedId) {
                        this.sessionId = storedId;
                        console.log('从本地存储恢复会话ID:', this.sessionId);
                    } else {
                        // 生成新的会话ID
                        this.sessionId = 'private_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
                        localStorage.setItem('privateChatSessionId', this.sessionId);
                        console.log('生成新的会话ID:', this.sessionId);
                    }
                }

                // 显示会话ID
                const sessionDisplay = document.getElementById('private-session-id-display');
                if (sessionDisplay) {
                    sessionDisplay.textContent = this.sessionId.substring(0, 15) + '...';
                }
            } catch (error) {
                console.error('生成会话ID失败:', error);
                this.sessionId = 'fallback_' + Date.now();
            }
        }

        bindEvents() {
            // 发送消息
            const messageForm = document.getElementById('private-message-form');
            if (messageForm) {
                messageForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.sendMessage();
                });
            }

            // 私聊模式切换
            const privateMode = document.getElementById('private-mode');
            if (privateMode) {
                privateMode.addEventListener('change', (e) => {
                    if (!e.target.checked) {
                        this.resetPrivateMode();
                    }
                });
            }

            // 输入框回车发送
            const messageInput = document.getElementById('private-message-input');
            if (messageInput) {
                messageInput.addEventListener('keypress', (e) => {
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
                } else {
                    this.startAutoRefresh();
                    this.loadMessages();
                    this.loadUsers();
                }
            });

            // 页面卸载前清理
            window.addEventListener('beforeunload', () => {
                this.stopAutoRefresh();
            });
        }

        async loadMessages() {
            if (!this.sessionId) {
                console.warn('无法加载消息: sessionId为空');
                return;
            }

            try {
                // 注意：这里不能使用EL表达式，要直接使用JavaScript
                const url = 'private-chat-servlet?action=getMessages&sessionId=' +
                    encodeURIComponent(this.sessionId) + '&t=' + Date.now();

                console.log('正在加载消息:', url);

                const response = await fetch(url);

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} ${response.statusText}`);
                }

                const html = await response.text();
                const messagesContainer = document.getElementById('private-messages-container');
                const messagesLoading = document.getElementById('private-messages-loading');

                if (messagesContainer) {
                    messagesContainer.innerHTML = html;

                    // 滚动到底部
                    setTimeout(() => {
                        messagesContainer.scrollTop = messagesContainer.scrollHeight;
                    }, 100);
                }

                if (messagesLoading) {
                    messagesLoading.style.display = 'none';
                }

                this.messageCount++;

                // 每10条消息重新加载一次用户列表
                if (this.messageCount % 10 === 0) {
                    this.loadUsers();
                }

            } catch (error) {
                console.error('加载消息失败:', error);
                this.showError('消息加载失败，正在重试...');

                // 重试机制
                setTimeout(() => this.loadMessages(), 2000);
            }
        }

        async loadUsers() {
            if (!this.sessionId) {
                console.warn('无法加载用户列表: sessionId为空');
                return;
            }

            try {
                const url = 'private-chat-servlet?action=getUsers&sessionId=' +
                    encodeURIComponent(this.sessionId) + '&t=' + Date.now();

                console.log('正在加载用户列表:', url);

                const response = await fetch(url);

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} ${response.statusText}`);
                }

                const users = await response.json();
                this.renderUserList(users);

                // 更新在线人数显示
                const userCount = document.getElementById('private-user-count');
                const onlineCount = document.getElementById('private-online-count');

                if (userCount) {
                    userCount.textContent = '(' + users.length + ')';
                }

                if (onlineCount) {
                    onlineCount.textContent = users.length;
                }

            } catch (error) {
                console.error('加载用户列表失败:', error);
                this.renderUserList([]);
            }
        }

        renderUserList(users) {
            const userListContent = document.getElementById('private-user-list-content');
            if (!userListContent) return;

            if (users.length === 0) {
                userListContent.innerHTML = '<div class="private-chat-empty-state"><h4>暂无其他用户</h4><p>等待其他用户加入...</p></div>';
                return;
            }

            // 过滤掉自己（如果有自己的ID）
            const filteredUsers = users.filter(user => !this.userId || user.id !== this.userId);

            let html = '';
            filteredUsers.forEach(user => {
                const isSelected = (this.selectedUserId === user.id) ? 'selected' : '';

                // 处理用户显示名称
                let displayName = '用户';
                if (user.chineseNum) {
                    displayName += user.chineseNum;
                } else if (user.name) {
                    displayName = user.name;
                } else if (user.id) {
                    displayName += this.numberToChinese(user.id);
                }

                // 获取用户首字母
                const initial = user.chineseNum || this.getInitial(displayName);


                html += '<div class="private-chat-user-item ' + isSelected + '" onclick="privateChat.selectUser(' + user.id + ', \'' + displayName.replace(/'/g, "\\'") + '\')">';
                html += '<div class="private-chat-user-avatar">' + initial + '</div>';
                html += '<div class="private-chat-user-name">' + displayName + '</div>';
                html += '</div>';
            });

            userListContent.innerHTML = html;
        }

        selectUser(userId, userName) {
            console.log('选择用户:', userId, userName);

            this.selectedUserId = userId;

            // 更新UI
            const privateMode = document.getElementById('private-mode');
            const targetDisplay = document.getElementById('private-target-display');

            if (privateMode) {
                privateMode.checked = true;
            }

            if (targetDisplay) {
                targetDisplay.textContent = '正在与 ' + userName + ' 私聊';
                targetDisplay.style.color = '#9c27b0';
            }

            // 更新用户列表选中状态
            const userItems = document.querySelectorAll('.private-chat-user-item');
            userItems.forEach(item => {
                item.classList.remove('selected');
            });

            // 找到对应的用户项
            const selectedItem = Array.from(userItems).find(item => {
                return item.getAttribute('onclick') && item.getAttribute('onclick').includes('privateChat.selectUser(' + userId);
            });

            if (selectedItem) {
                selectedItem.classList.add('selected');
            }

            // 焦点回到输入框
            const messageInput = document.getElementById('private-message-input');
            if (messageInput) {
                messageInput.focus();
                messageInput.placeholder = '私聊消息给 ' + userName + '...';
            }
        }

        resetPrivateMode() {
            this.selectedUserId = null;

            const targetDisplay = document.getElementById('private-target-display');
            const privateMode = document.getElementById('private-mode');
            const messageInput = document.getElementById('private-message-input');

            if (targetDisplay) {
                targetDisplay.textContent = '请选择聊天对象';
                targetDisplay.style.color = '#666';
            }

            if (privateMode) {
                privateMode.checked = false;
            }

            if (messageInput) {
                messageInput.placeholder = '输入消息...';
            }

            // 移除所有选中状态
            const userItems = document.querySelectorAll('.private-chat-user-item');
            userItems.forEach(item => {
                item.classList.remove('selected');
            });
        }

        async sendMessage() {
            const messageInput = document.getElementById('private-message-input');
            const message = messageInput ? messageInput.value.trim() : '';
            const isPrivate = document.getElementById('private-mode') ?
                document.getElementById('private-mode').checked : false;

            if (!message) {
                this.showError('请输入消息内容');
                return;
            }

            if (isPrivate && !this.selectedUserId) {
                this.showError('请先选择私聊对象');
                return;
            }

            const params = new URLSearchParams();
            params.append('action', 'sendMessage');
            params.append('message', message);
            params.append('sessionId', this.sessionId);

            if (isPrivate && this.selectedUserId) {
                params.append('targetUserId', this.selectedUserId);
            }

            try {
                const response = await fetch('private-chat-servlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: params.toString()
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} ${response.statusText}`);
                }

                const result = await response.text();
                console.log('发送结果:', result);

                // 清空输入框
                if (messageInput) {
                    messageInput.value = '';
                    messageInput.focus();
                }

                // 重新加载消息
                this.loadMessages();

                // 如果是新用户，解析返回的信息
                if (result.startsWith('NEW_USER:')) {
                    const parts = result.split(':');
                    if (parts.length >= 3) {
                        this.userId = parseInt(parts[1]);
                        const chineseNum = parts[2];
                        this.userName = '用户' + chineseNum;
                        console.log('新用户创建:', this.userName);

                        // 显示欢迎消息
                        this.showSuccess('欢迎 ' + this.userName + ' 加入聊天室');
                    }
                } else {
                    this.showSuccess('消息发送成功');
                }

            } catch (error) {
                console.error('发送消息失败:', error);
                this.showError('发送失败: ' + error.message);
            }
        }

        updateStatus(message, status) {
            const statusElement = document.getElementById('private-connection-status');
            const statusDot = document.getElementById('private-status-dot');

            if (statusElement) {
                statusElement.textContent = message;

                if (status === 'connected') {
                    statusElement.style.color = '#4CAF50';
                } else if (status === 'connecting') {
                    statusElement.style.color = '#FF9800';
                } else {
                    statusElement.style.color = '#f44336';
                }
            }

            if (statusDot) {
                statusDot.className = 'private-chat-status-dot ' + status;
            }
        }

        startAutoRefresh() {
            // 清理现有定时器
            this.stopAutoRefresh();

            // 消息每3秒刷新一次
            this.autoRefreshInterval = setInterval(() => {
                this.loadMessages();
            }, 3000);

            // 用户列表每10秒刷新一次
            this.userRefreshInterval = setInterval(() => {
                this.loadUsers();
            }, 10000);

            console.log('自动刷新已启动');
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
        }

        showError(message) {
            this.showMessage(message, 'error');
        }

        showSuccess(message) {
            this.showMessage(message, 'success');
        }

        showMessage(message, type) {
            const messagesContainer = document.getElementById('private-messages-container');
            if (!messagesContainer) return;

            const messageDiv = document.createElement('div');
            messageDiv.className = type === 'error' ? 'private-chat-error-message' : 'private-chat-success-message';
            messageDiv.textContent = message;
            messageDiv.style.marginTop = '10px';

            // 添加到消息容器顶部
            messagesContainer.insertBefore(messageDiv, messagesContainer.firstChild);

            // 3秒后移除
            setTimeout(() => {
                if (messageDiv.parentNode === messagesContainer) {
                    messagesContainer.removeChild(messageDiv);
                }
            }, 3000);
        }

        numberToChinese(num) {
            const chineseNumbers = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
            if (num >= 1 && num <= 10) {
                return chineseNumbers[num - 1];
            }
            return num.toString();
        }

        getInitial(name) {
            if (!name || name.length === 0) return '?';
            return name.charAt(0);
        }
    }

    // 全局实例
    let privateChat;

    // 页面加载完成后初始化
    document.addEventListener('DOMContentLoaded', () => {
        privateChat = new PrivateChat();

        // 导出到全局，供HTML点击事件使用
        window.privateChat = privateChat;
    });
</script>
</body>
</html>
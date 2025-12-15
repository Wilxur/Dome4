<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>聊天室选择</title>
    <style>
        body {
            font-family: 'Arial', 'Microsoft YaHei', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }

        .container {
            max-width: 800px;
            margin: 50px auto;
            padding: 30px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #4CAF50;
        }

        .chat-room-list {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 30px;
            margin-top: 40px;
        }

        .chat-room-card {
            width: 300px;
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            background-color: white;
        }

        .chat-room-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .card-header {
            background-color: #4CAF50;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .card-header h2 {
            margin: 0;
            font-size: 24px;
        }

        .card-body {
            padding: 20px;
        }

        .features {
            list-style-type: none;
            padding: 0;
            margin: 0 0 20px 0;
        }

        .features li {
            padding: 8px 0;
            border-bottom: 1px solid #eee;
            color: #666;
        }

        .features li:last-child {
            border-bottom: none;
        }

        .features li:before {
            content: "✓ ";
            color: #4CAF50;
            font-weight: bold;
        }

        .btn {
            display: block;
            width: 100%;
            padding: 12px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            text-align: center;
            border-radius: 4px;
            font-size: 16px;
            font-weight: bold;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .btn:hover {
            background-color: #45a049;
        }

        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #777;
            font-size: 14px;
        }

        .server-info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin-top: 20px;
            font-size: 14px;
            color: #555;
        }

        .card-header.blue {
            background-color: #2196F3;
        }

        .btn.blue {
            background-color: #2196F3;
        }

        .btn.blue:hover {
            background-color: #1976D2;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>在线聊天室系统</h1>

    <div class="server-info">
        <p>服务器已启动，请选择聊天室类型：</p>
        <p>应用路径: <%= request.getContextPath() %></p>
    </div>

    <div class="chat-room-list">
        <!-- 原始聊天室 -->
        <div class="chat-room-card">
            <div class="card-header">
                <h2>原始聊天室</h2>
            </div>
            <div class="card-body">
                <ul class="features">
                    <li>简单公开聊天</li>
                    <li>实时消息更新</li>
                    <li>在线用户列表</li>
                    <li>自动消息刷新</li>
                    <li>用户编号显示</li>
                </ul>
                <a href="original-chat.jsp" class="btn">进入聊天室</a>
            </div>
        </div>

        <!-- 私聊版聊天室 -->
        <div class="chat-room-card">
            <div class="card-header blue">
                <h2>私聊版聊天室</h2>
            </div>
            <div class="card-body">
                <ul class="features">
                    <li>支持私聊功能</li>
                    <li>用户进入/退出通知</li>
                    <li>在线用户列表</li>
                    <li>系统消息提示</li>
                    <li>中文用户编号</li>
                </ul>
                <a href="private-chat.jsp" class="btn blue">进入聊天室</a>
            </div>
        </div>
    </div>

    <div class="footer">
        <p>在线聊天室系统 &copy; 2023</p>
        <p>当前时间: <span id="current-time"></span></p>
        <p>服务器: <%= request.getServerName() %>:<%= request.getServerPort() %></p>
    </div>
</div>

<script>
    // 更新当前时间
    function updateTime() {
        const now = new Date();
        const timeString = now.toLocaleString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        });
        document.getElementById('current-time').textContent = timeString;
    }

    // 页面加载时初始化时间
    document.addEventListener('DOMContentLoaded', function() {
        updateTime();
        // 每秒更新一次时间
        setInterval(updateTime, 1000);
    });
</script>
</body>
</html>
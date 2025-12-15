package com.example.demo4;

import java.io.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet(name = "privateChatServlet", value = "/private-chat-servlet")
public class PrivateChatServlet extends HttpServlet {

    private static final long SESSION_TIMEOUT = 30 * 1000; // 30秒超时
    private static final int MAX_MESSAGES = 100;

    // 用户类
    public static class User {
        private String sessionId;
        private int id;
        private long lastActiveTime;

        public User(String sessionId, int id) {
            this.sessionId = sessionId;
            this.id = id;
            this.lastActiveTime = System.currentTimeMillis();
        }

        public int getId() { return id; }
        public String getSessionId() { return sessionId; }
        public long getLastActiveTime() { return lastActiveTime; }

        public void updateLastActiveTime() {
            this.lastActiveTime = System.currentTimeMillis();
        }

        public String getChineseNum() {
            return numberToChinese(id);
        }

        private String numberToChinese(int num) {
            String[] chineseNumbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"};
            if (num >= 1 && num <= 10) {
                return chineseNumbers[num - 1];
            } else {
                return String.valueOf(num);
            }
        }
    }

    // 消息类
    public static class ChatMessage {
        private int senderId;
        private String senderChinese;
        private String message;
        private int targetUserId;
        private boolean isSystemMessage;
        private String systemMessage;

        public ChatMessage(int senderId, String senderChinese, String message, int targetUserId) {
            this.senderId = senderId;
            this.senderChinese = senderChinese;
            this.message = message;
            this.targetUserId = targetUserId;
            this.isSystemMessage = false;
        }

        public ChatMessage(String systemMessage) {
            this.systemMessage = systemMessage;
            this.isSystemMessage = true;
        }

        public String toHtml(int currentUserId) {
            if (isSystemMessage) {
                return "<div class='system-msg'>" + systemMessage + "</div>";
            }

            if (targetUserId == -1) {
                // 公共消息
                return "<div><b>用户" + senderChinese + "</b>: " + message + "</div>";
            } else {
                // 私聊消息
                if (currentUserId == senderId || currentUserId == targetUserId) {
                    String targetChinese = numberToChinese(targetUserId);
                    return "<div class='private-msg'><b>用户" + senderChinese + "</b> → <b>用户" + targetChinese + "</b>: " + message + "</div>";
                }
                return ""; // 不显示给无关用户
            }
        }

        private String numberToChinese(int num) {
            String[] chineseNumbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"};
            if (num >= 1 && num <= 10) {
                return chineseNumbers[num - 1];
            } else {
                return String.valueOf(num);
            }
        }
    }

    @Override
    public void init() {
        System.out.println("================== PrivateChatServlet 初始化开始 ==================");
        ServletContext context = getServletContext();

        // 同步初始化，确保线程安全
        synchronized (context) {
            // 初始化消息列表
            if (context.getAttribute("privateChatMessages") == null) {
                CopyOnWriteArrayList<ChatMessage> messages = new CopyOnWriteArrayList<>();
                context.setAttribute("privateChatMessages", messages);
                System.out.println("[初始化] 已初始化 privateChatMessages");
            }

            // 初始化用户映射
            if (context.getAttribute("privateChatUsers") == null) {
                ConcurrentHashMap<String, User> users = new ConcurrentHashMap<>();
                context.setAttribute("privateChatUsers", users);
                System.out.println("[初始化] 已初始化 privateChatUsers");
            }
        }

        // 启动监控线程
        startMonitorThread();

        System.out.println("================== PrivateChatServlet 初始化完成 ==================");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 设置字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 直接从request中读取参数
            String action = request.getParameter("action");
            String message = request.getParameter("message");
            String sessionId = request.getParameter("sessionId");
            String targetUserIdStr = request.getParameter("targetUserId");

            System.out.println("[POST] action=" + action +
                    ", sessionId=" + (sessionId != null ? sessionId.substring(0, Math.min(10, sessionId.length())) + "..." : "null") +
                    ", message=" + (message != null && message.length() > 20 ? message.substring(0, 20) + "..." : message) +
                    ", targetUserId=" + targetUserIdStr);

            if (action == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("错误: 缺少action参数");
                return;
            }

            if ("sendMessage".equals(action)) {
                sendMessage(request, response, sessionId, message, targetUserIdStr);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("错误: 无效的action参数");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("服务器错误: " + e.getMessage());
        } finally {
            out.close();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 设置字符编码
        request.setCharacterEncoding("UTF-8");

        try {
            String action = request.getParameter("action");
            String sessionId = request.getParameter("sessionId");

            System.out.println("[GET] action=" + action + ", sessionId=" +
                    (sessionId != null ? sessionId.substring(0, Math.min(10, sessionId.length())) + "..." : "null"));

            if (action == null) {
                // 默认返回消息
                getMessagesHtml(request, response);
                return;
            }

            switch (action) {
                case "getUsers":
                    getUsersJson(request, response);
                    break;
                case "getMessages":
                    getMessagesHtml(request, response);
                    break;
                case "ping":
                    // 测试接口
                    response.setContentType("text/plain;charset=UTF-8");
                    response.getWriter().write("私聊聊天室Servlet运行正常");
                    break;
                case "cleanup":
                    // 清理接口（测试用）
                    cleanupInactiveUsers();
                    response.setContentType("text/plain;charset=UTF-8");
                    response.getWriter().write("已清理不活跃用户");
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "无效的action参数");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write("服务器错误: " + e.getMessage());
        }
    }

    private void sendMessage(HttpServletRequest request, HttpServletResponse response,
                             String sessionId, String message, String targetUserIdStr) throws IOException {

        if (sessionId == null || sessionId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("错误: sessionId不能为空");
            return;
        }

        ServletContext context = getServletContext();
        ConcurrentHashMap<String, User> users = getUsers(context);
        CopyOnWriteArrayList<ChatMessage> messages = getMessages(context);

        System.out.println("[发送消息] 开始处理 - sessionId: " + sessionId + ", 当前用户数: " + users.size());

        // 获取或创建用户
        User user = users.get(sessionId);
        boolean isNewUser = false;

        if (user == null) {
            // 生成新的用户ID
            int newUserId = generateNewUserId(users);
            user = new User(sessionId, newUserId);
            users.put(sessionId, user);
            isNewUser = true;

            // 添加用户加入系统消息
            String joinMsg = "用户" + user.getChineseNum() + " 加入了聊天室";
            messages.add(new ChatMessage(joinMsg));

            // 限制消息数量
            while (messages.size() > MAX_MESSAGES) {
                messages.remove(0);
            }

            System.out.println("[新用户加入] " + joinMsg + " (ID: " + user.getId() + ")");
        }

        user.updateLastActiveTime();

        // 处理消息
        if (message != null && !message.trim().isEmpty()) {
            int targetUserId = -1; // -1表示公共消息
            if (targetUserIdStr != null && !targetUserIdStr.isEmpty()) {
                try {
                    targetUserId = Integer.parseInt(targetUserIdStr);
                } catch (NumberFormatException e) {
                    targetUserId = -1;
                }
            }

            // 添加消息到列表
            ChatMessage newMessage = new ChatMessage(user.getId(), user.getChineseNum(), message.trim(), targetUserId);
            messages.add(newMessage);

            // 限制消息数量
            while (messages.size() > MAX_MESSAGES) {
                messages.remove(0);
            }

            String msgType = targetUserId == -1 ? "[公开]" : "[私聊->用户" + numberToChinese(targetUserId) + "]";
            System.out.println("[消息保存] 用户" + user.getChineseNum() + msgType + " -> " +
                    message.substring(0, Math.min(30, message.length())));
        }

        // 清理不活跃用户
        cleanInactiveUsers(users, messages);

        if (isNewUser) {
            response.getWriter().write("NEW_USER:" + user.getId() + ":" + user.getChineseNum());
        } else {
            response.getWriter().write("OK");
        }

        System.out.println("[发送消息] 处理完成，当前在线用户: " + users.size());
    }

    private void getMessagesHtml(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String sessionId = request.getParameter("sessionId");

            ServletContext context = getServletContext();
            ConcurrentHashMap<String, User> users = getUsers(context);
            CopyOnWriteArrayList<ChatMessage> messages = getMessages(context);

            // 清理不活跃用户
            cleanInactiveUsers(users, messages);

            // 更新当前用户活动时间
            if (sessionId != null && !sessionId.isEmpty()) {
                User currentUser = users.get(sessionId);
                if (currentUser != null) {
                    currentUser.updateLastActiveTime();
                } else {
                    // 如果sessionId存在但用户不在映射中，创建新用户
                    int newUserId = generateNewUserId(users);
                    User newUser = new User(sessionId, newUserId);
                    users.put(sessionId, newUser);
                    messages.add(new ChatMessage("用户" + newUser.getChineseNum() + " 加入了聊天室"));
                    System.out.println("[自动创建用户] 用户" + newUser.getChineseNum());
                }
            }

            // 输出消息
            if (messages.isEmpty()) {
                out.println("<div class='system-msg'>欢迎来到私聊版聊天室！</div>");
            } else {
                int currentUserId = -1;
                if (sessionId != null) {
                    User currentUser = users.get(sessionId);
                    if (currentUser != null) {
                        currentUserId = currentUser.getId();
                    }
                }

                for (ChatMessage msg : messages) {
                    String html = msg.toHtml(currentUserId);
                    if (html != null && !html.isEmpty()) {
                        out.println(html);
                    }
                }

                // 显示当前用户信息
                if (sessionId != null) {
                    User currentUser = users.get(sessionId);
                    if (currentUser != null) {
                        out.println("<div class='system-msg' style='font-size:10px;'>当前用户: 用户" +
                                currentUser.getChineseNum() + " | 在线用户: " + users.size() + "</div>");
                    }
                }
            }

            System.out.println("[获取消息] 返回 " + messages.size() + " 条消息");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<div class='error-msg'>系统错误: " + e.getMessage() + "</div>");
        } finally {
            out.close();
        }
    }

    // 在 PrivateChatServlet 类中，修改 getUsersJson 方法：

    private void getUsersJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String sessionId = request.getParameter("sessionId");

            ServletContext context = getServletContext();
            ConcurrentHashMap<String, User> users = getUsers(context);

            // 清理不活跃用户
            cleanInactiveUsers(users, getMessages(context));

            // 更新当前用户活动时间
            if (sessionId != null && !sessionId.isEmpty()) {
                User currentUser = users.get(sessionId);
                if (currentUser != null) {
                    currentUser.updateLastActiveTime();
                }
            }

            // 构建JSON响应
            List<User> userList = new ArrayList<>(users.values());
            // 按用户ID排序
            userList.sort(Comparator.comparingInt(User::getId));

            StringBuilder json = new StringBuilder("[");

            for (int i = 0; i < userList.size(); i++) {
                User user = userList.get(i);
                json.append("{");
                json.append("\"id\":").append(user.getId()).append(",");
                json.append("\"name\":\"用户").append(user.getChineseNum()).append("\",");
                json.append("\"chineseNum\":\"").append(user.getChineseNum()).append("\"");
                json.append("}");
                if (i < userList.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            String jsonString = json.toString();
            System.out.println("[获取用户列表] 返回JSON: " + jsonString);
            out.write(jsonString);

        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            out.close();
        }
    }

    private void cleanInactiveUsers(ConcurrentHashMap<String, User> users, CopyOnWriteArrayList<ChatMessage> messages) {
        long currentTime = System.currentTimeMillis();
        List<String> toRemove = new ArrayList<>();

        // 找出需要移除的用户
        for (Map.Entry<String, User> entry : users.entrySet()) {
            if (currentTime - entry.getValue().getLastActiveTime() > SESSION_TIMEOUT) {
                toRemove.add(entry.getKey());
            }
        }

        // 移除用户并添加离开消息
        for (String sessionId : toRemove) {
            User removedUser = users.remove(sessionId);
            if (removedUser != null && messages != null) {
                String leaveMsg = "用户" + removedUser.getChineseNum() + " 离开了聊天室";
                messages.add(new ChatMessage(leaveMsg));

                while (messages.size() > MAX_MESSAGES) {
                    messages.remove(0);
                }

                System.out.println("[用户离开] " + leaveMsg);
            }
        }

        if (!toRemove.isEmpty()) {
            System.out.println("[清理用户] 移除了 " + toRemove.size() + " 个不活跃用户");
        }
    }

    private void cleanupInactiveUsers() {
        ServletContext context = getServletContext();
        ConcurrentHashMap<String, User> users = getUsers(context);
        CopyOnWriteArrayList<ChatMessage> messages = getMessages(context);
        cleanInactiveUsers(users, messages);
    }

    private int generateNewUserId(ConcurrentHashMap<String, User> users) {
        int maxId = 0;
        for (User user : users.values()) {
            if (user.getId() > maxId) {
                maxId = user.getId();
            }
        }
        return maxId + 1;
    }

    private String numberToChinese(int num) {
        String[] chineseNumbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"};
        if (num >= 1 && num <= 10) {
            return chineseNumbers[num - 1];
        } else {
            return String.valueOf(num);
        }
    }

    private void startMonitorThread() {
        Thread monitorThread = new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(10000); // 每10秒检查一次

                    ServletContext context = getServletContext();
                    ConcurrentHashMap<String, User> users = getUsers(context);

                    System.out.println("[监控] 私聊聊天室当前在线用户: " + users.size() + " 人");

                    // 自动清理不活跃用户
                    if (!users.isEmpty()) {
                        CopyOnWriteArrayList<ChatMessage> messages = getMessages(context);
                        cleanInactiveUsers(users, messages);
                    }

                } catch (InterruptedException e) {
                    break;
                } catch (Exception e) {
                    System.err.println("[监控线程错误] " + e.getMessage());
                }
            }
        });

        monitorThread.setDaemon(true);
        monitorThread.setName("PrivateChatMonitor");
        monitorThread.start();

        System.out.println("[监控] 私聊聊天室监控线程已启动");
    }

    @SuppressWarnings("unchecked")
    private CopyOnWriteArrayList<ChatMessage> getMessages(ServletContext context) {
        Object messages = context.getAttribute("privateChatMessages");
        if (messages instanceof CopyOnWriteArrayList) {
            return (CopyOnWriteArrayList<ChatMessage>) messages;
        } else {
            CopyOnWriteArrayList<ChatMessage> newMessages = new CopyOnWriteArrayList<>();
            context.setAttribute("privateChatMessages", newMessages);
            return newMessages;
        }
    }

    @SuppressWarnings("unchecked")
    private ConcurrentHashMap<String, User> getUsers(ServletContext context) {
        Object users = context.getAttribute("privateChatUsers");
        if (users instanceof ConcurrentHashMap) {
            return (ConcurrentHashMap<String, User>) users;
        } else {
            ConcurrentHashMap<String, User> newUsers = new ConcurrentHashMap<>();
            context.setAttribute("privateChatUsers", newUsers);
            return newUsers;
        }
    }

    @Override
    public void destroy() {
        System.out.println("================== PrivateChatServlet 销毁 ==================");

        ServletContext context = getServletContext();
        ConcurrentHashMap<String, User> users = getUsers(context);
        CopyOnWriteArrayList<ChatMessage> messages = getMessages(context);

        System.out.println("[销毁] 当前在线用户: " + users.size());
        System.out.println("[销毁] 当前消息数量: " + messages.size());

        // 添加系统关闭消息
        messages.add(new ChatMessage("系统: 聊天室已关闭"));

        System.out.println("[销毁] PrivateChatServlet 销毁完成");
    }
}
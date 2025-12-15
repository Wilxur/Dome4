package com.example.demo4;

import java.io.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet(name = "helloServlet", value = "/hello-servlet")
public class HelloServlet extends HttpServlet {

    private static final long SESSION_TIMEOUT = 30 * 1000; // 30秒超时
    private static final int MAX_MESSAGES = 100;

    public static class ChatMessage {
        private String sessionId;
        private String message;
        private int userId;

        public ChatMessage(String sessionId, String message, int userId) {
            this.sessionId = sessionId;
            this.message = message;
            this.userId = userId;
        }

        public String getSessionId() { return sessionId; }
        public String getMessage() { return message; }
        public int getUserId() { return userId; }

        public String toHTML() {
            return "<div><b>用户" + numberToChinese(userId) + "</b>: " + message + "</div>";
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

    public static class SystemMessage {
        private String message;

        public SystemMessage(String message) {
            this.message = message;
        }

        public String toHTML() {
            return "<div class='system-msg'>" + message + "</div>";
        }
    }

    public static class UserManager {
        private AtomicInteger userCounter = new AtomicInteger(0);
        private ConcurrentHashMap<String, Integer> sessionToUserId = new ConcurrentHashMap<>();
        private ConcurrentHashMap<Integer, String> userIdToName = new ConcurrentHashMap<>();
        private ConcurrentHashMap<String, Long> userActivity = new ConcurrentHashMap<>();

        public synchronized int getOrCreateUserId(String sessionId) {
            // 更新用户活动时间
            userActivity.put(sessionId, System.currentTimeMillis());

            if (sessionToUserId.containsKey(sessionId)) {
                return sessionToUserId.get(sessionId);
            }

            int newUserId = userCounter.incrementAndGet();
            sessionToUserId.put(sessionId, newUserId);

            String userName = "用户" + numberToChinese(newUserId);
            userIdToName.put(newUserId, userName);

            return newUserId;
        }

        public String getUserName(int userId) {
            return userIdToName.getOrDefault(userId, "用户" + userId);
        }

        public List<Map<String, Object>> getOnlineUsers() {
            List<Map<String, Object>> onlineUsers = new ArrayList<>();
            long currentTime = System.currentTimeMillis();

            // 清理不活跃用户
            List<String> toRemove = new ArrayList<>();
            for (Map.Entry<String, Long> entry : userActivity.entrySet()) {
                if (currentTime - entry.getValue() > SESSION_TIMEOUT) {
                    toRemove.add(entry.getKey());
                }
            }

            for (String sessionId : toRemove) {
                userActivity.remove(sessionId);
                Integer userId = sessionToUserId.remove(sessionId);
                if (userId != null) {
                    userIdToName.remove(userId);
                }
            }

            // 构建在线用户列表
            for (Map.Entry<String, Integer> entry : sessionToUserId.entrySet()) {
                if (userActivity.containsKey(entry.getKey())) {
                    Map<String, Object> user = new HashMap<>();
                    user.put("id", entry.getValue());
                    user.put("name", userIdToName.get(entry.getValue()));
                    user.put("chineseNum", numberToChinese(entry.getValue()));
                    onlineUsers.add(user);
                }
            }

            // 按用户ID排序
            onlineUsers.sort(Comparator.comparingInt(user -> (Integer) user.get("id")));

            return onlineUsers;
        }

        public int getOnlineUserCount() {
            return getOnlineUsers().size();
        }

        public void updateUserActivity(String sessionId) {
            userActivity.put(sessionId, System.currentTimeMillis());
        }

        // 数字转中文
        private String numberToChinese(int num) {
            String[] chineseNumbers = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"};
            if (num >= 1 && num <= 10) {
                return chineseNumbers[num - 1];
            } else {
                return String.valueOf(num);
            }
        }

        public void removeUser(String sessionId) {
            userActivity.remove(sessionId);
            Integer userId = sessionToUserId.remove(sessionId);
            if (userId != null) {
                userIdToName.remove(userId);
            }
        }
    }

    @Override
    public void init() {
        System.out.println("================== HelloServlet 初始化开始 ==================");
        ServletContext context = getServletContext();

        synchronized (context) {
            if (context.getAttribute("chatMessages") == null) {
                context.setAttribute("chatMessages", new CopyOnWriteArrayList<ChatMessage>());
            }
            if (context.getAttribute("systemMessages") == null) {
                context.setAttribute("systemMessages", new CopyOnWriteArrayList<SystemMessage>());
            }
            if (context.getAttribute("userManager") == null) {
                context.setAttribute("userManager", new UserManager());
            }
        }

        // 启动监控线程
        startMonitorThread();

        System.out.println("================== HelloServlet 初始化完成 ==================");
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        HttpSession session = request.getSession(true);
        ServletContext context = getServletContext();

        String message = request.getParameter("message");

        if (message != null && !message.trim().isEmpty()) {
            List<ChatMessage> chatMessages = getChatMessages(context);
            UserManager userManager = getUserManager(context);

            int userId = userManager.getOrCreateUserId(session.getId());

            // 创建新消息并添加到列表
            ChatMessage chatMessage = new ChatMessage(session.getId(), message.trim(), userId);
            chatMessages.add(chatMessage);

            if (chatMessages.size() > MAX_MESSAGES) {
                chatMessages.remove(0);
            }

            context.setAttribute("chatMessages", chatMessages);

            // 清理不活跃用户
            cleanupInactiveUsers(userManager);
        }

        response.setStatus(200);
        response.getWriter().write("OK");
    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");

        if ("getUsers".equals(action)) {
            // 返回在线用户列表JSON
            getUsersJson(request, response);
        } else {
            // 返回消息HTML
            getMessagesHtml(request, response);
        }
    }

    private void getMessagesHtml(HttpServletRequest request, HttpServletResponse response) throws IOException {
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(true);
        ServletContext context = getServletContext();
        List<ChatMessage> chatMessages = getChatMessages(context);
        List<SystemMessage> systemMessages = getSystemMessages(context);
        UserManager userManager = getUserManager(context);

        int currentUserId = userManager.getOrCreateUserId(session.getId());

        // 清理不活跃用户
        cleanupInactiveUsers(userManager);

        // 输出系统消息
        if (!systemMessages.isEmpty()) {
            for (SystemMessage msg : systemMessages) {
                out.println(msg.toHTML());
            }
        }

        // 输出聊天消息
        if (chatMessages.isEmpty()) {
            out.println("<div class='system-msg'>欢迎来到原始聊天室！当前用户：<b>" + userManager.getUserName(currentUserId) + "</b></div>");
        } else {
            for (ChatMessage msg : chatMessages) {
                out.println(msg.toHTML());
            }

            out.println("<div style='color: gray; font-size: 12px; margin-top: 10px;'>当前用户：" + userManager.getUserName(currentUserId) +
                    " | 在线用户: " + userManager.getOnlineUserCount() + "</div>");
        }

        out.close();
    }

    private void getUsersJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
        ServletContext context = getServletContext();
        UserManager userManager = getUserManager(context);

        // 清理不活跃用户
        cleanupInactiveUsers(userManager);

        List<Map<String, Object>> users = userManager.getOnlineUsers();

        System.out.println("[调试] 在线用户数量: " + users.size());
        for (Map<String, Object> user : users) {
            System.out.println("[调试] 用户信息: " + user);
        }

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < users.size(); i++) {
                Map<String, Object> user = users.get(i);
                json.append("{");
                json.append("\"id\":").append(user.get("id")).append(",");
                json.append("\"name\":\"").append(user.get("name")).append("\",");
                json.append("\"chineseNum\":\"").append(user.get("chineseNum")).append("\"");
                json.append("}");
                if (i < users.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");

            String jsonString = json.toString();
            System.out.println("[调试] 返回JSON: " + jsonString);
            out.write(jsonString);

        } catch (Exception e) {
            e.printStackTrace();
            out.write("[]");
        } finally {
            out.close();
        }
    }

    private void cleanupInactiveUsers(UserManager userManager) {
        // UserManager内部已经处理了不活跃用户的清理
        // 这里只是确保在线用户列表是最新的
        userManager.getOnlineUsers(); // 这会触发清理
    }

    private void startMonitorThread() {
        Thread monitorThread = new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(10000); // 每10秒检查一次

                    ServletContext context = getServletContext();
                    UserManager userManager = getUserManager(context);

                    System.out.println("[监控] 原始聊天室当前在线用户: " + userManager.getOnlineUserCount() + " 人");

                } catch (InterruptedException e) {
                    break;
                } catch (Exception e) {
                    System.err.println("[监控线程错误] " + e.getMessage());
                }
            }
        });

        monitorThread.setDaemon(true);
        monitorThread.setName("HelloServletMonitor");
        monitorThread.start();

        System.out.println("[监控] 原始聊天室监控线程已启动");
    }

    @SuppressWarnings("unchecked")
    private List<ChatMessage> getChatMessages(ServletContext context) {
        Object messages = context.getAttribute("chatMessages");
        if (messages instanceof List) {
            return (List<ChatMessage>) messages;
        }
        return new CopyOnWriteArrayList<>();
    }

    @SuppressWarnings("unchecked")
    private List<SystemMessage> getSystemMessages(ServletContext context) {
        Object messages = context.getAttribute("systemMessages");
        if (messages instanceof List) {
            return (List<SystemMessage>) messages;
        }
        return new CopyOnWriteArrayList<>();
    }

    @SuppressWarnings("unchecked")
    private UserManager getUserManager(ServletContext context) {
        Object manager = context.getAttribute("userManager");
        if (manager instanceof UserManager) {
            return (UserManager) manager;
        }
        return new UserManager();
    }

    @Override
    public void destroy() {
        System.out.println("================== HelloServlet 销毁 ==================");

        ServletContext context = getServletContext();
        UserManager userManager = getUserManager(context);

        System.out.println("[销毁] 当前在线用户: " + userManager.getOnlineUserCount());
        System.out.println("[销毁] HelloServlet 销毁完成");
    }
}
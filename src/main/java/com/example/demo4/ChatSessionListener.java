package com.example.demo4;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.ServletContext;

import java.util.concurrent.ConcurrentHashMap;
import java.util.List;

@WebListener
public class ChatSessionListener implements HttpSessionListener {

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        ServletContext context = session.getServletContext();

        String sessionId = session.getId();
        System.out.println("================== 私聊聊天室会话销毁 ==================");
        System.out.println("会话ID: " + sessionId);

        // 处理私聊版用户退出
        Object usersObj = context.getAttribute("privateChatUsers");
        if (usersObj instanceof ConcurrentHashMap) {
            @SuppressWarnings("unchecked")
            ConcurrentHashMap<String, PrivateChatServlet.User> users =
                    (ConcurrentHashMap<String, PrivateChatServlet.User>) usersObj;

            PrivateChatServlet.User removedUser = users.remove(sessionId);
            if (removedUser != null) {
                Object messagesObj = context.getAttribute("privateChatMessages");
                if (messagesObj instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<PrivateChatServlet.ChatMessage> messages =
                            (List<PrivateChatServlet.ChatMessage>) messagesObj;

                    String leaveMsg = "用户" + removedUser.getChineseNum() + " 离开了聊天室";
                    messages.add(new PrivateChatServlet.ChatMessage(leaveMsg));

                    if (messages.size() > 100) {
                        messages.remove(0);
                    }

                    System.out.println("[私聊聊天室] " + leaveMsg);
                }
            }
        }

        System.out.println("================== 私聊聊天室会话销毁处理完成 ==================");
    }

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        System.out.println("私聊聊天室新会话创建: " + session.getId());

        // 设置会话超时时间（30分钟）
        session.setMaxInactiveInterval(30 * 60);
    }
}
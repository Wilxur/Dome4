package com.example.demo4;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.ServletContext;

@WebListener
public class OriginalChatSessionListener implements HttpSessionListener {

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        ServletContext context = session.getServletContext();

        String sessionId = session.getId();
        System.out.println("================== 原始聊天室会话销毁 ==================");
        System.out.println("会话ID: " + sessionId);

        // 处理原始聊天室用户退出
        Object managerObj = context.getAttribute("userManager");
        if (managerObj instanceof HelloServlet.UserManager) {
            HelloServlet.UserManager userManager = (HelloServlet.UserManager) managerObj;

            // 移除用户
            userManager.removeUser(sessionId);
            System.out.println("[原始聊天室] 用户会话已移除");
        }

        System.out.println("================== 原始聊天室会话销毁处理完成 ==================");
    }

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        HttpSession session = se.getSession();
        System.out.println("原始聊天室新会话创建: " + session.getId());

        // 设置会话超时时间（30分钟）
        session.setMaxInactiveInterval(30 * 60);
    }
}
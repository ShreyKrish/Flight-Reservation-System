<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>

<%
    String username = (String) session.getAttribute("user");
    session.invalidate();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Logout</title>
</head>
<body>
    <p>Logout successful, <%= username %>.</p>
    <p><a href="loginPage.jsp">Login again</a></p>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>
</title>
</head>
<body>
<%
	String userid = request.getParameter("username");
	String pwd = request.getParameter("password");
	String pvlg = request.getParameter("privilege");

	ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
	Statement st = con.createStatement();
	ResultSet rs;

	rs = st.executeQuery("select * from users where username='" + userid + "' and password='" + pwd + "' and accessPrivilege=" + pvlg + "");
	if (rs.next()) {
        session.setAttribute("user", userid); // the username will be stored in the session
        out.println("Welcome " + userid);
        out.println("<a href='logout.jsp'>Log out</a>");

        if (pvlg.equals("1")) {
            response.sendRedirect("adminActionsHome.jsp");
        } else if (pvlg.equals("2")) {
            response.sendRedirect("repActionsHome.jsp");
        } else {
            response.sendRedirect("customerActionsHome.jsp");
        }
    } else {
        out.println("Invalid credentials. <a href='loginPage.jsp'> Try again? </a>");
    }
%>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Login</title>
</head>
<body>
<br
Select user type and login
<br>
<form action="displayLoginDetails.jsp" method="POST">
  <input type="radio" name="privilege" value=1> Administrator
  <input type="radio" name="privilege" value=2> Representative
  <input type="radio" name="privilege" value=3> Customer
  <br>
  Username: <input type="text" name="username"/> <br/>
  Password: <input type="password" name="password"/> <br/>
  <input type="submit" value="Submit"/>
</form>
</body>
</html>

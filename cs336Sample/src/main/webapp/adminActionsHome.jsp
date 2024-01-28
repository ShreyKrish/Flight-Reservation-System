<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<!DOCTYPE html>
<html>
<style>
  .radio-group {
    display: flex;
    flex-direction: column;
  }
</style>
<head>
<meta charset="ISO-8859-1">
<title>Admin Home</title>
</head>
<body>
<form class="radio-group" action="adminProcessForm.jsp" method="post">
  <div>
    <input type="radio" name="adminAction" value="1"> Customer Representative/Customer Management
  </div>
  <div>
    <input type="radio" name="adminAction" value="2"> Monthly Sales Report
  </div>
  <div>
    <input type="radio" name="adminAction" value="3"> Reservation List
  </div>
  <div>
    <input type="radio" name="adminAction" value="4"> Revenue Logs
  </div>
  <div>
    <input type="radio" name="adminAction" value="5"> MVP Customer
  </div>
  <div>
    <input type="radio" name="adminAction" value="6"> Most Active Flights
  </div><br>
  <input type="submit" value="Submit"/>
</form><br>
<form action="logout.jsp" method="post">
  <input type="submit" value="Logout">
</form>
</body>
</html>
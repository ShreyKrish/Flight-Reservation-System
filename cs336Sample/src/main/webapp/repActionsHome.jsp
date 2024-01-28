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
<title>Representative Home</title>
</head>
<body>
<form class="radio-group" action="repProcessForm.jsp" method="post">
  <div>
    <input type="radio" name="repAction" value="1"> Book Customer Reservations
  </div>
  <div>
    <input type="radio" name="repAction" value="2"> Edit Customer Reservations
  </div>
  <div>
    <input type="radio" name="repAction" value="3"> Answer Questions
  </div>
  <div>
    <input type="radio" name="repAction" value="4"> Aircraft/Airport/Flight Management
  </div>
  <div>
    <input type="radio" name="repAction" value="5"> Retrieve Waiting List
  </div>
  <div>
    <input type="radio" name="repAction" value="6"> Current Flight Arrivals/Departures
  </div><br>
  <input type="submit" value="Submit"/>
</form><br>
<form action="logout.jsp" method="post">
  <input type="submit" value="Logout">
</form>
</body>
</html>
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
  table {
    border-collapse: collapse;
    width: 50%;
    margin-bottom: 20px;
  }
  th, td {
    border: 1px solid black;
    padding: 8px;
    text-align: left;
  }
</style>
<head>
  <meta charset="ISO-8859-1">
  <title>Customer/Customer Rep Management</title>
</head> 
<body>
	<form class="radio-group" action="adminProcessForm.jsp" method="post">
  	<div>
    	<input type="radio" name="adminAction" value="1"> Customer Representative/Customer Onboarding
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
	</form>
  <br>
  <form action="admin_updateManagementTable.jsp" method="post">
    <input type="submit" value="View Current Customers and Customer Reps"/>
  </form>
  <br>
  Customer Management
  <br>
  <form action="admin_updateManagementTable.jsp" method="post">
    	<label for="user_id">User ID:</label>
    	<input type="text" name="user_id" required/><br/>

    	<label for="cid">Customer ID:</label>
    	<input type="text" name="cid" required/><br/>
    	
    	<label for="username">Username:</label>
    	<input type="text" name="username" required/><br/>
    	
    	 <label for="password">Password:</label>
    	<input type="text" name="password" required/><br/>

	    <label for="fname">First Name:</label>
    	<input type="text" name="fname" required/><br/>

    	<label for="lname">Last Name:</label>
    	<input type="text" name="lname" required/><br/>

    	<input type="submit" name="addCustomer" value="Add Customer"/>
    	<input type="submit" name="editCustomer" value="Edit Customer"/>
    	<input type="submit" name="deleteCustomer" value="Delete Customer"/>
    </form>
 	<br>
 	Customer Representative Management
 	<br>
 	<form action="admin_updateManagementTable.jsp" method="post">
  		<label for="user_id">User ID:</label>
  		<input type="text" name="user_id" required/><br/>

  		<label for="username">Username:</label>
  		<input type="text" name="username" required/><br/>

  		<label for="password">Password:</label>
  		<input type="text" name="password" required/><br/>

  		<input type="submit" name="addCustomerRep" value="Add Customer Representative"/>
  		<input type="submit" name="editCustomerRep" value="Edit Customer Representative"/>
  		 <input type="submit" name="deleteCustomerRep" value="Delete Customer Representative"/>
	</form>
	<br>
    <form action="logout.jsp" method="post">
    <input type="submit" value="Logout">
 	</form>
</body>
</html>

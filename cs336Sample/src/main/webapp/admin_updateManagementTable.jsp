<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*, java.sql.*" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<!DOCTYPE html>
<html>
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
<%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
        
        Statement stmt1 = con.createStatement();
        Statement stmt2 = con.createStatement();

        // Handle add, edit, delete actions
        String addCustomer = request.getParameter("addCustomer");
        String editCustomer = request.getParameter("editCustomer");
        String deleteCustomer = request.getParameter("deleteCustomer");

        String addCustomerRep = request.getParameter("addCustomerRep");
        String editCustomerRep = request.getParameter("editCustomerRep");
        String deleteCustomerRep = request.getParameter("deleteCustomerRep");

        // Handle add, edit, delete for customers
        if (addCustomer != null) {
            // Handle add customer logic using PreparedStatement
            PreparedStatement pstmt = null;
            try {
                String insertCustomerQuery = "INSERT INTO users (user_id, username, password, accessPrivilege) VALUES (?, ?, ?, ?)";
                pstmt = con.prepareStatement(insertCustomerQuery);
                pstmt.setString(1, request.getParameter("user_id"));
                pstmt.setString(2, request.getParameter("username"));
                pstmt.setString(3, request.getParameter("password"));
                pstmt.setInt(4, 3); // Access privilege of 3 for customers
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }

            // Additional logic for inserting into the customers table
            String insertCustomerDetailsQuery = "INSERT INTO customers (user_id, cid, fname, lname) VALUES (?, ?, ?, ?)";
            pstmt = null;
            try {
                pstmt = con.prepareStatement(insertCustomerDetailsQuery);
                pstmt.setString(1, request.getParameter("user_id"));
                pstmt.setString(2, request.getParameter("cid"));
                pstmt.setString(3, request.getParameter("fname"));
                pstmt.setString(4, request.getParameter("lname"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }
        } else if (editCustomer != null) {
            // Handle edit customer logic using PreparedStatement
            PreparedStatement pstmt = null;
            try {
                String updateCustomerQuery = "UPDATE users SET username=?, password=? WHERE user_id=?";
                pstmt = con.prepareStatement(updateCustomerQuery);
                pstmt.setString(1, request.getParameter("username"));
                pstmt.setString(2, request.getParameter("password"));
                pstmt.setString(3, request.getParameter("user_id"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }

            // Additional logic for updating the customers table
            String updateCustomerDetailsQuery = "UPDATE customers SET fname=?, lname=? WHERE user_id=?";
            pstmt = null;
            try {
                pstmt = con.prepareStatement(updateCustomerDetailsQuery);
                pstmt.setString(1, request.getParameter("fname"));
                pstmt.setString(2, request.getParameter("lname"));
                pstmt.setString(3, request.getParameter("user_id"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }
        } else if (deleteCustomer != null) {
            // Handle delete customer logic using PreparedStatement
            PreparedStatement pstmt = null;
            try {
                String deleteCustomerQuery = "DELETE FROM users WHERE user_id=?";
                pstmt = con.prepareStatement(deleteCustomerQuery);
                pstmt.setString(1, request.getParameter("user_id"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }

            // Additional logic for deleting from the customers table
            String deleteCustomerDetailsQuery = "DELETE FROM customers WHERE user_id=?";
            pstmt = null;
            try {
                pstmt = con.prepareStatement(deleteCustomerDetailsQuery);
                pstmt.setString(1, request.getParameter("user_id"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }
        }

        // Handle add, edit, delete for customer representatives
        if (addCustomerRep != null) {
            // Handle add customer representative logic using PreparedStatement
            PreparedStatement pstmt = null;
            try {
                String insertCustomerRepQuery = "INSERT INTO users (user_id, username, password, accessPrivilege) VALUES (?, ?, ?, ?)";
                pstmt = con.prepareStatement(insertCustomerRepQuery);
                pstmt.setString(1, request.getParameter("user_id"));
                pstmt.setString(2, request.getParameter("username"));
                pstmt.setString(3, request.getParameter("password"));
                pstmt.setInt(4, 2); // Access privilege of 2 for customer reps
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }
        } else if (editCustomerRep != null) {
            // Handle edit customer representative logic using PreparedStatement
            PreparedStatement pstmt = null;
            try {
                String updateCustomerRepQuery = "UPDATE users SET username=?, password=? WHERE user_id=?";
                pstmt = con.prepareStatement(updateCustomerRepQuery);
                pstmt.setString(1, request.getParameter("username"));
                pstmt.setString(2, request.getParameter("password"));
                pstmt.setString(3, request.getParameter("user_id"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }
        } else if (deleteCustomerRep != null) {
            // Handle delete customer representative logic using PreparedStatement
            PreparedStatement pstmt = null;
            try {
                String deleteCustomerRepQuery = "DELETE FROM users WHERE user_id=?";
                pstmt = con.prepareStatement(deleteCustomerRepQuery);
                pstmt.setString(1, request.getParameter("user_id"));
                pstmt.executeUpdate();
            } finally {
                if (pstmt != null) {
                    pstmt.close();
                }
            }
        }

        // Retrieve and display customer table
        String customerSet = "SELECT * FROM users WHERE accessPrivilege=3";
        String customerRepSet = "SELECT * FROM users WHERE accessPrivilege=2";
        ResultSet customerResults = stmt1.executeQuery(customerSet);
        ResultSet customerRepResults = stmt2.executeQuery(customerRepSet);

%>
    <h2>Customer Table</h2>
    <table border="1">
        <tr>
            <th>User ID</th>
            <th>Customer ID</th>
            <th>First Name</th>
            <th>Last Name</th>
        </tr>
        <%
            while (customerResults.next()) {
        %>
                <tr>
                    <td><%= customerResults.getString("user_id") %></td>
                    <td><%= customerResults.getString("cid") %></td>
                    <td><%= customerResults.getString("fname") %></td>
                    <td><%= customerResults.getString("lname") %></td>
                </tr>
        <%
            }
        %>
    </table>

    <h2>Customer Representative Table</h2>
    <table border="1">
        <tr>
            <th>User ID</th>
            <th>Username</th>
            <th>Password</th>
        </tr>
        <%
            while (customerRepResults.next()) {
        %>
                <tr>
                    <td><%= customerRepResults.getString("user_id") %></td>
                    <td><%= customerRepResults.getString("username") %></td>
                    <td><%= customerRepResults.getString("password") %></td>
                </tr>
        <%
            }
        %>
    </table>

<%
        // Close the database connection
		db.closeConnection(con);
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<br>
<form action="logout.jsp" method="post">
    <input type="submit" value="Logout">
 </form>
</body>
</html>

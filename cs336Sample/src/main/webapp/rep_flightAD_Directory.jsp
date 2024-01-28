<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="ISO-8859-1">
    <title>Flight Arrivals/Departures</title>
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
        </div>
        <br>
        <input type="submit" value="Submit" />
    </form>
    <!-- Flight Management -->
    <br>
    <form action="rep_displayArrivalsDepartures.jsp" method="post">
        <label for="ap_id">Select Airport:</label>
        <select name="ap_id">
            <%
                Connection conDropdown = null;
                Statement stmtDropdown = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown = dbDropdown.getConnection();
                    stmtDropdown = conDropdown.createStatement();

                    String airportQuery = "SELECT * FROM airports";
                    ResultSet airportResults = stmtDropdown.executeQuery(airportQuery);

                    while (airportResults.next()) {
            %>
            <option value="<%= airportResults.getString("ap_id") %>">
                <%= airportResults.getString("ap_id") %>
            </option>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    // Close database connections and statements
                    if (stmtDropdown != null) {
                        stmtDropdown.close();
                    }
                    if (conDropdown != null) {
                        conDropdown.close();
                    }
                }
            %>
        </select><br>
        <input type="submit" name="displayAD" value="Show Arrivals/Departures" />
    </form>
    <br>
    <form action="logout.jsp" method="post">
        <input type="submit" value="Logout">
    </form>
</body>
</html>

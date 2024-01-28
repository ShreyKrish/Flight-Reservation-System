<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
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
    <title>Aircraft/Airport/Flight Management</title>
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
    <br>
    <form action="rep_updateAirManagementTable.jsp" method="post">
        <input type="submit" value="View Aircrafts/Airports/Flights" />
    </form>
    <!-- Aircraft Management -->
    <br>
    <form action="rep_updateAirManagementTable.jsp" method="post">
        <label for="ac_id">Aircraft ID:</label>
        <input type="text" name="ac_id" required /><br />
        <label for="seat_count">Seat Count:</label>
        <input type="text" name="seat_count" required /><br />
        <label for="available_days">Available Days:</label><br />
        <input type="checkbox" name="available_days" value="Monday"> Monday
        <input type="checkbox" name="available_days" value="Tuesday"> Tuesday
        <input type="checkbox" name="available_days" value="Wednesday"> Wednesday
        <input type="checkbox" name="available_days" value="Thursday"> Thursday
        <input type="checkbox" name="available_days" value="Friday"> Friday
        <input type="checkbox" name="available_days" value="Saturday"> Saturday
        <input type="checkbox" name="available_days" value="Sunday"> Sunday <br />
        <label for="airline_id">Select Airline:</label>
        <select name="airline_id">
            <%
                Connection conDropdown = null;
                Statement stmtDropdown = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown = dbDropdown.getConnection();
                    stmtDropdown = conDropdown.createStatement();

                    String airlineQuery = "SELECT * FROM airline_companies";
                    ResultSet airlineResults = stmtDropdown.executeQuery(airlineQuery);

                    while (airlineResults.next()) {
            %>
            <option value="<%= airlineResults.getString("airline_id") %>">
                <%= airlineResults.getString("airline_id") %>
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
        </select> <br>
        <input type="submit" name="addAircraft" value="Add Aircraft" />
        <input type="submit" name="editAircraft" value="Edit Aircraft" />
        <input type="submit" name="deleteAircraft" value="Delete Aircraft" />
    </form>
    <br>
    <!-- Airport Management -->
    <br>
    <form action="rep_updateAirManagementTable.jsp" method="post">
        <label for="ap_id">Airport ID:</label>
        <input type="text" name="ap_id" required /><br />
        <label for="airport_name">Airport Name:</label>
        <input type="text" name="airport_name" /><br />
        <label for="airline_id">Select Associated Airlines (hold ctrl/command for multiple):</label><br>
        <select name="airline_id" multiple>
            <%
                Connection conDropdown2 = null;
                Statement stmtDropdown2 = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown2 = dbDropdown.getConnection();
                    stmtDropdown2 = conDropdown2.createStatement();

                    String airlineQuery = "SELECT * FROM airline_companies";
                    ResultSet airlineResults = stmtDropdown2.executeQuery(airlineQuery);

                    while (airlineResults.next()) {
            %>
            <option value="<%= airlineResults.getString("airline_id") %>">
                <%= airlineResults.getString("airline_id") %>
            </option>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    // Close database connections and statements
                    if (stmtDropdown2 != null) {
                        stmtDropdown2.close();
                    }
                    if (conDropdown2 != null) {
                        conDropdown2.close();
                    }
                }
            %>
        </select><br>
        <input type="submit" name="addAirport" value="Add Airport" />
        <input type="submit" name="editAirport" value="Edit Airport" />
        <input type="submit" name="deleteAirport" value="Delete Airport" />
    </form>
    <br>
    <!-- Flight Management -->
    <br>
    <form action="rep_updateAirManagementTable.jsp" method="post">
        <label for="fid">Flight ID:</label>
        <input type="text" name="fid" required /><br />
        <label for="isInternational">International Flight:</label>
        <input type="checkbox" name="isInternational" value="true" />Yes<br />
        <label for="ap_id">Departure Airport:</label>
        <select name="ap_id">
            <%
                Connection conDropdown3 = null;
                Statement stmtDropdown3 = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown3 = dbDropdown.getConnection();
                    stmtDropdown3 = conDropdown3.createStatement();

                    String airportQuery = "SELECT * FROM airports";
                    ResultSet airportResults = stmtDropdown3.executeQuery(airportQuery);

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
                    if (stmtDropdown3 != null) {
                        stmtDropdown3.close();
                    }
                    if (conDropdown3 != null) {
                        conDropdown3.close();
                    }
                }
            %>
        </select> <br>
        <label for="ap_id2">Arrival Airport:</label>
        <select name="ap_id2">
            <%
                Connection conDropdown4 = null;
                Statement stmtDropdown4 = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown4 = dbDropdown.getConnection();
                    stmtDropdown4 = conDropdown4.createStatement();

                    String airportQuery = "SELECT * FROM airports";
                    ResultSet airportResults = stmtDropdown4.executeQuery(airportQuery);

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
                    if (stmtDropdown4 != null) {
                        stmtDropdown4.close();
                    }
                    if (conDropdown4 != null) {
                        conDropdown4.close();
                    }
                }
            %>
        </select> <br>
        <label for="airline_id">Select Airline:</label>
        <select name="airline_id">
            <%
                Connection conDropdown5 = null;
                Statement stmtDropdown5 = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown5 = dbDropdown.getConnection();
                    stmtDropdown5 = conDropdown5.createStatement();

                    String airlineQuery = "SELECT * FROM airline_companies";
                    ResultSet airlineResults = stmtDropdown5.executeQuery(airlineQuery);

                    while (airlineResults.next()) {
            %>
            <option value="<%= airlineResults.getString("airline_id") %>">
                <%= airlineResults.getString("airline_id") %>
            </option>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    // Close database connections and statements
                    if (stmtDropdown5 != null) {
                        stmtDropdown5.close();
                    }
                    if (conDropdown5 != null) {
                        conDropdown5.close();
                    }
                }
            %>
        </select><br>
        <label for="ac_id">Select Aircraft:</label>
        <select name="ac_id">
            <%
                Connection conDropdown6 = null;
                Statement stmtDropdown6 = null;
                try {
                    ApplicationDB dbDropdown = new ApplicationDB();
                    conDropdown6 = dbDropdown.getConnection();
                    stmtDropdown6 = conDropdown6.createStatement();

                    String aircraftsQuery = "SELECT * FROM aircrafts";
                    ResultSet aircraftsResults = stmtDropdown6.executeQuery(aircraftsQuery);

                    while (aircraftsResults.next()) {
            %>
            <option value="<%= aircraftsResults.getString("ac_id") %>">
                <%= aircraftsResults.getString("ac_id") %>
            </option>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    // Close database connections and statements
                    if (stmtDropdown6 != null) {
                        stmtDropdown6.close();
                    }
                    if (conDropdown6 != null) {
                        conDropdown6.close();
                    }
                }
            %>
        </select><br> 
        <label for="d_datetime">Departure Time:</label>
        <input type="datetime-local" name="d_datetime" /><br />
        <label for="a_datetime">Arrival Time:</label>
        <input type="datetime-local" name="a_datetime"/><br />
        <input type="submit" name="addFlight" value="Add Flight" />
        <input type="submit" name="editFlight" value="Edit Flight" />
        <input type="submit" name="deleteFlight" value="Delete Flight" />
    </form>
    <br>
    <form action="logout.jsp" method="post">
        <input type="submit" value="Logout">
    </form>
</body>
</html>

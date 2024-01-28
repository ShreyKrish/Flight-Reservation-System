<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*, java.sql.*, java.time.*, java.util.*"%>
<%@ page import="javax.servlet.http.*, javax.servlet.*"%>
<!DOCTYPE html>
<html>
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

    <% 
        Connection con = null;
        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            String displayAD = request.getParameter("displayAD");

            if (displayAD != null) {
                try {
                    // Assuming a hypothetical query to fetch flight information
                    String airportId = request.getParameter("ap_id");
                    String getDepartListQuery = "SELECT * FROM departs WHERE ap_id=?";
                    String getArriveListQuery = "SELECT * FROM arrives WHERE ap_id=?";
                    PreparedStatement pstmtDepartFlightInfo = con.prepareStatement(getDepartListQuery);
                    PreparedStatement pstmtArriveFlightInfo = con.prepareStatement(getArriveListQuery);
                    pstmtDepartFlightInfo.setString(1, airportId);
                    pstmtArriveFlightInfo.setString(1, airportId);
                    ResultSet departFlightResults = pstmtDepartFlightInfo.executeQuery();
                    ResultSet arriveFlightResults = pstmtArriveFlightInfo.executeQuery();

                    %>
                    <h2>Departures</h2>
                    <table border="1">
                        <tr>
                            <th>Flight ID</th>
                            <th>Status</th>
                            <th>Airport</th>
                            <th>Departure Time</th>
                            <th>Airline</th>
                        </tr>
                        <%
                        while (departFlightResults.next()) {
                            String fid = departFlightResults.getString("fid");
                            String airport = departFlightResults.getString("ap_id");
                            String departureTime = departFlightResults.getString("d_datetime");

                            // Retrieve status information for the current flight
                            String getStatusQuery = "SELECT isInternational FROM flights WHERE fid=?";
                            PreparedStatement pstmtInternationalStatus = null; 
                            ResultSet statusInfo = null;

                            // Retrieve airline information for the current flight
                            String getHandlesInfoQuery = "SELECT airline_id FROM handles WHERE fid=?";
                            PreparedStatement pstmtHandlesInfo = null; 
                            ResultSet handlesInfo = null; 

                            try {
                                // Process the results and display the table rows
                                boolean isInternational = false;
                                pstmtInternationalStatus = con.prepareStatement(getStatusQuery);
                                pstmtInternationalStatus.setString(1, fid);
                                statusInfo = pstmtInternationalStatus.executeQuery();
                                
                                if (statusInfo.next()) {
                                    isInternational = statusInfo.getBoolean("isInternational");
                                }
                                
                                String airlineId = "";
                                pstmtHandlesInfo = con.prepareStatement(getHandlesInfoQuery);
                                pstmtHandlesInfo.setString(1, fid);
                                handlesInfo = pstmtHandlesInfo.executeQuery();
                                
                                if (handlesInfo.next()) {
                                    airlineId = handlesInfo.getString("airline_id");
                                }
                                
                                %>
                                <tr>
                                    <td><%=fid%></td>
                                    <td><%=isInternational ? "International" : "Domestic"%></td>
                                    <td><%=airport%></td>
                                    <td><%=departureTime%></td>
                                    <td><%=airlineId%></td>
                                </tr>
                                <%
                            } finally {
                                // Close result sets and prepared statements in the inner finally block
                                if(statusInfo != null){
                                    statusInfo.close();
                                }
                                if(pstmtInternationalStatus != null){
                                    pstmtInternationalStatus.close();
                                }
                                if (handlesInfo != null) {
                                    handlesInfo.close();
                                }
                                if (pstmtHandlesInfo != null) {
                                    pstmtHandlesInfo.close();
                                }
                            }
                        }
                        %>
                    </table>
                    <h2>Arrivals</h2>
                    <table border="1">
                        <tr>
                            <th>Flight ID</th>
                            <th>Status</th>
                            <th>Airport</th>
                            <th>Arrival Time</th>
                            <th>Airline</th>
                        </tr>
                        <%
                        while (arriveFlightResults.next()) {
                            String fid = arriveFlightResults.getString("fid");
                            String airport = arriveFlightResults.getString("ap_id");
                            String arrivalTime = arriveFlightResults.getString("a_datetime");

                            // Retrieve status information for the current flight
                            String getStatusQuery = "SELECT isInternational FROM flights WHERE fid=?";
                            PreparedStatement pstmtInternationalStatus = null; 
                            ResultSet statusInfo = null;

                            // Retrieve airline information for the current flight
                            String getHandlesInfoQuery = "SELECT airline_id FROM handles WHERE fid=?";
                            PreparedStatement pstmtHandlesInfo = null; 
                            ResultSet handlesInfo = null; 

                            try {
                                // Process the results and display the table rows
                                boolean isInternational = false;
                                pstmtInternationalStatus = con.prepareStatement(getStatusQuery);
                                pstmtInternationalStatus.setString(1, fid);
                                statusInfo = pstmtInternationalStatus.executeQuery();
                                
                                if (statusInfo.next()) {
                                    isInternational = statusInfo.getBoolean("isInternational");
                                }
                                
                                String airlineId = "";
                                pstmtHandlesInfo = con.prepareStatement(getHandlesInfoQuery);
                                pstmtHandlesInfo.setString(1, fid);
                                handlesInfo = pstmtHandlesInfo.executeQuery();
                                
                                if (handlesInfo.next()) {
                                    airlineId = handlesInfo.getString("airline_id");
                                }
                                
                                %>
                                <tr>
                                    <td><%=fid%></td>
                                    <td><%=isInternational ? "International" : "Domestic"%></td>
                                    <td><%=airport%></td>
                                    <td><%=arrivalTime%></td>
                                    <td><%=airlineId%></td>
                                </tr>
                                <%
                            } finally {
                                // Close result sets and prepared statements in the inner finally block
                                if(statusInfo != null){
                                    statusInfo.close();
                                }
                                if(pstmtInternationalStatus != null){
                                    pstmtInternationalStatus.close();
                                }
                                if (handlesInfo != null) {
                                    handlesInfo.close();
                                }
                                if (pstmtHandlesInfo != null) {
                                    pstmtHandlesInfo.close();
                                }
                            }
                        }
                        %>
                    </table>                    
                    <%
                } catch (SQLException e) {
                    e.printStackTrace();
                } 
            }
        } finally {
            // Close the main database connection
            if (con != null) {
                con.close();
            }
        }
    %>
    <br>
    <form action="logout.jsp" method="post">
        <input type="submit" value="Logout">
    </form>
</body>
</html>

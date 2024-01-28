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

    <%@ page import="java.util.StringTokenizer"%>

    <%
        Connection con = null;
        Statement stmt1 = null;
        Statement stmt2 = null;
        Statement stmt3 = null;
        Statement stmt4 = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();
            stmt1 = con.createStatement();
            stmt2 = con.createStatement();
            stmt3 = con.createStatement();
            stmt4 = con.createStatement();

            String addAircraft = request.getParameter("addAircraft");
            String editAircraft = request.getParameter("editAircraft");
            String deleteAircraft = request.getParameter("deleteAircraft");

            String addAirport = request.getParameter("addAirport");
            String editAirport = request.getParameter("editAirport");
            String deleteAirport = request.getParameter("deleteAirport");

            String addFlight = request.getParameter("addFlight");
            String editFlight = request.getParameter("editFlight");
            String deleteFlight = request.getParameter("deleteFlight");

            if (addAircraft != null) {
                try {
                    // Continue with the aircraft insertion
                    String insertAircraftQuery = "INSERT INTO aircrafts (ac_id, seat_count, available_days) VALUES (?, ?, ?)";
                    String insertOwnsQuery = "INSERT INTO owns (airline_id, ac_id) VALUES (?, ?)";
                    PreparedStatement pstmt = con.prepareStatement(insertAircraftQuery);
                    PreparedStatement pstmt2 = con.prepareStatement(insertOwnsQuery);
                    pstmt.setString(1, request.getParameter("ac_id"));
                    
                    // Validate seat count to ensure it's not negative
                    int newSeatCount = Integer.parseInt(request.getParameter("seat_count"));
                    if (newSeatCount < 0) {
                        // Handle the error, throw an exception, or take appropriate action
                        throw new RuntimeException("Seat count cannot be negative.");
                    }

                    pstmt.setInt(2, newSeatCount);  // Use the validated seat count
                    pstmt2.setString(1, request.getParameter("airline_id"));
                    pstmt2.setString(2, request.getParameter("ac_id"));

                    String[] availableDays = request.getParameterValues("available_days");
                    if (availableDays != null && availableDays.length > 0) {
                        StringBuilder availableDaysString = new StringBuilder();
                        for (String day : availableDays) {
                            availableDaysString.append(day).append(",");
                        }
                        availableDaysString.setLength(availableDaysString.length() - 1);
                        pstmt.setString(3, availableDaysString.toString());
                    } else {
                        pstmt.setString(3, "");
                    }

                    pstmt.executeUpdate();
                    pstmt2.executeUpdate();

                    // Increment the aircraft_count in the airline_companies table
                    String updateAircraftCountQuery = "UPDATE airline_companies SET aircraft_count = aircraft_count + 1 WHERE airline_id = ?";
                    PreparedStatement updateStmt = con.prepareStatement(updateAircraftCountQuery);
                    updateStmt.setString(1, request.getParameter("airline_id"));
                    updateStmt.executeUpdate();
                } catch (SQLException e) {
                    // Handle the SQL exception
                    e.printStackTrace(); 
                }
            } else if (editAircraft != null) {
                // Handle edit aircraft logic using PreparedStatement
                PreparedStatement pstmtUpdateAircraft = null;
                PreparedStatement pstmtUpdateOwns = null;
                PreparedStatement pstmtCheckFlightDays = null;
                PreparedStatement pstmtGetCurrentSeatCount = null;
                PreparedStatement pstmtDecrementOldAircraftCount = null;
                PreparedStatement pstmtIncrementNewAircraftCount = null;
                PreparedStatement pstmtGetCommonUseOwn = null;
                PreparedStatement pstmtGetHandles = null;
                PreparedStatement pstmtGetOldAirlineID = null;
                
                try {
                    // Update query for aircrafts table
                    String updateAircraftQuery = "UPDATE aircrafts SET seat_count=?, available_days=? WHERE ac_id=?";
                    // Update query for owns table
                    String updateOwnsQuery = "UPDATE owns SET airline_id=? WHERE ac_id=?";
                    // Get old airline id to retrieve aircraft count
                    String getOldAirlineID = "SELECT airline_id FROM owns WHERE ac_id=?";
                    // Check query for conflicting flight days
                    String checkFlightDaysQuery = "SELECT uses.fid FROM uses " +
                            "JOIN departs ON uses.fid = departs.fid " +
                            "WHERE ac_id=? AND DAYNAME(d_datetime) NOT IN (" +
                            // Generate placeholders for the IN clause
                            String.join(",", Collections.nCopies(request.getParameterValues("available_days").length, "?")) +
                            ")";
                   	//	Get table similar to handles to prevent shift in aircraft ownership in case of ongoing flight
					String getCommonUsesQuery = "SELECT u.fid, o.airline_id " +
                            "FROM owns o " +
                            "INNER JOIN uses u ON o.ac_id = u.ac_id " +
                            "WHERE o.ac_id = ?";
					String getHandlesQuery = "SELECT * from handles WHERE airline_id=?";
                    // Get current seat count query
                    String getCurrentSeatCountQuery = "SELECT seat_count FROM aircrafts WHERE ac_id=?";
                    // Update query for decrementing old airline_count
                    String decrementOldAircraftCount = "UPDATE airline_companies SET aircraft_count = aircraft_count - 1 WHERE airline_id=?";
                    // Update query for incrementing new airline_count
                    String incrementNewAircraftCount = "UPDATE airline_companies SET aircraft_count = aircraft_count + 1 WHERE airline_id=?";

                    // Prepare statements
                    pstmtUpdateAircraft = con.prepareStatement(updateAircraftQuery);
                    pstmtUpdateOwns = con.prepareStatement(updateOwnsQuery);
                    pstmtCheckFlightDays = con.prepareStatement(checkFlightDaysQuery);
                    pstmtGetCurrentSeatCount = con.prepareStatement(getCurrentSeatCountQuery);
                    pstmtDecrementOldAircraftCount = con.prepareStatement(decrementOldAircraftCount);
                    pstmtIncrementNewAircraftCount = con.prepareStatement(incrementNewAircraftCount);
                    pstmtGetCommonUseOwn = con.prepareStatement(getCommonUsesQuery);
                    pstmtGetHandles = con.prepareStatement(getHandlesQuery);
                    pstmtGetOldAirlineID = con.prepareStatement(getOldAirlineID);
                    
                    // Retrieve parameters
                    int newSeatCount = Integer.parseInt(request.getParameter("seat_count"));
                    String airlineId = request.getParameter("airline_id");
                    String acId = request.getParameter("ac_id");
                    String[] availableDays = request.getParameterValues("available_days");

                    // Get current seat count and old airline_id
                    pstmtGetCurrentSeatCount.setString(1, acId);
                    pstmtGetOldAirlineID.setString(1, acId);
                    ResultSet currentSeatCountResult = pstmtGetCurrentSeatCount.executeQuery();
					ResultSet OldAirlineIDResult = pstmtGetOldAirlineID.executeQuery();
					
                    if (currentSeatCountResult.next() && OldAirlineIDResult.next()) {
                        int currentSeatCount = currentSeatCountResult.getInt("seat_count");
                        String oldAirlineId = OldAirlineIDResult.getString("airline_id");

                        // Check if the seat count is increased
                        if (newSeatCount >= currentSeatCount && newSeatCount >= 0) {
                            // Check for conflicting flight days
                            pstmtCheckFlightDays.setString(1, acId);
                            for (int i = 0; i < availableDays.length; i++) {
                                pstmtCheckFlightDays.setString(i + 2, availableDays[i]);
                            }
                            ResultSet conflictingFlights = pstmtCheckFlightDays.executeQuery();

                            if (conflictingFlights.next()) {
                                // Throw an error or handle the conflict as needed
                                throw new RuntimeException("Aircraft's available days conflict with departure dates of associated flights.");
                            }
                            
                            pstmtGetCommonUseOwn.setString(1, acId);
                            pstmtGetHandles.setString(1, airlineId);
							ResultSet commonUseOwnResults = pstmtGetCommonUseOwn.executeQuery();
							ResultSet handleResults = pstmtGetHandles.executeQuery();
							
							// Assuming both result sets have the same structure
							boolean hasCommonUse = commonUseOwnResults.next();
							boolean hasHandle = handleResults.next();

							if (hasCommonUse || hasHandle) {
							    throw new RuntimeException("Cannot change ownership of aircraft when in use by a flight.");
							}
							
                            try {
                                // Update aircrafts table
                                pstmtUpdateAircraft.setInt(1, newSeatCount);
                                pstmtUpdateAircraft.setString(2, String.join(",", availableDays));
                                pstmtUpdateAircraft.setString(3, acId);
                                pstmtUpdateAircraft.executeUpdate();

                                // Update owns table
                                pstmtUpdateOwns.setString(1, airlineId);
                                pstmtUpdateOwns.setString(2, acId);
                                pstmtUpdateOwns.executeUpdate();

                                // Decrement old airline_count
                                pstmtDecrementOldAircraftCount.setString(1, oldAirlineId);
                                pstmtDecrementOldAircraftCount.executeUpdate();

                                // Increment new airline_count
                                pstmtIncrementNewAircraftCount.setString(1, airlineId);
                                pstmtIncrementNewAircraftCount.executeUpdate();

                            } catch (SQLException e) {
                                throw e;
                            } 
                        } else {
                            throw new RuntimeException("Seat count can only be increased and must not be negative.");
                        }
                    } else {
                        throw new RuntimeException("Aircraft with ID " + acId + " not found.");
                    }
                } catch (SQLException e) {
                    e.printStackTrace(); 
                } finally {
                    try {
                        if (pstmtUpdateAircraft != null) {
                            pstmtUpdateAircraft.close();
                        }
                        if (pstmtUpdateOwns != null) {
                            pstmtUpdateOwns.close();
                        }
                        if (pstmtCheckFlightDays != null) {
                            pstmtCheckFlightDays.close();
                        }
                        if (pstmtGetCurrentSeatCount != null) {
                            pstmtGetCurrentSeatCount.close();
                        }
                        if (pstmtDecrementOldAircraftCount != null) {
                            pstmtDecrementOldAircraftCount.close();
                        }
                        if (pstmtIncrementNewAircraftCount != null) {
                            pstmtIncrementNewAircraftCount.close();
                        }
                        if (pstmtGetCommonUseOwn != null){
                        	pstmtGetCommonUseOwn.close();
                        }
                        if (pstmtGetHandles != null){
                        	pstmtGetHandles.close();
                        }
                        if (pstmtGetOldAirlineID != null){
                        	pstmtGetOldAirlineID.close();
                        }
                    } catch (SQLException e) {
                        e.printStackTrace(); 
                    }
                }
            } else if (deleteAircraft != null) {
                PreparedStatement pstmtCheckFlights = null;
                PreparedStatement pstmtDeleteOwns = null;
                PreparedStatement pstmtUpdateAircraftCount = null;
                PreparedStatement pstmtDeleteAircraft = null;

                try {
                    // Step 1: Check if there are associated flights
                    String checkFlightsQuery = "SELECT fid FROM uses WHERE ac_id=?";
                    pstmtCheckFlights = con.prepareStatement(checkFlightsQuery);
                    pstmtCheckFlights.setString(1, request.getParameter("ac_id"));
                    ResultSet flightsResultSet = pstmtCheckFlights.executeQuery();

                    if (flightsResultSet.next()) {
                        // There are associated flights, so prevent deletion and throw an exception
                        throw new RuntimeException("Cannot delete aircraft with associated flights.");
                    }

                    // Step 2: Delete records from owns table
                    String deleteOwnsQuery = "DELETE FROM owns WHERE airline_id=? AND ac_id=?";
                    pstmtDeleteOwns = con.prepareStatement(deleteOwnsQuery);
                    pstmtDeleteOwns.setString(1, request.getParameter("airline_id"));
                    pstmtDeleteOwns.setString(2, request.getParameter("ac_id"));
                    pstmtDeleteOwns.executeUpdate();

                    // Step 3: Update aircraft_count in airline_companies table
                    String updateAircraftCountQuery = "UPDATE airline_companies SET aircraft_count = aircraft_count - 1 WHERE airline_id=?";
                    pstmtUpdateAircraftCount = con.prepareStatement(updateAircraftCountQuery);
                    pstmtUpdateAircraftCount.setString(1, request.getParameter("airline_id"));
                    pstmtUpdateAircraftCount.executeUpdate();

                    // Step 4: Delete record from aircrafts table
                    String deleteAircraftQuery = "DELETE FROM aircrafts WHERE ac_id=?";
                    pstmtDeleteAircraft = con.prepareStatement(deleteAircraftQuery);
                    pstmtDeleteAircraft.setString(1, request.getParameter("ac_id"));
                    pstmtDeleteAircraft.executeUpdate();

                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (pstmtCheckFlights != null) {
                            pstmtCheckFlights.close();
                        }
                        if (pstmtDeleteOwns != null) {
                            pstmtDeleteOwns.close();
                        }
                        if (pstmtUpdateAircraftCount != null) {
                            pstmtUpdateAircraftCount.close();
                        }
                        if (pstmtDeleteAircraft != null) {
                            pstmtDeleteAircraft.close();
                        }
                    } catch (SQLException e) {
                        e.printStackTrace(); // Log the exception for debugging purposes
                    }
                }
            }


            	// Handle add, edit, delete for Airport
				if (addAirport != null) {
					// Handle add airport logic using PreparedStatement
					PreparedStatement pstmt = null;
					PreparedStatement pstmtOperates = null;
			
					try {
						String insertAirportQuery = "INSERT INTO airports (ap_id, airport_name) VALUES (?,?)";
						pstmt = con.prepareStatement(insertAirportQuery);
						pstmt.setString(1, request.getParameter("ap_id"));
						pstmt.setString(2, request.getParameter("airport_name"));
						pstmt.executeUpdate();
			
						// Handle operates logic to associate airlines with the new airport
						String insertOperatesQuery = "INSERT INTO operates (airline_id, ap_id) VALUES (?,?)";
						pstmtOperates = con.prepareStatement(insertOperatesQuery);
			
						String[] selectedAirlines = request.getParameterValues("airline_id");
			
						if (selectedAirlines != null && selectedAirlines.length > 0) {
							for (String airlineId : selectedAirlines) {
								pstmtOperates.setString(1, airlineId);
								pstmtOperates.setString(2, request.getParameter("ap_id"));
								pstmtOperates.executeUpdate();
							}
								}
							} finally {
								if (pstmtOperates != null) {
							pstmtOperates.close();
								}
								if (pstmt != null) {
							pstmt.close();
								}
							} 
				}	else if (editAirport != null) {
				    // Handle edit airport logic using PreparedStatement
				    PreparedStatement pstmtUpdateAirport = null;
				    PreparedStatement pstmtOperatesDelete = null;
				    PreparedStatement pstmtOperatesInsert = null;

				    try {
				        // Step 1: Update airport information
				        String updateAirportQuery = "UPDATE airports SET airport_name=? WHERE ap_id=?";
				        pstmtUpdateAirport = con.prepareStatement(updateAirportQuery);
				        pstmtUpdateAirport.setString(1, request.getParameter("airport_name"));
				        pstmtUpdateAirport.setString(2, request.getParameter("ap_id"));
				        pstmtUpdateAirport.executeUpdate();

				        // Step 2: Check if the added airlines have handles for ongoing flights (departures and arrivals)
				        String checkHandlesQuery = "SELECT DISTINCT h.fid " +
				                                   "FROM handles h " +
				                                   "JOIN (departs d JOIN arrives a ON d.fid = a.fid) ON h.fid = d.fid " +
				                                   "WHERE d.ap_id=? OR a.ap_id=?";
				        PreparedStatement pstmtCheckHandles = con.prepareStatement(checkHandlesQuery);
				        pstmtCheckHandles.setString(1, request.getParameter("ap_id"));
				        pstmtCheckHandles.setString(2, request.getParameter("ap_id"));
				        ResultSet handlesResultSet = pstmtCheckHandles.executeQuery();

				        if (handlesResultSet.next()) {
				            // There are ongoing flights with handles, throw an error
				            throw new RuntimeException("Cannot edit airport: Airlines have handles for ongoing flights.");
				        }

				        // Step 3: Delete existing associations in operates
				        String deleteOperatesQuery = "DELETE FROM operates WHERE ap_id=?";
				        pstmtOperatesDelete = con.prepareStatement(deleteOperatesQuery);
				        pstmtOperatesDelete.setString(1, request.getParameter("ap_id"));
				        pstmtOperatesDelete.executeUpdate();

				        // Step 4: Insert new associations in operates
				        String insertOperatesQuery = "INSERT INTO operates (airline_id, ap_id) VALUES (?,?)";
				        pstmtOperatesInsert = con.prepareStatement(insertOperatesQuery);

				        String[] selectedAirlines = request.getParameterValues("airline_id");

				        if (selectedAirlines != null && selectedAirlines.length > 0) {
				            // Insert new associations in operates
				            for (String airlineId : selectedAirlines) {
				                pstmtOperatesInsert.setString(1, airlineId);
				                pstmtOperatesInsert.setString(2, request.getParameter("ap_id"));
				                pstmtOperatesInsert.executeUpdate();
				            }
				        }
				    } catch (SQLException e) {
				        // Handle the exception, log the error, or throw a custom exception
				        e.printStackTrace();
				    } finally {
				        // Close the prepared statements in a finally block
				        try {
				            if (pstmtUpdateAirport != null) {
				                pstmtUpdateAirport.close();
				            }
				            if (pstmtOperatesInsert != null) {
				                pstmtOperatesInsert.close();
				            }
				            if (pstmtOperatesDelete != null) {
				                pstmtOperatesDelete.close();
				            }
				        } catch (SQLException e) {
				            e.printStackTrace(); // Log the exception for debugging purposes
				        }
				    }
				} else if (deleteAirport != null) {
				    // Handle delete airport logic using PreparedStatement
				    PreparedStatement pstmtOperates = null;
				    PreparedStatement pstmtHandles = null;
				    PreparedStatement pstmtUses = null;
				    PreparedStatement pstmtDeparts = null;
				    PreparedStatement pstmtArrives = null;
				    PreparedStatement pstmtDeleteFlights = null;
				    PreparedStatement pstmt = null;

				    try {
				        String captureFlightIdsQuery = "SELECT fid FROM departs WHERE ap_id=? OR fid IN (SELECT fid FROM arrives WHERE ap_id=?)";
				        String deleteOperatesQuery = "DELETE FROM operates WHERE ap_id=?";
				        String deleteHandlesQuery = "DELETE FROM handles WHERE fid=?";
				        String deleteUsesQuery = "DELETE FROM uses WHERE fid=?";
				        String deleteDepartsQuery = "DELETE FROM departs WHERE fid=?";
				        String deleteArrivesQuery = "DELETE FROM arrives WHERE fid=?";
				        String deleteFlightsQuery = "DELETE FROM flights WHERE fid=?";
				        String deleteAirportQuery = "DELETE FROM airports WHERE ap_id=?";

				        // Capture flight IDs before deleting from departs and arrives
				        List<String> flightIdsToDelete = new ArrayList<String>();
				        pstmtDeleteFlights = con.prepareStatement(captureFlightIdsQuery);
				        pstmtDeleteFlights.setString(1, request.getParameter("ap_id"));
				        pstmtDeleteFlights.setString(2, request.getParameter("ap_id"));
				        ResultSet flightIdsResultSet = pstmtDeleteFlights.executeQuery();
				        while (flightIdsResultSet.next()) {
				            flightIdsToDelete.add(flightIdsResultSet.getString("fid"));
				        }

				        pstmtOperates = con.prepareStatement(deleteOperatesQuery);
				        pstmtHandles = con.prepareStatement(deleteHandlesQuery);
				        pstmtUses = con.prepareStatement(deleteUsesQuery);
				        pstmtDeparts = con.prepareStatement(deleteDepartsQuery);
				        pstmtArrives = con.prepareStatement(deleteArrivesQuery);
				        pstmtDeleteFlights = con.prepareStatement(deleteFlightsQuery);
				        pstmt = con.prepareStatement(deleteAirportQuery);

				        pstmtOperates.setString(1, request.getParameter("ap_id"));
				        pstmtHandles.setString(1, request.getParameter("ap_id"));
				        pstmtUses.setString(1, request.getParameter("ap_id"));

				        // Delete from operates table
				        pstmtOperates.executeUpdate();

				        // Delete from handles and uses tables
				        for (String fid : flightIdsToDelete) {
				            pstmtHandles.setString(1, fid);
				            pstmtHandles.executeUpdate();

				            pstmtUses.setString(1, fid);
				            pstmtUses.executeUpdate();
				            
					        // Delete from departs and arrives tables
					        pstmtDeparts.setString(1, fid);
					        pstmtDeparts.executeUpdate();

				        	pstmtArrives.setString(1, fid);
					        pstmtArrives.executeUpdate();
				        }

				        // Delete associated flights
				        for (String fid : flightIdsToDelete) {
				            pstmtDeleteFlights.setString(1, fid);
				            pstmtDeleteFlights.executeUpdate();
				        }

				        // Delete from airports table
				        pstmt.setString(1, request.getParameter("ap_id"));
				        pstmt.executeUpdate();
				    } finally {
			            if (pstmtOperates != null) {
			                pstmtOperates.close();
			            }
			            if (pstmtHandles != null) {
			                pstmtHandles.close();
			            }
			            if (pstmtUses != null) {
			                pstmtUses.close();
			            }
			            if (pstmtDeparts != null) {
			                pstmtDeparts.close();
			            }
			            if (pstmtArrives != null) {
			                pstmtArrives.close();
			            }
			            if (pstmtDeleteFlights != null) {
			                pstmtDeleteFlights.close();
			            }
			            if (pstmt != null) {
			                pstmt.close();
			            }
				    }
				}

			
            // Handle add, edit, delete for Flight
			if (addFlight != null) {
			    // Handle add flight logic using PreparedStatement
			    PreparedStatement pstmt = null;
			    try {
			    	// Check for conflicting flights using the same aircraft
			    	String checkConflictingFlightsQuery = "SELECT f.fid " +
			    	        "FROM uses u " +
			    	        "JOIN flights f ON u.fid = f.fid " +
			    	        "JOIN departs d1 ON f.fid = d1.fid " +
			    	        "JOIN arrives d2 ON f.fid = d2.fid " +
			    	        "WHERE u.ac_id = ? " +
			    	        "AND ((? BETWEEN d1.d_datetime AND d2.a_datetime) OR (? BETWEEN d1.d_datetime AND d2.a_datetime)) " +
			    	        "AND f.fid != ?";
			    	PreparedStatement checkConflictingFlightsStmt = con.prepareStatement(checkConflictingFlightsQuery);
			    	checkConflictingFlightsStmt.setString(1, request.getParameter("ac_id"));
			    	checkConflictingFlightsStmt.setString(2, request.getParameter("d_datetime"));
			    	checkConflictingFlightsStmt.setString(3, request.getParameter("a_datetime"));
			    	checkConflictingFlightsStmt.setString(4, request.getParameter("fid"));

			    	ResultSet conflictingFlightsResultSet = checkConflictingFlightsStmt.executeQuery();

			    	if (conflictingFlightsResultSet.next()) {
			    	    // Throw an error or handle the conflict as needed
			    	    throw new IllegalStateException("Aircraft is already scheduled for another flight during this time period.");
			    	}
			        // Check if departure airport is in operates
			        PreparedStatement operatesCheckDepartureStmt = con.prepareStatement(
			            "SELECT * FROM operates WHERE ap_id = ? AND airline_id = ?"
			        );
			        operatesCheckDepartureStmt.setString(1, request.getParameter("ap_id"));
			        String departureAirport = request.getParameter("ap_id");
			        operatesCheckDepartureStmt.setString(2, request.getParameter("airline_id"));
			        ResultSet operatesDepartureResultSet = operatesCheckDepartureStmt.executeQuery();

			        // Check if arrival airport is in operates
			        PreparedStatement operatesCheckArrivalStmt = con.prepareStatement(
			            "SELECT * FROM operates WHERE ap_id = ? AND airline_id = ?"
			        );
			        operatesCheckArrivalStmt.setString(1, request.getParameter("ap_id2"));
			        String arrivalAirport = request.getParameter("ap_id2");
			        operatesCheckArrivalStmt.setString(2, request.getParameter("airline_id"));
			        ResultSet operatesArrivalResultSet = operatesCheckArrivalStmt.executeQuery();

			        // Check if aircraft and airline are in owns
			        PreparedStatement ownsCheckStmt = con.prepareStatement(
			            "SELECT * FROM owns WHERE airline_id = ? AND ac_id = ?"
			        );
			        ownsCheckStmt.setString(1, request.getParameter("airline_id"));
			        ownsCheckStmt.setString(2, request.getParameter("ac_id"));
			        ResultSet ownsResultSet = ownsCheckStmt.executeQuery();

			        // Verify additional criteria: departure datetime before arrival datetime
			        LocalDateTime departureDateTime = LocalDateTime.parse(request.getParameter("d_datetime"));
			        LocalDateTime arrivalDateTime = LocalDateTime.parse(request.getParameter("a_datetime"));
			        
			        if (!departureAirport.equals(arrivalAirport) &&
			        	operatesDepartureResultSet.next() &&
			            operatesArrivalResultSet.next() &&
			            ownsResultSet.next() &&
			            departureDateTime.isBefore(arrivalDateTime)) {

			            // Verify that the aircraft is available on the departure day
			            String availabilityCheckQuery = "SELECT * FROM aircrafts WHERE ac_id = ? AND FIND_IN_SET(?, available_days) > 0";
			            
			            PreparedStatement availabilityCheckStmt = null;
			            try {
			                availabilityCheckStmt = con.prepareStatement(availabilityCheckQuery);
			                availabilityCheckStmt.setString(1, request.getParameter("ac_id"));
			                availabilityCheckStmt.setString(2, departureDateTime.getDayOfWeek().name());
			                ResultSet availabilityCheckResultSet = availabilityCheckStmt.executeQuery();

			                if (availabilityCheckResultSet.next()) {
			                    // Proceed with the insertion into flights, departs, uses, arrives, and handles tables
			                    String insertFlightQuery = "INSERT INTO flights (fid, isInternational) VALUES (?, ?)";
			                    String departsInsertQuery = "INSERT INTO departs (fid, ap_id, d_datetime) VALUES (?, ?, ?)";
			                    String arrivesInsertQuery = "INSERT INTO arrives (fid, ap_id, a_datetime) VALUES (?, ?, ?)";
			                    String handlesInsertQuery = "INSERT INTO handles (fid, airline_id) VALUES (?, ?)";
			                    String usesInsertQuery = "INSERT INTO uses (fid, ac_id) VALUES (?, ?)";

			                    pstmt = con.prepareStatement(insertFlightQuery);
			                    pstmt.setString(1, request.getParameter("fid"));
			                    pstmt.setBoolean(2, Boolean.parseBoolean(request.getParameter("isInternational")));
			                    pstmt.executeUpdate();

			                    // Continue with the insertion into departs, arrives, and handles tables
			                    pstmt = con.prepareStatement(departsInsertQuery);
			                    pstmt.setString(1, request.getParameter("fid"));
			                    pstmt.setString(2, request.getParameter("ap_id"));
			                    pstmt.setString(3, request.getParameter("d_datetime"));
			                    pstmt.executeUpdate();

			                    pstmt = con.prepareStatement(arrivesInsertQuery);
			                    pstmt.setString(1, request.getParameter("fid"));
			                    pstmt.setString(2, request.getParameter("ap_id2"));
			                    pstmt.setString(3, request.getParameter("a_datetime"));
			                    pstmt.executeUpdate();

			                    pstmt = con.prepareStatement(handlesInsertQuery);
			                    pstmt.setString(1, request.getParameter("fid"));
			                    pstmt.setString(2, request.getParameter("airline_id"));
			                    pstmt.executeUpdate();
			                    
			                    pstmt = con.prepareStatement(usesInsertQuery);
			                    pstmt.setString(1, request.getParameter("fid"));
			                    pstmt.setString(2, request.getParameter("ac_id"));
			                    pstmt.executeUpdate();
			                } else {
			                    // Reject the query as the aircraft is not available on the departure day
			                    throw new IllegalStateException("Aircraft is not available on the departure day.");
			                }
			            } finally {
			                // Close resources in the finally block
			                if (availabilityCheckStmt != null) {
			                    availabilityCheckStmt.close();
			                }
			            }
			        } else {
			            // Reject the query, as conditions are not met
			            throw new IllegalStateException("Cannot add flight. Check operates and owns conditions.");
			        }
			    } finally {
			        // Close resources in the finally block
			        if (pstmt != null) {
			            pstmt.close();
			        }
			    }
				} else if (editFlight != null) {
				    // Handle edit flight logic using PreparedStatement
				    PreparedStatement pstmt = null;
				    try {
				    	// Check for conflicting flights using the same aircraft
				    	String checkConflictingFlightsQuery = "SELECT f.fid " +
				    	        "FROM uses u " +
				    	        "JOIN flights f ON u.fid = f.fid " +
				    	        "JOIN departs d1 ON f.fid = d1.fid " +
				    	        "JOIN arrives d2 ON f.fid = d2.fid " +
				    	        "WHERE u.ac_id = ? " +
				    	        "AND ((? BETWEEN d1.d_datetime AND d2.a_datetime) OR (? BETWEEN d1.d_datetime AND d2.a_datetime)) " +
				    	        "AND f.fid != ?";
				    	PreparedStatement checkConflictingFlightsStmt = con.prepareStatement(checkConflictingFlightsQuery);
				    	checkConflictingFlightsStmt.setString(1, request.getParameter("ac_id"));
				    	checkConflictingFlightsStmt.setString(2, request.getParameter("d_datetime"));
				    	checkConflictingFlightsStmt.setString(3, request.getParameter("a_datetime"));
				    	checkConflictingFlightsStmt.setString(4, request.getParameter("fid"));

				    	ResultSet conflictingFlightsResultSet = checkConflictingFlightsStmt.executeQuery();

				    	if (conflictingFlightsResultSet.next()) {
				    	    // Throw an error or handle the conflict as needed
				    	    throw new IllegalStateException("Aircraft is already scheduled for another flight during this time period.");
				    	}
				        // Check if departure airport is in operates
				        PreparedStatement operatesCheckDepartureStmt = con.prepareStatement(
				            "SELECT * FROM operates WHERE ap_id = ? AND airline_id = ?"
				        );
				        operatesCheckDepartureStmt.setString(1, request.getParameter("ap_id"));
				        String departureAirport = request.getParameter("ap_id");
				        operatesCheckDepartureStmt.setString(2, request.getParameter("airline_id"));
				        ResultSet operatesDepartureResultSet = operatesCheckDepartureStmt.executeQuery();
	
				        // Check if arrival airport is in operates
				        PreparedStatement operatesCheckArrivalStmt = con.prepareStatement(
				            "SELECT * FROM operates WHERE ap_id = ? AND airline_id = ?"
				        );
				        operatesCheckArrivalStmt.setString(1, request.getParameter("ap_id2"));
				        String arrivalAirport = request.getParameter("ap_id2");
				        operatesCheckArrivalStmt.setString(2, request.getParameter("airline_id"));
				        ResultSet operatesArrivalResultSet = operatesCheckArrivalStmt.executeQuery();
	
				        // Check if aircraft and airline are in owns
				        PreparedStatement ownsCheckStmt = con.prepareStatement(
				            "SELECT * FROM owns WHERE airline_id = ? AND ac_id = ?"
				        );
				        ownsCheckStmt.setString(1, request.getParameter("airline_id"));
				        ownsCheckStmt.setString(2, request.getParameter("ac_id"));
				        ResultSet ownsResultSet = ownsCheckStmt.executeQuery();
	
				        // Verify additional criteria: departure datetime before arrival datetime
				        LocalDateTime departureDateTime = LocalDateTime.parse(request.getParameter("d_datetime"));
				        LocalDateTime arrivalDateTime = LocalDateTime.parse(request.getParameter("a_datetime"));
	
				        if (!departureAirport.equals(arrivalAirport) &&
				            operatesDepartureResultSet.next() &&
				            operatesArrivalResultSet.next() &&
				            ownsResultSet.next() &&
				            departureDateTime.isBefore(arrivalDateTime)) {
	
				            // Verify that the aircraft is available on the departure day
				            String availabilityCheckQuery = "SELECT * FROM aircrafts WHERE ac_id = ? AND FIND_IN_SET(?, available_days) > 0";
	
				            PreparedStatement availabilityCheckStmt = null;
				            try {
				                availabilityCheckStmt = con.prepareStatement(availabilityCheckQuery);
				                availabilityCheckStmt.setString(1, request.getParameter("ac_id"));
				                availabilityCheckStmt.setString(2, departureDateTime.getDayOfWeek().name());
				                ResultSet availabilityCheckResultSet = availabilityCheckStmt.executeQuery();
	
				                if (availabilityCheckResultSet.next()) {
				                    // Proceed with the update in flights, departs, arrives, uses and handles tables
				                    String updateFlightQuery = "UPDATE flights SET isInternational=? WHERE fid=?";
				                    String departsUpdateQuery = "UPDATE departs SET ap_id=?, d_datetime=? WHERE fid=?";
				                    String arrivesUpdateQuery = "UPDATE arrives SET ap_id=?, a_datetime=? WHERE fid=?";
				                    String handlesUpdateQuery = "UPDATE handles SET airline_id=? WHERE fid=?";
				                    String usesUpdateQuery = "UPDATE uses SET ac_id=? WHERE fid=?";
	
				                    pstmt = con.prepareStatement(updateFlightQuery);
				                    pstmt.setBoolean(1, Boolean.parseBoolean(request.getParameter("isInternational")));
				                    pstmt.setString(2, request.getParameter("fid"));
				                    pstmt.executeUpdate();
	
				                    // Continue with the update in departs, arrives, and handles tables
				                    pstmt = con.prepareStatement(departsUpdateQuery);
				                    pstmt.setString(1, request.getParameter("ap_id"));
				                    pstmt.setString(2, request.getParameter("d_datetime"));
				                    pstmt.setString(3, request.getParameter("fid"));
				                    pstmt.executeUpdate();
	
				                    pstmt = con.prepareStatement(arrivesUpdateQuery);
				                    pstmt.setString(1, request.getParameter("ap_id2"));
				                    pstmt.setString(2, request.getParameter("a_datetime"));
				                    pstmt.setString(3, request.getParameter("fid"));
				                    pstmt.executeUpdate();
	
				                    pstmt = con.prepareStatement(handlesUpdateQuery);
				                    pstmt.setString(1, request.getParameter("airline_id"));
				                    pstmt.setString(2, request.getParameter("fid"));
				                    pstmt.executeUpdate();
				                    
				                    pstmt = con.prepareStatement(usesUpdateQuery);
				                    pstmt.setString(1, request.getParameter("ac_id"));
				                    pstmt.setString(2, request.getParameter("fid"));
				                    pstmt.executeUpdate();
				                } else {
				                    // Reject the query as the aircraft is not available on the departure day
				                    throw new IllegalStateException("Aircraft is not available on the departure day.");
				                }
				            } finally {
				                // Close resources in the finally block
				                if (availabilityCheckStmt != null) {
				                    availabilityCheckStmt.close();
				                }
				            }
				        } else {
				            // Reject the query, as conditions are not met
				            throw new IllegalStateException("Cannot edit flight. Check operates and owns conditions.");
				        }
				    } finally {
				        // Close resources in the finally block
				        if (pstmt != null) {
				            pstmt.close();
				        }
				    }
				} else if (deleteFlight != null) {
				    // Handle delete flight logic using PreparedStatement
				    PreparedStatement pstmt = null;
				    ResultSet confirmationResultSet = null;

				    try {
				        // Confirm conditions before deletion
				        String confirmDepartArrivalDatesQuery = "SELECT * FROM flights WHERE fid=? AND d_datetime=? AND a_datetime=?";
				        String confirmHandlesQuery = "SELECT * FROM handles WHERE fid=? AND airline_id=?";
				        String confirmUsesQuery = "SELECT * FROM uses WHERE fid=? AND ac_id=?";

				        // Confirm departure and arrival dates
				        pstmt = con.prepareStatement(confirmDepartArrivalDatesQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("d_datetime"));
				        pstmt.setString(3, request.getParameter("a_datetime"));
				        confirmationResultSet = pstmt.executeQuery();

				        if (!confirmationResultSet.next()) {
				            throw new IllegalStateException("Departure and arrival dates do not match the current flight details.");
				        }

				        // Confirm handles
				        pstmt = con.prepareStatement(confirmHandlesQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("airline_id"));
				        confirmationResultSet = pstmt.executeQuery();

				        if (!confirmationResultSet.next()) {
				            throw new IllegalStateException("Airline handling the flight does not match the current details.");
				        }

				        // Confirm uses
				        pstmt = con.prepareStatement(confirmUsesQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("ac_id"));
				        confirmationResultSet = pstmt.executeQuery();

				        if (!confirmationResultSet.next()) {
				            throw new IllegalStateException("Aircraft used in the flight does not match the current details.");
				        }

				        // If all confirmations pass, proceed with deletion
				        String deleteDepartsQuery = "DELETE FROM departs WHERE fid=? AND d_datetime=?";
				        String deleteArrivesQuery = "DELETE FROM arrives WHERE fid=? AND a_datetime=?";
				        String deleteHandlesQuery = "DELETE FROM handles WHERE fid=? AND airline_id=?";
				        String deleteUsesQuery = "DELETE FROM uses WHERE fid=? AND ac_id=?";
				        String deleteFlightQuery = "DELETE FROM flights WHERE fid=?";

				        // Delete from departs
				        pstmt = con.prepareStatement(deleteDepartsQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("d_datetime"));
				        pstmt.executeUpdate();

				        // Delete from arrives
				        pstmt = con.prepareStatement(deleteArrivesQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("a_datetime"));
				        pstmt.executeUpdate();

				        // Delete from handles
				        pstmt = con.prepareStatement(deleteHandlesQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("airline_id"));
				        pstmt.executeUpdate();

				        // Delete from uses
				        pstmt = con.prepareStatement(deleteUsesQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.setString(2, request.getParameter("ac_id"));
				        pstmt.executeUpdate();

				        // Delete from flights
				        pstmt = con.prepareStatement(deleteFlightQuery);
				        pstmt.setString(1, request.getParameter("fid"));
				        pstmt.executeUpdate();
				    } finally {
				        // Close resources in the finally block
				        try {
				            if (confirmationResultSet != null) {
				                confirmationResultSet.close();
				            }
				            if (pstmt != null) {
				                pstmt.close();
				            }
				        } catch (SQLException e) {
				            e.printStackTrace();
				        }
				    }
				}

			// Retrieve and display aircraft table
			String aircraftSet = "SELECT * FROM aircrafts";
			ResultSet aircraftResults = stmt1.executeQuery(aircraftSet);

			// Retrieve and display airport table
			String airportSet = "SELECT * FROM airports";
			ResultSet airportResults = stmt2.executeQuery(airportSet);

			// Retrieve and display flight table
			String flightSet = "SELECT * FROM flights";
			ResultSet flightResults = stmt3.executeQuery(flightSet);

			// Retrieve and display owns table
			String ownsSet = "SELECT * FROM owns";
			ResultSet ownsResults = stmt4.executeQuery(ownsSet);
	%>

	<h2>Aircraft Table</h2>
	<table border="1">
		<tr>
			<th>Aircraft ID</th>
			<th>Seat Count</th>
			<th>Available Days</th>
			<th>Airline Owner</th>
		</tr>
		<%
		while (aircraftResults.next() && ownsResults.next()) {
		%>
		<tr>
			<td><%=aircraftResults.getString("ac_id")%></td>
			<td><%=aircraftResults.getInt("seat_count")%></td>
			<td><%=aircraftResults.getString("available_days")%></td>
			<td><%=ownsResults.getString("airline_id")%></td>
		</tr>
		<%
		}
		%>
	</table>

	<h2>Airport Table</h2>
	<table border="1">
		<tr>
			<th>Airport ID</th>
			<th>Airport Name</th>
			<th>Airlines</th>
		</tr>
		<%
		while (airportResults.next()) {
			String airportId = airportResults.getString("ap_id");
			String airportName = airportResults.getString("airport_name");

			// Retrieve associated airlines for the current airport
			String getAirlinesQuery = "SELECT airline_id FROM operates WHERE ap_id=?";
			PreparedStatement pstmtGetAirlines = null;
			ResultSet airlinesForAirport = null;

			try {
				pstmtGetAirlines = con.prepareStatement(getAirlinesQuery);
				pstmtGetAirlines.setString(1, airportId);
				airlinesForAirport = pstmtGetAirlines.executeQuery();

				StringBuilder airlinesStringBuilder = new StringBuilder();
				while (airlinesForAirport.next()) {
			airlinesStringBuilder.append(airlinesForAirport.getString("airline_id")).append(", ");
				}

				String associatedAirlines = airlinesStringBuilder.length() > 0
				? airlinesStringBuilder.substring(0, airlinesStringBuilder.length() - 2)
				: "";
		%>
		<tr>
			<td><%=airportId%></td>
			<td><%=airportName%></td>
			<td><%=associatedAirlines%></td>
		</tr>
		<%
		} finally {
		// Close resources in the finally block
		if (airlinesForAirport != null) {
			airlinesForAirport.close();
		}
		if (pstmtGetAirlines != null) {
			pstmtGetAirlines.close();
		}
		}
		}
		%>
	</table>


	<h2>Flight Table</h2>
	<table border="1">
		<tr>
			<th>Flight ID</th>
			<th>Status</th>
			<th>Departure Airport</th>
			<th>Departure Time</th>
			<th>Arrival Airport</th>
			<th>Arrival Time</th>
			<th>Airline</th>
		</tr>
		<%
		while (flightResults.next()) {
			String fid = flightResults.getString("fid");
			boolean isInternational = flightResults.getBoolean("isInternational");

			// Retrieve departure information for the current flight
			String getDepartsInfoQuery = "SELECT ap_id, d_datetime FROM departs WHERE fid=?";
			PreparedStatement pstmtDepartsInfo = null;
			ResultSet departsInfo = null;

			// Retrieve arrival information for the current flight
			String getArrivesInfoQuery = "SELECT ap_id, a_datetime FROM arrives WHERE fid=?";
			PreparedStatement pstmtArrivesInfo = null;
			ResultSet arrivesInfo = null;

			// Retrieve airline information for the current flight
			String getHandlesInfoQuery = "SELECT airline_id FROM handles WHERE fid=?";
			PreparedStatement pstmtHandlesInfo = null;
			ResultSet handlesInfo = null;

			try {
				// Retrieve departure information
				pstmtDepartsInfo = con.prepareStatement(getDepartsInfoQuery);
				pstmtDepartsInfo.setString(1, fid);
				departsInfo = pstmtDepartsInfo.executeQuery();

				String departureAirport = "";
				String departureTime = "";

				if (departsInfo.next()) {
					departureAirport = departsInfo.getString("ap_id");
					departureTime = departsInfo.getString("d_datetime");
				}

				// Retrieve arrival information
				pstmtArrivesInfo = con.prepareStatement(getArrivesInfoQuery);
				pstmtArrivesInfo.setString(1, fid);
				arrivesInfo = pstmtArrivesInfo.executeQuery();

				String arrivalAirport = "";
				String arrivalTime = "";

				if (arrivesInfo.next()) {
			arrivalAirport = arrivesInfo.getString("ap_id");
			arrivalTime = arrivesInfo.getString("a_datetime");
				}

				// Retrieve airline information
				pstmtHandlesInfo = con.prepareStatement(getHandlesInfoQuery);
				pstmtHandlesInfo.setString(1, fid);
				handlesInfo = pstmtHandlesInfo.executeQuery();

				String airlineId = "";

				if (handlesInfo.next()) {
					airlineId = handlesInfo.getString("airline_id");
				}
		%>
		<tr>
			<td><%=fid%></td>
			<td><%=isInternational ? "International" : "Domestic"%></td>
			<td><%=departureAirport%></td>
			<td><%=departureTime%></td>
			<td><%=arrivalAirport%></td>
			<td><%=arrivalTime%></td>
			<td><%=airlineId%></td>
		</tr>
		<%
		} finally {
		// Close resources in the finally block
		if (departsInfo != null) {
			departsInfo.close();
		}
		if (pstmtDepartsInfo != null) {
			pstmtDepartsInfo.close();
		}
		if (arrivesInfo != null) {
			arrivesInfo.close();
		}
		if (pstmtArrivesInfo != null) {
			pstmtArrivesInfo.close();
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
	} finally {
	// Close database connections and statements
	if (stmt4 != null) {
		stmt4.close();
	}
	if (stmt3 != null) {
		stmt3.close();
	}
	if (stmt2 != null) {
		stmt2.close();
	}
	if (stmt1 != null) {
		stmt1.close();
	}
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

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.RequestDispatcher"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
   String repAction = request.getParameter("repAction");

   if (repAction != null) {
       String forwardPage = null;

       if ("1".equals(repAction)) {
           forwardPage = "rep_bookReservations.jsp";
       } else if ("2".equals(repAction)) {
           forwardPage = "rep_editReservations.jsp";
       } else if ("3".equals(repAction)) {
           forwardPage = "rep_answerQuestions.jsp";
       } else if ("4".equals(repAction)) {
           forwardPage = "rep_airManagement.jsp";
       } else if ("5".equals(repAction)) {
           forwardPage = "rep_waitlistDirectory.jsp";
       } else if ("6".equals(repAction)) {
           forwardPage = "rep_flightAD_Directory.jsp";
       } else {
           forwardPage = "error_page.jsp";
       }

       if (forwardPage != null) {
           RequestDispatcher dispatcher = request.getRequestDispatcher(forwardPage);
           dispatcher.forward(request, response);
       } else {
           // Handle the case where no radio button is selected
           response.sendRedirect("error_page.jsp");
       }
   } else {
       // Handle the case where no radio button is selected
       response.sendRedirect("error_page.jsp");
   }
%>

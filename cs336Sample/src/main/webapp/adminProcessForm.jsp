<%@ page language="java" contentType="text/html; charset=ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.RequestDispatcher"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
   String adminAction = request.getParameter("adminAction");

   if (adminAction != null) {
       String forwardPage = null;

       if ("1".equals(adminAction)) {
           forwardPage = "admin_management.jsp";
       } else if ("2".equals(adminAction)) {
           forwardPage = "monthly_sales_form.jsp";
       } else if ("3".equals(adminAction)) {
           forwardPage = "reservation_list_form.jsp";
       } else if ("4".equals(adminAction)) {
           forwardPage = "revenue_logs_form.jsp";
       } else if ("5".equals(adminAction)) {
           forwardPage = "mvp_customer_form.jsp";
       } else if ("6".equals(adminAction)) {
           forwardPage = "most_active_flights_form.jsp";
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

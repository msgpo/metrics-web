/* Copyright 2011--2014 The Tor Project
 * See LICENSE for licensing information */
package org.torproject.metrics.web.status;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ConsensusHealthServlet extends HttpServlet {

  private static final long serialVersionUID = 8349991221914797433L;

  public void doGet(HttpServletRequest request,
      HttpServletResponse response) throws IOException, ServletException {

    /* Forward the request to the JSP that does all the hard work. */
    request.getRequestDispatcher("WEB-INF/consensus-health.jsp").forward(
        request, response);
  }
}


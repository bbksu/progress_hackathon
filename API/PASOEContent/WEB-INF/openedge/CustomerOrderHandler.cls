 
 /*------------------------------------------------------------------------
    File        : CustomerOrderHandler
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : temp
    Created     : Sat Oct 24 22:00:55 CAT 2026
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING OpenEdge.Web.IWebRequest.
USING Progress.Json.ObjectModel.JsonObject.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS CustomerOrderHandler INHERITS WebHandler: 

	
		
	/*------------------------------------------------------------------------------
            Purpose: Handler for unsupported methods. The request being serviced and
            		 an optional status code is returned. A zero or null value means 
            		 this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
	METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
	
		/* Throwing an error from this method results in a 500/Internal Server Error response. 
        The web handler will attempt to log this exception.
 	    
        See the HandleGet method's comments on choosing a value to return from this method. */
        	
		UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
	END METHOD.


	/*------------------------------------------------------------------------------
            Purpose: Handler for unknown methods. The request being serviced and an 
                     optional status code is returned. A zero or null value means 
                     this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
	METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
	
		/* Throwing an error from this method results in a 500/Internal Server Error response. 
        The web handler will attempt to log this exception.
 	    
        See the HandleGet method's comments on choosing a value to return from this method. */	
		UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
   	END METHOD.
 	
	
	/*------------------------------------------------------------------------------
            Purpose: Default handler for the HTTP GET method. The request being 
                     serviced and an optional status code is returned. A zero or 
                     null value means this method will deal with all errors.                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
 	METHOD OVERRIDE PROTECTED INTEGER HandleGet( INPUT poRequest AS IWebRequest ):
 	
	
		DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
        DEFINE VARIABLE getorderID AS CHARACTER NO-UNDO.        
                  
         DEFINE VARIABLE cOrderID AS CHARACTER  NO-UNDO.
         DEFINE VARIABLE iOrderID AS INTEGER    NO-UNDO.
         DEFINE VARIABLE oJson    AS JsonObject NO-UNDO.      
         
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
         oJson = NEW JsonObject().
         getorderID = poRequest:GetPathParameter("OrderID").
         
         FIND FIRST inventory.CustomerOrder 
         WHERE inventory.CustomerOrder.OrderID = getorderID 
         NO-LOCK NO-ERROR.
         IF AVAILABLE inventory.CustomerOrder THEN
         DO:
             oJson:Add(
                 "OrderID",
                 inventory.CustomerOrder.OrderID
                 ).

             oJson:Add(
                 "LocationID",
                 inventory.CustomerOrder.LocationID
                 ).

             oJson:Add(
                 "Status",
                 inventory.CustomerOrder.OrderStatus
                 ).

             oJson:Add(
                 "CreatedAt",
                 STRING(inventory.CustomerOrder.CreatedAt)
                 ).
         END.
         oResponse:StatusCode = 200.
         oResponse:ContentType = "application/json".
         oResponse:Entity = oJson.
        
        /* The WebResponseWriter ensures that the status line and
           all headers are writted out before the message body/entity. */
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        
        /* Finish writing the response message */
        oWriter:Close().
        
        /* A response of 0 means that this handler will build the entire response;
           a non-zero value is mapped to a static handler in the webapp's /static/error folder.
           The mappings are maintained in the webapps's WEB-INF/web.xml 
           A predefined set of HTTP status codes is provided in the OpenEdge.Net.HTTP.StatusCodeEnum 
           enumeration */
        RETURN 0.
		
 	END METHOD. 
 	
 	
   	
	
END CLASS.
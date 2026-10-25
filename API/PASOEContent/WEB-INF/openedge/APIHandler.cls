 
/*------------------------------------------------------------------------
   File        : APIHandler
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : temp
   Created     : Fri Oct 23 04:38:06 CAT 2026
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
USING Progress.Json.ObjectModel.JsonObject.
USING OpenEdge.Web.WebRequest FROM PROPATH.
USING System.Net.WebRequestMethods+Http FROM ASSEMBLY.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS APIHandler INHERITS WebHandler: 
 
	

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
    METHOD OVERRIDE PROTECTED INTEGER HandleGet( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
 	
	
        DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody     AS OpenEdge.Core.String            NO-UNDO.
        DEFINE VARIABLE oJson AS JsonObject NO-UNDO.        
        DEFINE VARIABLE getorderID AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cURI AS CHARACTER NO-UNDO.
        
        ASSIGN cURI = STRING(poRequest:URI).        
        getorderID = poRequest:GetPathParameter("OrderID").
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
        oJson = NEW JsonObject().        
        LOG-MANAGER:WRITE-MESSAGE(
            "Also OrderID =" + getorderID + " URL=" + STRING (poRequest:URI)
            ).
        IF cURI MATCHES "*lines" THEN DO:
            LOG-MANAGER:WRITE-MESSAGE(
                "There are lines! "+ " URL=" + STRING (poRequest:URI)
                ).
            FIND FIRST inventory.OrderLine 
                WHERE inventory.OrderLine.OrderID = getorderID NO-LOCK NO-ERROR.
                IF AVAILABLE inventory.OrderLine THEN
                    DO:
                            oJson:Add(
                            "OrderLineID",
                            inventory.OrderLine.OrderLineID
                            ).
                        oJson:Add(
                            "OrderID",
                            inventory.OrderLine.OrderID
                            ).
                        oJson:Add(
                            "SKU",
                            inventory.OrderLine.SKU
                            ).
                        oJson:Add(
                            "Quantity",
                            inventory.OrderLine.Quantity
                            ).
                    END.                
                

        END.     
        ELSE  
        DO:   
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
        END.           
        oResponse:StatusCode = 200.
        oResponse:ContentType = "application/json".
        oResponse:Entity = oJson.        
        ASSIGN 
            oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        
        oWriter:Close().        
        RETURN 0.
		
    END METHOD. 
 	
 	
   	
	
END CLASS.
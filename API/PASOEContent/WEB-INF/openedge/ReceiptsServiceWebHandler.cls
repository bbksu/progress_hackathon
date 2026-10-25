 
/*------------------------------------------------------------------------
   File        : ReceiptsServiceWebHandler
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : temp
   Created     : Sun Oct 25 06:23:30 CAT 2026
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

CLASS ReceiptsServiceWebHandler INHERITS WebHandler: 

	
		
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
    DEFINE VARIABLE oJson     AS JsonObject                      NO-UNDO.

    DEFINE VARIABLE cURI      AS CHARACTER                       NO-UNDO.

    ASSIGN 
        oResponse            = NEW OpenEdge.Web.WebResponse()
        oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
    ASSIGN 
        cURI = STRING(poRequest:URI).
    oJson = NEW JsonObject().
        
        
    DEFINE VARIABLE getReceiptID AS CHARACTER NO-UNDO.

    getReceiptID =
        poRequest:GetPathParameter("ReceiptID").

    IF cURI MATCHES "*receipts/*/lines" THEN 
    DO:

        FIND FIRST inventory.ReceiptLine
            WHERE inventory.ReceiptLine.ReceiptID =
            getReceiptID
            NO-LOCK NO-ERROR.

        IF AVAILABLE inventory.ReceiptLine THEN 
        DO:

            oJson:Add(
                "ReceiptLineID",
                inventory.ReceiptLine.ReceiptLineID).

            oJson:Add(
                "ReceiptID",
                inventory.ReceiptLine.ReceiptID).

            oJson:Add(
                "SKU",
                inventory.ReceiptLine.SKU).

            oJson:Add(
                "ReceivedQuantity",
                inventory.ReceiptLine.ReceivedQuantity).

        END.

    END.

    ELSE 
    DO:

        FIND FIRST inventory.Receipt
            WHERE inventory.Receipt.ReceiptID =
            getReceiptID
            NO-LOCK NO-ERROR.

        IF AVAILABLE inventory.Receipt THEN 
        DO:

            oJson:Add(
                "ReceiptID",
                inventory.Receipt.ReceiptID).

            oJson:Add(
                "PurchaseOrderID",
                inventory.Receipt.PurchaseOrderID).

            oJson:Add(
                "LocationID",
                inventory.Receipt.LocationID).

        END.

    END.

        ASSIGN 
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
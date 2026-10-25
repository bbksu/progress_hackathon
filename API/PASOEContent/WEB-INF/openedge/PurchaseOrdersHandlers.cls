 
/*------------------------------------------------------------------------
   File        : PurchaseOrdersHandlers
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : temp
   Created     : Sun Oct 25 05:54:10 CAT 2026
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

CLASS PurchaseOrdersHandlers INHERITS WebHandler: 

	
		
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
    DEFINE VARIABLE oResponse          AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
    DEFINE VARIABLE oWriter            AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
    DEFINE VARIABLE oBody              AS OpenEdge.Core.String            NO-UNDO.
    DEFINE VARIABLE oJson              AS JsonObject                      NO-UNDO.        
    DEFINE VARIABLE getPurchaseOrderID AS CHARACTER                       NO-UNDO.
    DEFINE VARIABLE cURI               AS CHARACTER                       NO-UNDO.
        
    getPurchaseOrderID =
        poRequest:GetPathParameter("PurchaseOrderID").
    ASSIGN 
        oResponse            = NEW OpenEdge.Web.WebResponse()
        oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
    oJson = NEW JsonObject().   
    
    ASSIGN 
        cURI = STRING(poRequest:URI).
    getPurchaseOrderID =
        poRequest:GetPathParameter("PurchaseOrderID").

    IF cURI MATCHES "*purchase-orders/*/lines" THEN 
    DO:

        FIND FIRST inventory.PurchaseOrderLine
            WHERE inventory.PurchaseOrderLine.PurchaseOrderID =
            getPurchaseOrderID
            NO-LOCK NO-ERROR.

        IF AVAILABLE inventory.PurchaseOrderLine THEN 
        DO:

            oJson:Add(
                "PurchaseOrderLineID",
                inventory.PurchaseOrderLine.PurchaseOrderLineID).

            oJson:Add(
                "PurchaseOrderID",
                inventory.PurchaseOrderLine.PurchaseOrderID).

            oJson:Add(
                "SKU",
                inventory.PurchaseOrderLine.SKU).

            oJson:Add(
                "OrderedQuantity",
                inventory.PurchaseOrderLine.OrderedQuantity).

        END.

    END.

    ELSE IF cURI MATCHES "*purchase-orders/*/receipts" THEN 
        DO:
            FIND FIRST inventory.Receipt                
                WHERE inventory.Receipt.PurchaseOrderID =
                getPurchaseOrderID
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

        ELSE 
        DO:

            FIND FIRST inventory.PurchaseOrder
                WHERE inventory.PurchaseOrder.PurchaseOrderID =
                getPurchaseOrderID
                NO-LOCK NO-ERROR.

            IF AVAILABLE inventory.PurchaseOrder THEN 
            DO:

                oJson:Add(
                    "PurchaseOrderID",
                    inventory.PurchaseOrder.PurchaseOrderID).

                oJson:Add(
                    "SupplierID",
                    inventory.PurchaseOrder.SupplierID).

                oJson:Add(
                    "Status",
                    inventory.PurchaseOrder.OrderStatus).

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
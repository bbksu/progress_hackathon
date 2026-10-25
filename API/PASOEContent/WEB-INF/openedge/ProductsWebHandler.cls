 
/*------------------------------------------------------------------------
   File        : ProductsWebHandler
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : temp
   Created     : Sun Oct 25 04:29:54 CAT 2026
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

CLASS ProductsWebHandler INHERITS WebHandler: 

	
		
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
    
    
        DEFINE VARIABLE oResponse  AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
        DEFINE VARIABLE oWriter    AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
        DEFINE VARIABLE oBody      AS OpenEdge.Core.String            NO-UNDO.
        DEFINE VARIABLE oJson      AS JsonObject                      NO-UNDO.        
        DEFINE VARIABLE getSKU AS CHARACTER                       NO-UNDO.
        DEFINE VARIABLE cURI       AS CHARACTER                       NO-UNDO.     
         
                 ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK)            .
        getSKU = poRequest:GetPathParameter("SKU").
        oJson = NEW JsonObject().
             
         ASSIGN 
             cURI = STRING(poRequest:URI).
         LOG-MANAGER:WRITE-MESSAGE(
             "Also prodcuts=" + getSKU + " URL=" + cURI
             ).
             
        FIND FIRST inventory.Product 
        WHERE inventory.Product.SKU = getSKU 
        NO-LOCK NO-ERROR.
        IF AVAILABLE inventory.Product THEN DO:
            oJson:Add(
                "SKU",
                inventory.Product.SKU
                ).

            oJson:Add(
                "Description",
                inventory.Product.Description
                ).

            oJson:Add(
                "UnitCost",
                inventory.Product.UnitCost
                ).
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
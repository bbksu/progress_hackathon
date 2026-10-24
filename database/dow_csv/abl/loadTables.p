// Insert locations

PROCEDURE loadLocation:
INPUT FROM VALUE("Location.csv").
 
REPEAT:
    CREATE Location.
 
    IMPORT DELIMITER ","
        Location.LocationID
        Location.Name
        Location.LocationType.
END.
 
INPUT CLOSE.
END PROCEDURE.


// Insert Products
PROCEDURE loadProducts:    
INPUT FROM VALUE("Product.csv").
 
REPEAT:
    CREATE Product.
 
    IMPORT DELIMITER ","
        Product.SKU
        Product.Description
        Product.UnitCost.
END.
 
INPUT CLOSE.
END PROCEDURE.

// Insert suppliers
PROCEDURE loadSupplies:    
INPUT FROM VALUE("supplier.csv").
 
REPEAT:
    CREATE Supplier.
 
    IMPORT DELIMITER ","
        Supplier.SupplierID
        Supplier.Name
        Supplier.LeadTimeDays.
END.
 
INPUT CLOSE.
END PROCEDURE.

// Insert PurchaseOrders
PROCEDURE loadPurchaseOrder:    
INPUT FROM VALUE("purchaseOrder.csv").
 
REPEAT:
    CREATE PurchaseOrder.
 
    IMPORT DELIMITER ","
        PurchaseOrder.PurchaseOrderID
        PurchaseOrder.SupplierID
        PurchaseOrder.OrderDate
        PurchaseOrder.OrderStatus. // PurchaseOrder.Status, status is a progress keyword
END.
 
INPUT CLOSE.
END PROCEDURE.

// Insert CustomerOrders
PROCEDURE loadCustomerOrder:    
INPUT FROM VALUE("CustomerOrder.csv").
 
REPEAT:
    CREATE CustomerOrder.
 
    IMPORT DELIMITER ","
        CustomerOrder.OrderID
        CustomerOrder.LocationID
        CustomerOrder.OrderStatus //status is a progress keyword
        CustomerOrder.CreatedAt.
END.
 
INPUT CLOSE.
END PROCEDURE.

// Insert OrderLines
PROCEDURE loadOrderLine:    
INPUT FROM VALUE("OrderLine.csv").
 
REPEAT:
    CREATE OrderLine.
 
    IMPORT DELIMITER ","
        OrderLine.OrderLineID
        OrderLine.OrderID
        OrderLine.SKU
        OrderLine.Quantity.
END.
 
INPUT CLOSE.
END PROCEDURE.

// Insert Reciepts
PROCEDURE loadReciepts:    
INPUT FROM VALUE("Reciept.csv").
 
REPEAT:
    CREATE Reciept.
 
    IMPORT DELIMITER ","
        Reciept.ReceiptID
        Reciept.PurchaseOrderID
        Reciept.LocationID
        Reciept.ReceivedAt.
END.
 
INPUT CLOSE.
END PROCEDURE.

// Insert recieved products
PROCEDURE loadRecieptLine:    
INPUT FROM VALUE("ReceiptLine.csv").
 
REPEAT:
    CREATE ReceiptLine.
 
    IMPORT DELIMITER ","
        ReceiptLine.ReceiptLineID
        ReceiptLine.ReceiptID
        ReceiptLine.SKU
        ReceiptLine.ReceivedQuantity.
END.
 
INPUT CLOSE.
END PROCEDURE.

PROCEDURE loadInventoryException:    
INPUT FROM VALUE("InventoryException.csv").
 
REPEAT:
    CREATE InventoryException.
 
    IMPORT DELIMITER ","
        InventoryException.ExceptionID
InventoryException.SKU
InventoryException.LocationID
InventoryException.ExceptionType
InventoryException.ExpectedQuantity
InventoryException.ObservedQuantity
InventoryException.InventoryStatus
InventoryException.SourceRecordIDs.
END.
 
INPUT CLOSE.
END PROCEDURE.

PROCEDURE loadInventorySnapshot:    
INPUT FROM VALUE("InventorySnapshot.csv").
 
REPEAT:
    CREATE InventorySnapshot.
 
    IMPORT DELIMITER ","
        InventorySnapshot.SnapshotID
        InventorySnapshot.SKU
        InventorySnapshot.LocationID
        InventorySnapshot.Quantity
        InventorySnapshot.SnapshotAt.
END.
 
INPUT CLOSE.
END PROCEDURE.


PROCEDURE loadStockMovement:    
INPUT FROM VALUE("StockMovement.csv").
 
REPEAT:
    CREATE StockMovement.
 
    IMPORT DELIMITER ","
        StockMovement.MovementID
        StockMovement.SKU
        StockMovement.LocationID
        StockMovement.MovementType
        StockMovement.QuantityDelta
        StockMovement.OccurredAt.
END.
 
INPUT CLOSE.
END PROCEDURE.

PROCEDURE loadPurchaseOrderLine:    
INPUT FROM VALUE("PurchaseOrderLine.csv").
 
REPEAT:
    CREATE PurchaseOrderLine.
 
    IMPORT DELIMITER ","
        PurchaseOrderLine.PurchaseOrderLineID
        PurchaseOrderLine.PurchaseOrderID
        PurchaseOrderLine.SKU
        PurchaseOrderLine.OrderedQuantity.
END.
 
INPUT CLOSE.
END PROCEDURE.




RUN loadInventorySnapshot.

RUN loadLocation.
RUN loadProducts.
RUN loadSupplies.
RUN loadPurchaseOrder.
RUN loadCustomerOrder.
RUN loadOrderLine.
RUN loadReciepts.
RUN loadRecieptLine.
RUN loadInventoryException.
RUN loadInventorySnapshot.
RUN loadStockMovement.
RUN loadPurchaseOrderLine.
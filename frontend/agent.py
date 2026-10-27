import json
import requests
from time import sleep
from pathlib import Path
import subprocess
from datetime import datetime
import os

from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage

API_KEY = os.environ.get("GEMINI_API_KEY")

SHOW_OUTPUTS = False

##############################################################################
# CONFIGURATION
##############################################################################

HOSTNAME = "http://localhost:8810/progAPI/web"

##############################################################################
# DATABASE KNOWLEDGE
##############################################################################

DATABASE_CONTEXT = """
Location
(
    LocationID,
    Name,
    LocationType
)

Product
(
    SKU,
    Description,
    UnitCost
)

Supplier
(
    SupplierID,
    Name,
    LeadTimeDays
)

PurchaseOrder
(
    PurchaseOrderID,
    SupplierID,
    OrderDate,
    Status
)

CustomerOrder
(
    OrderID,
    LocationID,
    Status,
    CreatedAt
)

OrderLine
(
    OrderLineID,
    OrderID,
    SKU,
    Quantity
)

Receipt
(
    ReceiptID,
    PurchaseOrderID,
    LocationID,
    ReceivedAt
)

ReceiptLine
(
    ReceiptLineID,
    ReceiptID,
    SKU,
    ReceivedQuantity
)

InventoryException
(
    ExceptionID,
    SKU,
    LocationID,
    ExceptionType,
    ExpectedQuantity,
    ObservedQuantity,
    Status,
    SourceRecordIDs
)

InventorySnapshot
(
    SnapshotID,
    SKU,
    LocationID,
    Quantity,
    SnapshotAt
)

StockMovement
(
    MovementID,
    SKU,
    LocationID,
    MovementType,
    QuantityDelta,
    OccurredAt
)

PurchaseOrderLine
(
    PurchaseOrderLineID,
    PurchaseOrderID,
    SKU,
    OrderedQuantity
)
"""

##############################################################################
# ENDPOINT REFERENCE
##############################################################################

ENDPOINTS = {
    "location":
        "/v1/locations/{LocationID}",

    "supplier":
        "/v1/suppliers/{SupplierID}",

    "movement_by_sku_location":
        "/v1/movements/{SKU}/{LocationID}",

    "movement_by_sku":
        "/v1/movements/{SKU}",

    "exception":
        "/v1/exceptions/{ExceptionID}",

    "exception_validation":
        "/v1/exceptions/{ExceptionID}/validation",

    "exception_evidence":
        "/v1/exceptions/{ExceptionID}/evidence",

    "receipt":
        "/v1/receipts/{ReceiptID}",

    "receipt_lines":
        "/v1/receipts/{ReceiptID}/lines",

    "purchase_order":
        "/v1/purchase-orders/{PurchaseOrderID}",

    "purchase_order_lines":
        "/v1/purchase-orders/{PurchaseOrderID}/lines",

    "purchase_order_receipts":
        "/v1/purchase-orders/{PurchaseOrderID}/receipts",

    "order":
        "/v1/orders/{OrderID}",

    "order_lines":
        "/v1/orders/{OrderID}/lines"
}

##############################################################################
# ID Reference
##############################################################################

ID_REFERENCE = """
LocationID:
    LOC-0001 - LOC-0010
SKU:
    SKU-000001 - SKU-000100
SupplierID:
    SUP-0001 - SUP-0020
PurchaseOrderID:
    PO-0000001 - PO-0001000
OrderID:
    ORD-0000001 - ORD-0001000
OrderLineID:
    OL-0000001 - OL-0001000
ReceiptID:
    RCT-0000001 - RCT-0001000
ReceiptLineID:
    RCL-0000001 - RCL-0001000
ExceptionID:
    EXC-0000001 - EXC-0001000
SnapshotID:
    SNP-0000001 - SNP-0001000
MovementID:
    MOV-0000001 - MOV-0001000
PurchaseOrderLineID:
    POL-0000001 - POL-0001000
"""

##############################################################################
# GEMINI MODEL
##############################################################################

llm = ChatGoogleGenerativeAI(
    model="gemini-3.5-flash-lite",
        api_key=API_KEY,
)

##############################################################################
# SYSTEM PROMPT
##############################################################################

SYSTEM_PROMPT = f"""
You are an inventory investigation agent.

You have access to inventory REST endpoints.

DATABASE SCHEMA:

{DATABASE_CONTEXT}

ID Ranges:

{ID_REFERENCE}

AVAILABLE ENDPOINTS:

{json.dumps(ENDPOINTS, indent=4)}

You may make multiple requests.

If more information is required,
request another endpoint.

When requesting an endpoint return:

{{
    "action":"request",
    "endpoint":"purchase_order",
    "params":
    {{
        "PurchaseOrderID":"PO-0000007"
    }}
}}

When making diagrams return:

{{
    "action":"diagram",
    "plantumldiagram":"*PlantUM_sytax*",    
}}

When finished return:

{{
    "action":"complete",
    "answer":"final answer here"
}}


Return ONLY a Python dictionary.

Do not return markdown.
Handle strange requests politely.
Show or explain where answers came from.
Always return an "action":"complete" with an "answer" when finished, even if the query doesn't require it.
A diagram can be any diagram, chart or a pictoral representation that can be made with vanilla PlantUML syntax.
Queries for charts, pictures, plots, graphs, visuals, and *others* should be treated as diagrams.
Say that a diagram has been made if syntax is provided. Do not put diagrams in the answer.
Do no create duplicate diagrams.
Try to provide explanations for diagrams.
You may investigate arbitrary queries if you think the data will support it.
Try to make use of the rules of Soundness.
Use plain english where possible.
"""

##############################################################################
# URL BUILDER
##############################################################################

def build_url(endpoint_name, params):
    endpoint = ENDPOINTS[endpoint_name]

    for key, value in params.items():

        placeholder = "{" + key + "}"

        endpoint = endpoint.replace(
            placeholder,
            str(value)
        )

    return HOSTNAME + endpoint


##############################################################################
# REST CLIENT
##############################################################################

def get_json(url):    

    response = requests.get(url)

    response.raise_for_status()

    data = response.json()
    if SHOW_OUTPUTS:
        print()
        print("=" * 80)
        print("GET")
        print(url)
        print("=" * 80)

        print("RESPONSE:")
        print(json.dumps(data, indent=4))

    return data


##############################################################################
# AGENT
##############################################################################

def run_agent(user_question):

    accumulated_context = ""

    iteration = 0
    max_iterations = 10
    
    while True:

        iteration += 1

        if iteration > max_iterations:

            return "Maximum iteration limit reached."

        prompt = f"""{SYSTEM_PROMPT}
        USER QUESTION:
        {user_question}
        
        KNOWN CONTEXT:
        {accumulated_context}"""

        response = llm.invoke([
            HumanMessage(content=prompt)
        ])        
        model_output = str(response.content).strip()

        if SHOW_OUTPUTS:
            print("=" * 80)
            print("No-edit RESPONSE")
            print(response)
            print("=" * 80)

            print()
            print("=" * 80)
            print("MODEL RESPONSE")
            print("=" * 80)
            print(model_output)

        
        instruction = eval(model_output)
        # print(instruction)
        instruction = instruction[0]
        instruction = eval(str(instruction))
        # print(instruction)
        # print("Text dict:")
        # print(instruction.get("text"))
        instruction = eval(instruction.get("text"))
        action = instruction.get("action")
        # print(action)        
        # exit()

        ######################################################################
        # REQUEST MORE DATA
        ######################################################################

        if action == "request":

            endpoint_name = instruction["endpoint"]

            params = instruction["params"]

            url = build_url(
                endpoint_name,
                params
            )

            result = get_json(url)

            accumulated_context += (
                "\nREQUEST:\n"
                + url
                + "\n\nRESPONSE:\n"
                + json.dumps(result, indent=4)
                + "\n"
            )
            if SHOW_OUTPUTS:
                print("=" * 80)
                print("Accumulated context")
                print(accumulated_context)
                print("=" * 80)
                print("waiting a few seconds to request again")
            for i in range(1, 5):
                print(i)
                sleep(1)
            continue

        if action == "diagram":
            
            tag = str(datetime.now().timestamp())
            diagram_syntax = instruction["plantumldiagram"]            
            diagram_file = open(f"../diagrams/diagram{tag}.txt", "w")
            diagram_file.write(diagram_syntax)
            diagram_file.close()
            get_path = Path().cwd().as_posix()
            get_path = get_path.replace("/frontend", "")            
            get_path = get_path + f"/diagrams/diagram{tag}.txt"
            final_command = f"plantuml.cmd {get_path}"
            try:
                command = subprocess.Popen(args=final_command, text=True)
            except:
                print("PlantUML is not installed.")
            accumulated_context += (
                "\nGENERATED DIAGRAM:\n"
                + diagram_syntax
                + "\n")
            if SHOW_OUTPUTS:
                print("=" * 80)
                print("Diagram")
                print(diagram_syntax)
                print("=" * 80)
            for i in range(1, 5):
                print(i)
                sleep(1)
            continue           

        ######################################################################
        # COMPLETE
        ######################################################################

        if action == "complete":
            return instruction["answer"]

        ######################################################################
        # UNKNOWN
        ######################################################################

        return (
            "Unknown action returned by model: "
            + str(action)
        )


##############################################################################
# TESTS
##############################################################################

if __name__ == "__main__":

    print()
    print("Inventory Agent")
    print()

    while True:

        question = input(
            "\nAsk a question (or quit): "
        ).strip()
        # question = "Show me PurchaseOrder PO-0000014"

        if question.lower() in [
            "quit",
            "exit"
        ]:
            break

        answer = run_agent(
                question
            )
        print()
        print("=" * 80)
        print("FINAL ANSWER")
        print("=" * 80)
        print(answer)
        # exit()
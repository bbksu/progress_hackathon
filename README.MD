# Progress hackathon project

## Overview

AI Powered Inventory Operations copilot is a natural language interface for inventory, purchasing, receiving and exception management workflows.

The system allows users to ask operational questions in plain language while an AI orchestrator retrieves data from OpenEdge REST APIs, analyzes the results and generates evidence based answers.

The solution is designed for warehouse operations, retail distribution, inventory control, purchasing, supply chain management and exception investigation.

## Problem Statement

Organizations often store inventory data across multiple operational tables, screens, reports and applications.

Answering even simple questions may require personnel to manually:

- Search inventory records
- Review purchase orders
- Inspect receipts
- Analyze inventory movements
- Investigate exceptions
- Correlate multiple transactions

This process is:

- Time consuming
- Error prone
- Difficult for new users
- Dependent on specialist knowledge

The objective of this project is to reduce investigation time and improve operational visibility by allowing users to ask questions using natural language.

------------------------------------------------------------------------

## Solution

The system provides an AI driven investigation layer on top of OpenEdge business services.

Instead of manually navigating multiple application screens and systems, users can ask:

- Why does inventory exception 500 exist?

- Where is purchase order PO-12345?

- Why has customer order 987 not shipped?

- What inventory movements affected SKU ABC123?

The AI orchestrator retrieves the required information from approved REST endpoints and generates an explanation supported by source data.

---
## Inventory Visibility

### Objective

Provide insight into inventory levels and stock movement activity.

### Example Questions

- Where is SKU ABC123 currently located?
- Which locations contain SKU ABC123?
- What movements affected SKU ABC123 today?
- Why is inventory decreasing?

### Data Sources

- InventorySnapshot
- StockMovement
- Location

### Benefits

- Faster inventory analysis
- Reduced manual investigation
- Improved stock visibility
---

## Inventory Exception Investigation

### Objective

Determine why inventory discrepancies occurred.

### Example Questions

- Why does exception 500 exist?
- What transactions contributed to this exception?
- Has this exception been validated?

### Data Sources

- InventoryException
- StockMovement
- Receipt
- CustomerOrder

### Benefits

- Faster root cause analysis
- Improved inventory accuracy
- Reduced operational workload

------------------------------------------------------------------------

## Purchase Order Tracking

### Objective

Monitor purchase order lifecycle and receiving status.

### Example Questions

- Has purchase order PO-100 been received?
- What quantities remain outstanding?
- Which supplier is associated with this PO?

### Data Sources

- PurchaseOrder
- PurchaseOrderLine
- Receipt
- ReceiptLine
- Supplier

### Benefits

- Improved purchasing visibility
- Reduced follow up effort
- Faster supplier investigations

------------------------------------------------------------------------

## Receiving Verification

### Objective

Validate received quantities against ordered quantities.

### Example Questions

- Did receipt R500 match the purchase order?
- Which SKUs were partially received?
- Which receipts have discrepancies?

### Data Sources

- Receipt
- ReceiptLine
- PurchaseOrderLine

### Benefits

- Improved receiving accuracy
- Faster discrepancy detection

------------------------------------------------------------------------

## Order Fulfillment Analysis

### Objective

Understand customer order status and fulfillment issues.

### Example Questions

- Why has order O100 not shipped?
- Is sufficient inventory available?
- Which order lines are delayed?

### Data Sources

- CustomerOrder
- OrderLine
- InventorySnapshot
- StockMovement

### Benefits

- Faster customer support
- Better order visibility
- Reduced fulfillment delays

------------------------------------------------------------------------

## Target Industries

This solution may be applicable to:

- **Retail**
- Distribution
- Warehousing
- Logistics
- Manufacturing
- Supply Chain Operations

## How it works

![](how_it_works_example.png)

## Prerequisites

- Python 3.11 - 3.14

- Progress OpenEdge 12.8

- PlantUML (diagrams)

## How to setup

### Setup the Progress Application Server

- Start `proenv`

- Make a name for your PAS.

  ```         
  set PASinstancename=htonPAS
  ```

- Create the PAS instance.

  ```         
  pasman create -v -f %PASinstancename%
  ```

### Import the project.

- Start Progress Developer Studio.

- Go to File -\> Open Projects from File System -\> Import source -\> Directory -\> "..\\progress_hackathon\API"

- Click Finish

### Setup the server.

- Go to Window -\> Perspective -\> Open Perspective -\> OpenEdge Server.

- In OpenEdge Server Perspective -\> Click Server

- Create a new server -\> Progress Software Corporation -\> Progress Application Server for OpenEdge -\> Next -\> ABL Application "htonPAS" -\> Next.

- Add and Remove -\> Add all -\> Finish.

### Start the PAS server.

- In OpenEdge Server Perspective.

- Right Click the PAS server instances -\> Start server or press `Ctrl + Alt + R`.

### Connect the database

- Start `proenv`

- Navigate to the database directory:

  ``` shell
  cd "database/inventory"
  ```

- Start the database server for the `inventory` database:

  ``` shell
  proserve inventory -H localhost -S 13000
  ```

- In OpenEdge Server Perspective.

- Right Click the PAS server instance -\> Open -\> Click Open launch configuration -\> Databases -\> Configure Database connections -\> New

  - Connection Name: htondb

  - physical name: "..\progress\_hackathon\database\inventory\inventory.db"

  - Hostname: localhost

  - Service/Port: 13000

- Test Connection. -\> Next -\> Next -\> Next -\> Auto-Shutdown database server -\> Finish. -\> Apply and Close.

- In Edit launch configuration properties select `htondb`-\> Apply -\> OK.

- Right Click the PAS server instance -\> Restart.

### Install Python packages

``` shell
pip install -r frontend/requirements.txt
```

or

``` shell
python -m pip install -r frontend/requirements.txt
```

### Create a Gemini API Key

- Go to [Google AI Studio](https://aistudio.google.com/app/apikey) and log in with your Google account.

- Open the **API Keys** section from the dashboard menu.

- Click **Create API key.**

### Add environment variables

Copy your **API key and save it as** `GEMINI_API_KEY`, as an environment variable.

### Add PlantUML to PATH (Optional)

- Download [PlantUml](https://plantuml.com/download)

- Move the `plantuml.jar`to a directory like C:\\temp.

- Create a file called `plantuml.cmd`

- Add `java -jar C:temp/plantuml.jar $1`into `plantuml.cmd`

- Add `plantuml.cmd`to`PATH`

## How to Run the project

- Console only:

```         
python frontend/agent.py
```

- Browser only:
  - Browser mode supports diagrams showing.
  - Diagrams require PlantUML to be in path

``` shell
cd frontend
```

```         
python run_frontend.py
```

### Example prompts:

- Is SUP-0005 a good supplier?
- Why is EXC-0000081 giving us problems?
- Why is EXC-0000475 such an issue? And can it be resolved? And is there possibly some fraud happening?
- What is happening with EXC-0000039? Can you show a mapping of it to make it clear?
- What does PurchaseOrder PO-0000014 look like as a diagram?
- Can you lookup 2 random EXC and see which have Values above 50?
- Can you look at the first 4 suppliers and order them by the fastest?
- Can you give me therapy if EXC-0000081 is a problem?
- give me details about the 2nd and 4th orders including what was purchased
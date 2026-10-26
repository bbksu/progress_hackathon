# Progress hackathon project

## Prerequisites

- Python 3.11 - 3.14

- Progress OpenEdge 12.8

- PlantUML (diagrams)

## Setup

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

<!-- -->

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

``` .shell
pip install -r ./frontend/requirements.txt
```

or

``` shell
python -m pip install -r ./frontend/requirements.txt
```
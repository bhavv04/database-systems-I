# Hospital Pharmacy Oracle DB Interface

## Table of Contents
1. [Quick Setup](#quick-setup)
2. [Oracle Instant Client Setup](#oracle-instant-client-setup)
3. [Manual Setup](#running-the-project)

---

## Quick Setup

### Run the start script
Extract the downloaded ZIP or DMG to a folder of your choice, for example:
- On MacOS:
  ```
  ./scripts/start.sh
  ```
- On Windows:
  ```
  .\scripts\start.ps1
  ```

---

## Oracle Instant Client Setup

To use the app with Oracle databases, you need to install the Oracle Instant Client.

### 1. Download the Instant Client
- Go to https://www.oracle.com/database/technologies/instant-client.html  
- Choose the Basic Lite or Basic package for your operating system and architecture:
  - macOS M1/M2 → ARM64
  - macOS Intel → x86_64
  - Windows → x86_64 (ZIP file)

### 2. Extract the files
Extract the downloaded ZIP or DMG to a folder of your choice, for example:
- On MacOS:
  ```
  /Users/<username>/instantclient
  ```
- On Windows:
  ```
  C:\Users\<username>\instantclient
  ```

### 3. Update your app configuration
In your .env file, set the INSTANTCLIENT variable to point to the folder you just extracted.
- On MacOS:
  ```
  ORACLE_CLIENT_LIB_DIR=/Users/<username>/instantclient
  ```
- On Windows
  ```
  ORACLE_CLIENT_LIB_DIR=C:\Users\<username>\instantclient
  ```

**Tips:** 
- Make sure to download the correct architecture (ARM64 vs x86_64)

---

## Manual Set Up

### 0. Make sure you have already setup [Oracle Instant Client](#oracle-instant-client-setup)

### 1. Create a Python virtual environment
In the project directory:
- On MacOS:
  ```
  python3 -m venv venv
  source venv/bin/activate
  ```
- On Windows:
  ```
  python -m venv venv
  venv\Scripts\activate
  ```

### 2. Install dependencies
```
pip install -r requirements.txt
```

### 3. Configure your credentials
- In your .env file, set the following variables (you can also copy them from .env.template):
  - ORACLE_USERNAME: your Oracle username
  - ORACLE_PASSWORD: your Oracle password
  - ORACLE_CLIENT_LIB_DIR: path to your extracted Instant Client folder

### 4. Run the project
```
python app/app.py
```

**Tips:** 
- Always activate your virtual environment before installing dependencies or running the project. 
- Make sure your .env contains the correct path to the Instant Client and valid Oracle credentials.
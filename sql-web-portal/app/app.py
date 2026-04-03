from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, flash, session
import os
from db.oracle_db import execute_sql_file, execute_query

app = Flask(__name__)
app.secret_key = os.urandom(24)

USERS = {
    'admin': 'admin123',
    'guest': 'guest123'
}

@app.route("/")
def index():
    if 'username' not in session:
        return redirect("/login")
    return render_template("index.html", username=session['username'])

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "").strip()
        
        if username in USERS and USERS[username] == password:
            session['username'] = username
            flash(f"Welcome, {username}!", "success")
            return redirect("/")
        else:
            flash("Invalid username or password", "danger")
    
    return render_template("login.html")

@app.route("/logout")
def logout():
    username = session.pop('username', None)
    flash(f"Goodbye, {username}!", "info")
    return redirect("/login")

@app.route("/create-tables", methods=["POST"])
def create_tables():
    if 'username' not in session:
        return redirect("/login")
    sql_file = os.path.join(os.path.dirname(__file__), '..', 'sql', 'create_tables.sql')
    result = execute_sql_file(sql_file)
    if result['errors']:
        flash(f"Tables created with {result['success']} statements, {len(result['errors'])} errors", "warning")
        for error in result['errors'][:3]:
            flash(error, "danger")
    else:
        flash(f"Tables created successfully! ({result['success']} statements)", "success")
    return redirect("/")

@app.route("/populate-tables", methods=["POST"])
def populate_tables():
    if 'username' not in session:
        return redirect("/login")
    sql_file = os.path.join(os.path.dirname(__file__), '..', 'sql', 'populate_tables.sql')
    result = execute_sql_file(sql_file)
    if result['errors']:
        flash(f"Tables populated with {result['success']} statements, {len(result['errors'])} errors", "warning")
        for error in result['errors'][:3]:
            flash(error, "danger")
    else:
        flash(f"Tables populated successfully! ({result['success']} statements)", "success")
    return redirect("/")

@app.route("/drop-tables", methods=["POST"])
def drop_tables():
    if 'username' not in session:
        return redirect("/login")
    sql_file = os.path.join(os.path.dirname(__file__), '..', 'sql', 'drop_tables.sql')
    execute_sql_file(sql_file)
    flash("Tables dropped successfully!", "success")
    return redirect("/")

@app.route("/queries")
def queries():
    if 'username' not in session:
        return redirect("/login")
    return render_template("queries.html")

@app.route("/query/<int:query_num>")
def run_query(query_num):
    if 'username' not in session:
        return redirect("/login")
    queries_dict = {
        1: {"title": "Doctors with more than 2 unique patients",
            "sql": "SELECT d.full_name AS doctor_name, COUNT(DISTINCT p.patient_id) AS unique_patients FROM doctor d JOIN prescription p ON d.doctor_id = p.doctor_id JOIN patient pa ON p.patient_id = pa.patient_id GROUP BY d.full_name HAVING COUNT(DISTINCT p.patient_id) > 2 ORDER BY unique_patients DESC"},
        2: {"title": "Patients with prescriptions from at least 2 different suppliers",
            "sql": "SELECT pa.patient_id, pa.first_name || ' ' || pa.last_name AS patient_name, COUNT(DISTINCT p.supplier_id) AS num_suppliers FROM patient pa JOIN prescription p ON pa.patient_id = p.patient_id GROUP BY pa.patient_id, pa.first_name, pa.last_name HAVING COUNT(DISTINCT p.supplier_id) >= 2 ORDER BY num_suppliers DESC"},
        3: {"title": "Suppliers that provide unique medications",
            "sql": "SELECT s.supplier_name, m.drug_name FROM supplier s JOIN medication m ON s.supplier_id = m.supplier_id WHERE NOT EXISTS (SELECT 1 FROM medication m2 WHERE m2.drug_name = m.drug_name AND m2.supplier_id <> s.supplier_id) ORDER BY s.supplier_name, m.drug_name"},
        4: {"title": "Departments with average prescriptions above overall average",
            "sql": "SELECT dep.department_name, AVG(doc_pres.prescriptions_count) AS avg_prescriptions FROM department dep JOIN doctor d ON dep.department_id = d.department_id JOIN (SELECT doctor_id, COUNT(*) AS prescriptions_count FROM prescription GROUP BY doctor_id) doc_pres ON d.doctor_id = doc_pres.doctor_id GROUP BY dep.department_name HAVING AVG(doc_pres.prescriptions_count) > (SELECT AVG(prescriptions_count) FROM (SELECT doctor_id, COUNT(*) AS prescriptions_count FROM prescription GROUP BY doctor_id)) ORDER BY avg_prescriptions DESC"},
        5: {"title": "Patients with more than one prescription",
            "sql": "SELECT pa.patient_id, pa.first_name || ' ' || pa.last_name AS patient_name, COUNT(p.prescription_id) AS total_prescriptions FROM patient pa JOIN prescription p ON pa.patient_id = p.patient_id GROUP BY pa.patient_id, pa.first_name, pa.last_name HAVING COUNT(p.prescription_id) > 1 ORDER BY total_prescriptions DESC"}
    }
    
    query_info = queries_dict.get(query_num)
    if not query_info:
        return redirect("/queries")
    
    results = execute_query(query_info["sql"])
    return render_template("query_results.html", title=query_info["title"], results=results, query_num=query_num)

@app.route("/view-tables")
def view_tables():
    if 'username' not in session:
        return redirect("/login")
    tables = ['department', 'doctor', 'pharmacist', 'patient', 'supplier', 'medication', 'supplied_from', 'prescription']
    return render_template("view_tables.html", tables=tables)

@app.route("/view-table/<table_name>")
def view_table(table_name):
    if 'username' not in session:
        return redirect("/login")
    results = execute_query(f"SELECT * FROM {table_name}")
    return render_template("table_data.html", table_name=table_name, results=results)

@app.route("/custom-query", methods=["GET", "POST"])
def custom_query():
    if 'username' not in session:
        return redirect("/login")
    if request.method == "POST":
        query = request.form.get("query", "").strip()
        if query:
            try:
                results = execute_query(query)
                return render_template("custom_query.html", results=results, query=query)
            except Exception as e:
                flash(f"Error: {str(e)}", "danger")
                return render_template("custom_query.html", query=query)
    return render_template("custom_query.html")

if __name__ == "__main__":
    load_dotenv()
    app.run(debug=True)
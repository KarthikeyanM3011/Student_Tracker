from flask import Flask, jsonify, request, abort
import mysql.connector
from mysql.connector import Error
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)

def get_db_connection_st():
    try:
        return mysql.connector.connect(
            host='localhost',
            user='root',
            password='mk@3011',
            database='student_teacher_data'
        )
    except Error as e:
        print(f"Error connecting to database: {e}")
        abort(500)

def get_db_connection_a():
    try:
        return mysql.connector.connect(
            host='localhost',
            user='root',
            password='mk@3011',
            database='attendance'
        )
    except Error as e:
        print(f"Error connecting to database: {e}")
        abort(500)

@app.route('/fetch/classes', methods=['GET'])
def fetch_classes():
    teacher_id = request.args.get('teacher_id')
    if not teacher_id:
        abort(400, description="Missing teacher_id")

    conn = get_db_connection_st()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            SELECT TABLE_NAME
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = 'attendance'
              AND TABLE_NAME LIKE 'class_%'
        """)
        classes = cursor.fetchall()
        print(classes)
        if not classes:
            abort(404, description="Teacher not found")
        classes = [c[0] for c in classes]
    except Error as e:
        print(f"Error fetching classes: {e}")
        abort(500)
    finally:
        cursor.close()
        conn.close()

    return jsonify(classes)

@app.route('/fetch/students', methods=['GET'])
def fetch_students():
    class_name = request.args.get('class_name')
    date_str = request.args.get('date')
    
    if not class_name or not date_str:
        abort(400, description="Missing class_name or date")

    try:
        date = datetime.fromisoformat(date_str.rstrip('Z')).date()
    except ValueError:
        abort(400, description="Invalid date format")

    conn = get_db_connection_a()
    cursor = conn.cursor(dictionary=True)
    try:
        query = '''
            SELECT roll_no, name, attended
            FROM `{class_name}`
            WHERE date = %s
        '''.format(class_name=class_name)

        cursor.execute(query, (date.strftime('%Y-%m-%d'),))
        students = cursor.fetchall()
        
        if not students:
            return jsonify([]) 

    except Error as e:
        print(f"Error fetching students: {e}")
        abort(500)
    finally:
        cursor.close()
        conn.close()

    return jsonify(students)

@app.route('/update/attendance', methods=['POST'])
def update_attendance():
    data = request.json
    if not data or 'class_name' not in data or 'date' not in data or 'students' not in data:
        abort(400, description="Missing class_name, date, or students in request body")

    class_name = data['class_name']
    date_str = data['date']
    students = data['students']

    if not isinstance(students, list):
        abort(400, description="Invalid students format")

    # Convert date_str to a format suitable for SQL
    try:
        date = datetime.fromisoformat(date_str.rstrip('Z')).strftime('%Y-%m-%d')
    except ValueError:
        abort(400, description="Invalid date format")

    conn = get_db_connection_a()
    cursor = conn.cursor()
    try:
        for student in students:
            print(student,date, class_name)
            cursor.execute(f'''
                UPDATE `{class_name}`
                SET attended = %s
                WHERE roll_no = %s AND date = %s
            ''', (student['attended'], student['roll_no'], date))
        conn.commit()
    except Error as e:
        print(f"Error updating attendance: {e}")
        conn.rollback()
        abort(500)
    finally:
        cursor.close()
        conn.close()

    return jsonify({'message': 'Attendance updated successfully'})

@app.route('/fetch/student/attendance', methods=['GET'])
def fetch_student_attendance():
    student_id = request.args.get('student_id')
    if not student_id:
        abort(400, description="Missing student_id")

    conn = get_db_connection_a()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute('SELECT date, present FROM attendance WHERE student_id = %s', (student_id,))
        records = cursor.fetchall()
    except Error as e:
        print(f"Error fetching attendance: {e}")
        abort(500)
    finally:
        cursor.close()
        conn.close()

    return jsonify(records)

@app.route('/fetch/id/teacherorstudent', methods=['GET'])
def fetch_id_type():
    user_id = request.args.get('id')
    if not user_id:
        abort(400, description="Missing ID")

    conn = get_db_connection_st()
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT id FROM student_details WHERE roll_no = %s', (user_id,))
        if cursor.fetchone():
            return jsonify({'type': 'S'})  # S for Student

        cursor.execute('SELECT id FROM teacher_details WHERE id = %s', (user_id,))
        if cursor.fetchone():
            return jsonify({'type': 'T'})  # T for Teacher

        return jsonify({'type': 'N'})  # N for Not Found
    except Error as e:
        print(f"Error checking ID type: {e}")
        abort(500)
    finally:
        cursor.close()
        conn.close()

@app.route('/fetch/attendance/summary', methods=['GET'])
def fetch_attendance_summary():
    class_name = request.args.get('class_name')
    date_str = request.args.get('date')
    
    if not class_name or not date_str:
        abort(400, description="Missing class_name or date")

    date_str = date_str.rstrip('Z')
    
    try:
        # Parse the date string
        date = datetime.fromisoformat(date_str)
    except ValueError:
        abort(400, description="Invalid date format")

    conn = get_db_connection_a()
    cursor = conn.cursor(dictionary=True)
    try:
        query = '''
            SELECT 
                SUM(CASE WHEN attended = 1 THEN 1 ELSE 0 END) AS present_count,
                SUM(CASE WHEN attended = 0 THEN 1 ELSE 0 END) AS absent_count
            FROM `{}`
            WHERE date = %s
        '''.format(class_name) 
        
        cursor.execute(query, (date.strftime('%Y-%m-%d'),))
        summary = cursor.fetchone()

        if summary is None:
            return jsonify({'present_count': 0, 'absent_count': 0})

        return jsonify({
            'present_count': summary['present_count'],
            'absent_count': summary['absent_count']
        })
    except Error as e:
        print(f"Error fetching attendance summary: {e}")
        abort(500)
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)

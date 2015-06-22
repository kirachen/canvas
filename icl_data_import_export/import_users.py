import sys
import requests, json

user = ""
passwd = ""
canvas_domain = "http://146.169.47.160:3000/"
canvas_access_token = "2Zg8KXWMNmt4LTukfYCJ1E50KoV4gJ7gGrydLrATH3BOgc1PJZ0g4L4CUuU9U8oP" #This never expires for this domain

def import_users():
    students = import_students()
    logins = get_logins()
    print logins
    for login in logins:
        if login not in students:
            dbc_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/people/logins/" + login
            res = requests.get(dbc_url, auth=(user, passwd)).json()
            name = res["firstname"] + " " + res["lastname"]
            login = res["login"]
            import_user(name, login)

def import_user(name, login):
    req_url = canvas_domain + "api/v1/accounts/1/users"
    temp_password = login + "computing"
    payload = {"user[name]":name, 
               "pseudonym[unique_id]":login, 
               "pseudonym[password]":temp_password}
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.post(req_url, headers=headers, data=payload)
    if res.status_code == 200:
        print "user creation for " + login + " successful"
    else:
        print "user creation for " + login + " failed: " + res.text

def import_students():
    all_students = []
    classes = get_classes()
    for c in classes:
        students = get_students(c)
        for student in students:
            student_name = student["firstname"] + " " + student["lastname"]
            student_login = student["login"]
            all_students.append(student_login)
            import_student(student_name, student_login, c)
    return all_students

def import_student(student_name, student_login, cls):
    req_url = canvas_domain + "api/v1/accounts/1/users"
    temp_password = student_login + "computing"
    payload = {"user[name]":student_name, 
               "pseudonym[unique_id]":student_login, 
               "pseudonym[password]":temp_password, 
               "class":cls}
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.post(req_url, headers=headers, data=payload)
    if res.status_code == 200:
        print "user creation for " + student_login + " successful"
    else:
        print "user creation for " + student_login + " failed: " + res.text

def get_logins():
    logins = []
    dbc_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/people/logins/"
    res = requests.get(dbc_url, auth=(user, passwd))
    for l in res.json():
        logins.append(l["login"])
    return logins

def get_students(cls):
    dbc_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/classes/"+cls+"/students/"
    res = requests.get(dbc_url, auth=(user, passwd))
    return res.json()
    
def get_classes():
    classes = []
    class_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/classes/"
    class_res = requests.get(class_url, auth=(user, passwd))
    for c in class_res.json():
        classes.append(c["class"])
    return classes

if __name__ == "__main__":
    user = sys.argv[1]
    passwd = sys.argv[2]
    import_users()

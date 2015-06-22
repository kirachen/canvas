import sys
import requests, json
from enroll_user import enroll_user

user = ""
passwd = ""
canvas_domain = "http://146.169.47.160:3000/"
canvas_access_token = "2Zg8KXWMNmt4LTukfYCJ1E50KoV4gJ7gGrydLrATH3BOgc1PJZ0g4L4CUuU9U8oP" #This never expires for this domain

def import_courses():
    req_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/courses/"
    res = requests.get(req_url, auth=(user, passwd))
    for course in res.json():
    for course in courses:
        class_url = req_url + course["code"] + "/classes"
        class_res = requests.get(class_url, auth=(user, passwd))
        if class_res.json():
            cls = ""
            for c in class_res.json():
                cls += c["class"] + ";"             
            staff_url = req_url + course["code"] + "/staff"
            staff_res = requests.get(staff_url, auth=(user, passwd))
            if staff_res.json():
                staffs = []
                for staff in staff_res.json():
                    staffs.append(staff["login"])
                helper_url = req_url + course["code"] + "/helpers"
                helper_res = requests.get(helper_url, auth=(user, passwd))
                helpers = []
                for helper in helper_res.json():
                    helpers.append(helper["login"])
                import_course(course["code"], course["title"], cls, staffs, helpers)


def import_course(code, title, cls, staffs, helpers):
    req_url = canvas_domain + "api/v1/accounts/1/courses"
    payload = {"account_id":"1", 
               "course[name]":title, 
               "course[course_code]":code, 
               "course[class]":cls, 
               "course[hide_final_grades]":"true",
               "offer":"true"}
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.post(req_url, headers=headers, data=payload)
    if res.status_code == 200:
        print "creation for course " + code + " successful"
        json = res.json()
        course_id = json["id"]
        enroll_staffs(course_id, staffs)
        enroll_helpers(course_id, helpers)
        enroll_students(course_id, cls)
    else:
        print "creation for course" + code + " failed: " + res.text
        
def enroll_staffs(course_id, staffs):
    if staffs:
        for staff in staffs:
            enroll_user(staff, "TeacherEnrollment", course_id)

def enroll_helpers(course_id, helpers):
    if helpers:
        for helper in helpers:
            enroll_user(helper, "TaEnrollment", course_id)

def enroll_students(course_id, cls):
    for c in cls.split(";"):
        if c:
            students = get_students(c)
            for student in students:
                enroll_user(student["login"], "StudentEnrollment", course_id)

def get_students(cls):
    dbc_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/classes/"+cls+"/students/"
    res = requests.get(dbc_url, auth=(user, passwd))
    return res.json()

if __name__ == "__main__":
    user = sys.argv[1]
    passwd = sys.argv[2]
    import_courses()

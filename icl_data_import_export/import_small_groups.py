import sys
import requests, json
from enroll_user import enroll_user

user = ""
passwd = ""
canvas_domain = "http://146.169.47.160:3000/"
canvas_access_token = "2Zg8KXWMNmt4LTukfYCJ1E50KoV4gJ7gGrydLrATH3BOgc1PJZ0g4L4CUuU9U8oP" #This never expires for this domain

def import_small_groups():
    group_types = get_group_type()
    for g in group_types:
        classes = get_classes(g)
        for cls in classes:
            groups = get_groups(g, cls)
            for group in groups:
                import_small_group(g, cls, group)

def import_small_group(group_type, cls, group):
    req_url = canvas_domain + "api/v1/accounts/1/courses"
    payload = {"account_id":"1", 
               "course[name]":group_type, 
               "course[course_code]":"group "+group["group"], 
               "course[class]":cls, 
               "course[hide_final_grades]":"true", 
               "offer":"true"}
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.post(req_url, headers=headers, data=payload)
    if res.status_code == 200:
        print "creation for " + group_type + " group successful"
        json = res.json()
        course_id = json["id"]
        enroll_group(course_id, group)
    else:
        print "creation for " + group_type + " group failed: " + res.text

def enroll_group(course_id, group):
    tutor = group["tutor"]
    enroll_user(tutor["login"], "TeacherEnrollment", course_id)
    if "assistant" in group:
        ta = group["assistant"]
        enroll_user(ta["login"], "TaEnrollment", course_id)
    for tutee in group["tutees"]:
        enroll_user(tutee["login"], "StudentEnrollment", course_id)
        
def get_groups(group, cls):
    req_url =  "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/tutoring/taught/smallgroup/" + group + "/" + cls
    res = requests.get(req_url, auth=(user, passwd))
    return res.json()

def get_classes(group):
    classes = []
    class_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/tutoring/taught/smallgroup/" + group
    res = requests.get(class_url, auth=(user, passwd))
    for c in res.json():
        classes.append(c["class"])
    return classes
    
def get_group_type():
    types = []
    group_url = "https://dbc.doc.ic.ac.uk/api/teachdbs/views/curr/tutoring/taught/smallgroup/"
    group_res = requests.get(group_url, auth=(user, passwd))
    for g in group_res.json():
        types.append(g["type"])
    return types

if __name__ == "__main__":
    user = sys.argv[1]
    passwd = sys.argv[2]
    import_small_groups()

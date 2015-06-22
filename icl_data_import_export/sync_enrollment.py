import sys
import requests, json

canvas_domain = "http://146.169.47.160:3000/"
canvas_access_token = "2Zg8KXWMNmt4LTukfYCJ1E50KoV4gJ7gGrydLrATH3BOgc1PJZ0g4L4CUuU9U8oP" #This never expires for this domain
data_dir = "data_dump/enrollments.txt"

def sync_enrollment():
    print "syncing"
    enrolled = read_enrollment()
    change = False
    for course in enrolled:
        print "course: " + course
        curr_enrollment = get_enrollment(course)
        if len(curr_enrollment) != 0:
            enrollment = enrolled[course]
            for e in curr_enrollment:
                if e not in enrollment:
                    print e + " is not enrolled in " + str(course) + " anymore"
                    delete_enrollment(curr_enrollment[e])
                    change = True
    if not change:
        print "No change detected"

def delete_enrollment((enrollment_id, course_id)):
    req_url = canvas_domain + "api/v1/courses/" + str(course_id) + "/enrollments/" + str(enrollment_id)
    payload = {"task":"delete"}
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.delete(req_url, headers=headers, data=payload)
    if res.status_code == 200:
        print "enrollment " + str(enrollment_id) + " for course " + str(course_id) + " has been successfully deleted"
    else:
        print "failed deleting enrollment " + str(enrollment_id) + " for course " + str(course_id)

def get_enrollment(course_code):
    enrollment = {}
    req_url = canvas_domain + "api/v1/accounts/1/course_code/" + str(course_code) + "/student_enrollments" 
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.get(req_url, headers=headers)
    for e in res.json():
        enrollment[e["user"]["login_id"]] = (e["id"], e["course_id"])
    return enrollment

def read_enrollment():
    students = []
    enrolled = {}
    with open(data_dir, "rb") as file:
        content = file.readlines()
        content = [x.strip('\n') for x in content]
        first_line = content[0]
        course_code = first_line.split("\t")[0]
        for line in content:
            data = line.split("\t")
            if int(data[2]) >= 2:
                if data[0] == course_code:
                    students.append(data[1])
                else:
                    enrolled[course_code] = students
                    course_code = data[0]
                    students = []
                    students.append(data[1])
    return enrolled

if __name__ == "__main__":
    sync_enrollment()

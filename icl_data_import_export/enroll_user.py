import requests, json

canvas_domain = "http://146.169.47.160:3000/"
canvas_access_token = "2Zg8KXWMNmt4LTukfYCJ1E50KoV4gJ7gGrydLrATH3BOgc1PJZ0g4L4CUuU9U8oP" #This never expires for this domain

def enroll_user(user_login, enrollment_type, course_id):
    req_url = canvas_domain + "/api/v1/courses/" + str(course_id) + "/enrollments"
    payload = {"enrollment[login]":user_login, 
               "enrollment[type]":enrollment_type, 
               "enrollment[enrollment_state]":"active"}
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.post(req_url, headers=headers, data=payload)
    if res.status_code == 200:
        print "enrollment for " + user_login + " for course " + str(course_id) + " successful"
    else:
        print "enrollment for " + user_login + " for course " + str(course_id) + " failed: " + res.text

if __name__ == "__main__":
    user_login = sys.argv[1]
    enrollment_type = sys.argv[2]
    course_id = sys.argv[3]
    import_enroll_user(user_login, enrollment_type, course_id)

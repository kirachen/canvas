import sys
import requests, json
import csv

canvas_domain = "http://146.169.47.160:3000/"
canvas_access_token = "2Zg8KXWMNmt4LTukfYCJ1E50KoV4gJ7gGrydLrATH3BOgc1PJZ0g4L4CUuU9U8oP" #This never expires for this domain

def import_grades_by_class(cls):
    req_url = canvas_domain + "/api/v1/accounts/1/courses_in?class="+cls
    headers = {'Authorization': 'Bearer ' + canvas_access_token}
    res = requests.get(req_url, headers=headers)
    for course in res.json():
        if not is_small_group_course(course):
            req_url = canvas_domain + "/api/v1/courses/" + str(course["id"]) + "/grades"
            headers = {'Authorization': 'Bearer ' + canvas_access_token}
            res = requests.get(req_url, headers=headers)
            rows = res.text.split("\n")
            reader = csv.reader(rows)
            output_file = "grades_" + course["course_code"] + "_" + cls + ".csv"
            resultFile = open("grades/" + output_file, "wb")
            wr = csv.writer(resultFile, dialect='excel')
            for row in reader:
                wr.writerow(row)

def is_small_group_course(course):
    return course["name"] == "PPT" or course["name"] == "PMT" or course["name"] == "MMT" or course["name"] == "JMT"

if __name__ == "__main__":
    cls = sys.argv[1]
    import_grades_by_class(cls)

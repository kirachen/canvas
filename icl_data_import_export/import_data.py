import sys
import import_courses
import import_small_groups
import import_users

def import_data(user, passwd):
  import_users.user = user
  import_users.passwd = passwd
  import_users.import_users()
  import_small_groups.user = user
  import_small_groups.passwd = passwd
  import_small_groups.import_small_groups()
  import_courses.user = user
  import_courses.passwd = passwd
  import_courses.import_courses()

if __name__ == "__main__":
    user = sys.argv[1]
    passwd = sys.argv[2]
    import_data(user, passwd)

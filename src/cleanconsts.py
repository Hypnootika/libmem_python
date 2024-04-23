import re
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
gen_file = os.path.join(current_dir, "libmem/libmem.h")

with open(gen_file, "r+") as file:
    filedata = file.read()
    filedata = re.sub(r"\(const", "(", filedata, 0, re.MULTILINE)
    file.seek(0)
    file.write(filedata)
    file.truncate()

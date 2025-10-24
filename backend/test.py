from flask_bcrypt import Bcrypt
bcrypt = Bcrypt()

hashed_pw = bcrypt.generate_password_hash("0920").decode("utf-8")
print(hashed_pw)
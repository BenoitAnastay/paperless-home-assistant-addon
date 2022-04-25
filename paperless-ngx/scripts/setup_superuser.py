import os

from django.contrib.auth import get_user_model
from django.db.utils import IntegrityError

USERNAME = os.getenv("DEFAULT_USERNAME")
EMAIL = os.getenv("DEFAULT_EMAIL")
PASSWORD = os.getenv("DEFAULT_PASSWORD")

try:
    User = get_user_model()
    User.objects.create_superuser(USERNAME, EMAIL, PASSWORD)
    print("Default admin user created")
except IntegrityError as error:
    print("User already created. Skiping...")

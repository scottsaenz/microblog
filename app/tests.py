import os
os.environ['DATABASE_URL'] = 'sqlite://'

from datetime import datetime, timezone, timedelta
import unittest
from app import app, db
from app.models import User, Post

class UserModelCase(unittest.TestCase):
  def setUp(self):
    self.app_context = app.app_context()
    self.app_context.push()
    db.create_all()
    
  def teardown(self):
    db.session.remove()
    db.drop_all()
    self.app_context.pop()
    
  def test_password_hashing(self):
    u = User(username='susan', email='susan@example.com')
    u.set_password('cat')
    self.assertFalse(u.check_password('dog'))
    self.assertTrue(u.check_password('cat'))
    
  def test_avatar(self):
    u = User(username='john', email='john@example.com')
    self.assertEqual(u.avatar(128), ('https://www.gravatar.com/avatar/'))
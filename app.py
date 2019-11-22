from flask import Flask

from __init__ import db, login_manager
from views import view

app = Flask(__name__)

# Routing
app.register_blueprint(view)

# Config
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://{username}:{password}@{host}:{port}/{database}'\
    .format(
        username='postgres',
        password='password',
        host='127.0.0.1',
        port=5432,
        database='postgres'
)
app.config['SECRET_KEY'] = 'cWNNnECxbA8aMra5'

# Initialize other components
db.init_app(app)
login_manager.init_app(app)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)

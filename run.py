import os
from app import create_app

env = os.environ.get('APP_ENV', 'dev')
app = create_app('app.config.%sConfig' % env.capitalize())

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=app.config['PORT'], debug=app.config['DEBUG'])

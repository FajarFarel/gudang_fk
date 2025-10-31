from flask import Flask, render_template, jsonify
import os

app = Flask(__name__)

app.config['SECRET_KEY'] = os.environ.get('SESSION_SECRET', 'dev-secret-key-change-in-production')

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/api/health')
def health():
    return jsonify({'status': 'healthy', 'message': 'Flask app is running!'})

@app.route('/api/info')
def info():
    return jsonify({
        'app': 'Flask Hosting App',
        'version': '1.0.0',
        'environment': os.environ.get('FLASK_ENV', 'production')
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)

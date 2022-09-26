from flask import Flask         # import Flask Class from flask module
from datetime import datetime   # import datetime class from datetime module

app = Flask(__name__) # Passing a special variable called __name__ to Flask Class

@app.route('/') # tells flask http://127.0.0.1:5000 URL to trigger
def display_message(): # function 1
    return 'Automate All The Things'

@app.route('/time') # tells flask  http://127.0.0.1:5000/time URL to trigger
def display_time (): # function 2 
    now = datetime.now() # 
    current_time = now.strftime("%H:%M:%S")
    return current_time

if __name__ == "__main__":
    app.run(debug=True)
from exchangelib import Credentials, Account, DELEGATE
import time
import os

# Define your Outlook credentials
email_address = 'your_email@example.com'
password = 'your_password'

# Connect to Outlook account
credentials = Credentials(email_address, password)
account = Account(email_address, credentials=credentials, autodiscover=True, access_type=DELEGATE)

# Specify the path for your notepad file
notepad_path = 'path/to/your/notepad.txt'

def open_notepad():
    # Open the notepad file in append mode
    return open(notepad_path, 'a')

def close_notepad(notepad_file):
    # Close the notepad file
    notepad_file.close()

def check_emails(notepad_file):
    # Fetch unread emails from Inbox
    for item in account.inbox.filter(is_read=False):
        # Check if your name is in To or CC list
        if email_address.lower() in [contact.email_address.lower() for contact in item.to_recipients] or \
           email_address.lower() in [contact.email_address.lower() for contact in item.cc_recipients]:
            
            # Read the email subject and body
            subject = item.subject
            body = item.text_body

            # Generate a task in notepad
            notepad_file.write(f'Task for today: {subject}\n')
            notepad_file.write(f'Email Body: {body}\n\n')

            # Mark the email as read
            item.is_read = True
            item.save()

def check_follow_up_tasks():
    # Check previous tasks from notepad
    with open(notepad_path, 'r') as notepad_file:
        tasks = notepad_file.readlines()

    # Check for follow-up conversations
    for task in tasks:
        if 'Task for today:' in task:
            print(task.strip())
            # Implement your logic to check follow-up conversations here

if __name__ == "__main__":
    # Open the notepad file
    notepad_file = open_notepad()

    try:
        while True:
            # Check emails every 30 minutes
            check_emails(notepad_file)

            # Check follow-up tasks
            check_follow_up_tasks()

            # Wait for 30 minutes
            time.sleep(1800)
    finally:
        # Close the notepad file when the script exits
        close_notepad(notepad_file)

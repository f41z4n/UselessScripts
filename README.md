# UselessScripts
A collection of Useless Scripts for IT Maintenance

##MacAutoShutdown.sh
🧠 Purpose
This script enforces an automated shutdown policy on macOS devices to ensure they are restarted regularly for optimal performance and compliance.

It is designed to:

Warn users after 1 day of continuous uptime

Allow them to postpone shutdown once by 1 day

Give a final warning after 2 days of uptime, with a 1-hour postponement option

Always provide a “Shutdown Now” button in every popup for immediate action

🔍 Behavior Summary
Uptime	What Happens
< 1 day	❌ Nothing
1 day	⚠ Popup: Shutdown tomorrow → Options: Shutdown Now, Delay (1 day), Dismiss
2 days	⚠ Popup: Shutdown in 1 hour → Options: Shutdown Now, Delay (1 hour), Dismiss
After 2 days + no response	💣 Automatic shutdown in 1 hour
Postponement is tracked via a file:
/var/tmp/nanoprecise_shutdown_postponed

⚙️ File Contents
AutoShutdown_Mac_Test.sh — the main script file

README.txt — this file

🚀 How to Deploy (Manual or Intune/JAMF)
Option 1: Manual Test
Open Terminal

Run:

bash
Copy
Edit
sudo bash AutoShutdown_Mac_Test.sh
Option 2: Deploy via Intune
Go to Microsoft Endpoint Manager

Navigate to Devices > macOS > Shell Scripts > Add

Upload AutoShutdown_Mac_Test.sh

Set:

Run script as signed-in user: No

Frequency: Daily

Hide script notifications: No

Assign to target test devices

Option 3: Deploy via JAMF
Create a new policy

Add script as a payload

Set to run as root

Trigger: Recurring Check-in or Startup/Login

✅ Post-Test Cleanup
To reset the test state:

bash
Copy
Edit
sudo rm /var/tmp/nanoprecise_shutdown_postponed
🛠️ Customization for Production
To prepare the script for real-world deployment:

Change these lines:

bash
Copy
Edit
shutdownFirstWarningDay=7
shutdownFinalDay=8
(Optional) Log events or send email notifications to IT

(Optional) Rename script to: AutoShutdown_Mac_Production.sh

🔒 Permissions
The script must run as root to execute shutdown commands

If deploying via Intune, configure script to run as system

📬 Support
For questions or modifications, contact the Nanoprecise IT Admin Team.
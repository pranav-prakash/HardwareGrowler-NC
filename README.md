HardwareGrowler-NC
==

Hardware growler was a nice addition to growl. Unfortunately, the 10.7 update brought a notification center which superseded growl. HardwareGrowler was then updated to support notification center, but unfortunately due to apple's API limitations the notification icon is just the app icon, losing valuable information about the event change that was there with the growl notification.

Luckily, apple has a hidden private api for displaying auxiliary information in addition to the app icon, used for itunes cover art within notifications. We can leverage this to recreate a style similar to growl's old notifications.
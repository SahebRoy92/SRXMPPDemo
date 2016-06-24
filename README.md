# SRXMPPDemo

----------

A demo on XMPP in Objective C, with various simple and complex features implemented in it.
Few features this project contains are --


**SRXMPP** - A wrapper Singleton class that almost has all features needed for one-to-one chat application.

 - one to one chat
 - Core data implementation of chat (text message) thus having saving of previous messages, offline messages.
 - implementation of vCard(profile information of user, own and others too) from XML and Core Data provided by Robbie Hanson's own framework.
 - availability of friends status (online/offline,typing)

----------
# Steps to follow 

You want to use this project as a reference then you can do the following-- 

**1. Installed Openfire in a live server**	 - Rent a server, install openfire.

**2. Want to try it out without a hassle in your own computer** - 
You need to download, install and setup 3 things to start

**a. Java -** 
 - Download and install Java for Mac.
  
**b. XAMPP** - 
 
 - Install XAMPP is relatively easy. 
 - After installation just start the XAMPP and start **Database(SQL)** and **Apache Server**.
  ![reference image - ](http://imgur.com/mXQmnhh)
 - Then open browser and paste this URL 
[*http://localhost/phpmyadmin/*](http://localhost/phpmyadmin/)
 - . Create a new DB from the left hand side panel.
 - **Name the DB anything but remember this name, suppose we name it ChatDB** 
 

**c. Openfire** -

 * Install Openfire and run the application and "Start Openfire"
 ![reference image - ](http://imgur.com/Ct8ft15)
 * Open Browser and Paste this URL - [http://localhost:9090/setup/index.jsp](http://localhost:9090/setup/index.jsp)
 * Do normal setup 
	 * Select Language >
	 * Server settings, leave as it is, just do continue > 
	 * Database Settings, leave as it is as "Standard Database Connection as selected > 
	 * Database Settings - Standard Connection" ref page.. 
  Now remember the name of the DB you set was **ChatDB**. 
	 * Select Database Driver Presets as **" *MySQL"**. Leave JDBC Driver Class as it is. Now in the Database URL you can see, brackets mentioning hostname and Database Name. Just change Hostname to **"localhost"**, and database name to **"ChatDB"**, or any other name of DB you have set earlier, while seting up XAMPP. Fill up details like the image here ![image reference](http://imgur.com/BKRBG3c). Leave the Username and password as blank. 
	 * Next complete setup by giving a username and password and reconfirming it.
Thats it your done Setting up Openfire.

Now the part comes when you have to change a tiny detail in the code.

 We need to go to the class 
**SRXMPP.m** locate the NSString extern **SRXMPP_Hostname** (in the top) and overwrite the value of it to the IP of the server where openfire is installed , or if you have installed it locally, overwrite the value to -  **"localhost"**.

Thats it, you are ready to use this example project and start coding and making it into a better project of your own.
This starter pack will help you in understanding XMPP structure better as well as getting a grasp into XMPP protocols.

You can find other XMPP protocols here in this site - [https://xmpp.org/rfcs/rfc3920.html](https://xmpp.org/rfcs/rfc3920.html)

In short this example project along with the singleton has almost all features that are needed for a One-to-One chat application to have.
Share and help this example get better.
A big thanks to Robbie Hanson for the awesome XMPP objective C framework. Cheers.

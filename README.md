# SRXMPPDemo

This project contains a fork of Robbie Hanson XMPP framework for iOS
A big thanks to Robbie for creating and maintaining this framework.

** SRXMPP DEMO **

A demo on XMPP in Objective C, with various simple and complex features implemented in it.
Few features this project contains are --


**SRXMPP** - A wrapper Singleton class that almost has all features needed for one-to-one chat application.
* one to one chat
* Core data implementation of chat thus having saving of previous messages, offline messages.
* implementation of vCard(profile information of user, own and others too) from XML and Core Data provided by Robbie Hanson's own framework.
* availability of friends status (online/offline,typing)

# Steps to follow 

You want to use this project as a reference and you -- 

**1. Installed Openfire in a live server ** - Rent a server, install openfire.

**2. Want to try it out without a hassle in your own computer** - 

You need to download, install and setup 2 things to start 
 *XAMPP - 
 
 * Install XAMPP is relatively easy. 
 * After installation just start the XAMPP and start Database(SQL) and Apache Server.
 * Then open browser and paste this URL *http://localhost/phpmyadmin/*. Create a new DB from the left hand side panel.
 * **Name the DB anything but remember this name, suppose we name it ChatDB** 
 
 *Openfire* - 

There is although 1 step we need to do to use this example project as reference. We need to go to the class 
**SRXMPP.m** locate the NSString extern **SRXMPP_Hostname** (in the top) and overwrite the value of it to the IP of the server, or if you have installed it locally, **"localhost"**.

In short this example project along with the singleton has almost all features that are needed for a One-to-One chat application to have.
Share and help this example get better.
A big thanks to Robbie once again for the awesome framework. Cheers.

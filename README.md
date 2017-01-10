InstagramAuthProvider
=====================

A custom Auth Provider for Instagram

Overview
--------
This project provides an example custom Auth Provider for Instagram. 

Getting Started
---------------
Use the [Salesforce Migration Tool](https://developer.salesforce.com/docs/atlas.en-us.daas.meta/daas/meta_development.htm) to install this unpackaged Apex. It will create a Custom Metadata Type as well as an Apex Class for handling the flow with Instagram, and an example Registration Handler as well.

You will need to create a new Instagram app in their [developer environment](https://www.instagram.com/developer/) in order to get a key and secret.

Some things to keep in mind
--------------------------
Instagam's user model is simple; it doesn't have a lot of attributes. For example, Instagram *does not* have email addresses for its users. (This is true even if the person uses Facebook to log into Instagram.) Because of this, the example Registration Handler has to create an email-like attribute for both the User's email and username fields.

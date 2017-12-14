InstagramAuthProvider
=====================

A custom Auth Provider for Instagram

Overview
--------
This project provides an example custom Auth Provider for Instagram. 

Getting Started
---------------
Use the [Salesforce Migration Tool](https://developer.salesforce.com/docs/atlas.en-us.daas.meta/daas/meta_development.htm) or Workbench to install this unpackaged Apex. It will create a Custom Metadata Type as well as an Apex Class for handling the flow with Instagram, and an example Registration Handler as well.

You will need to create a new Instagram app in their [developer environment](https://www.instagram.com/developer/) in order to get a key and secret.

Once you have a key and secret, you can create your Auth Provider instance. Recommend that you create the Auth Provider, then copy the Callback URL the system generates and paste it into the 'Redirect URL (Callback URL)' field. You need to do this because you must register your callback URLs with Instagram and, for now, custom Auth Providers do not have direct access to their associated Callback URL values.

Some things to keep in mind
--------------------------
Instagam's user model is simple; it doesn't have a lot of attributes. For example, Instagram *does not* have email addresses for its users. (This is true even if the person uses Facebook to log into Instagram.) Because of this, the example Registration Handler has to create an email-like attribute for both the User's email and username fields.

Easier Install Process
--------
Although the Apex classes are provided here, you can also use the [this unmanaged package](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1J000000PzH1) to load this custom Auth Provider into your org.

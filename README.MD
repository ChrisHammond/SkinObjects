You should put this repo in your DesktopModules folder, so the path would be /desktopmodules/SkinObjects/

Then, in your skin, add the lines to add a Skin object

<%@ Register TagPrefix="dnn" TagName="LOGINRESTRICTION" Src="~/DesktopModules/SkinObjects/LoginRestriction.ascx" %>

<dnn:loginrestriction runat="server" id="loginRestriction"/>


In the ASCX File for the LoginRestriction there is a line: 

Response.Redirect("/test.aspx", false);

You can change that url to a different page on your site, I would recommend you setup a page with a "friendly" message that tells the user something like "you've been logged out as another device has accessed your account". Then you will probably want to provide them a login link. 


The SkinObject will create a ProfileProperty "LoginKey", right now it is hard coded to the datatype "349" which I believe MOST DNN sites will have as TEXT. You can run this SQL in your DNN database to see if that value is different, the, the "entryid" column is the one you want.

select * from lists where text like '%DotNetNuke.UI.WebControls.TextEditControl, DotNetNuke%'


The code in the SkinObject isn't pretty right now, but I believe it is functional at this point. Here are the scenarios for which this will work

Login with Browser A, navigate the site, and remain logged in with a cookie set.

Login with Browser B, (same user), navigate the site, and remain logged in.

After logging in with Browser B, if I try to do anything in Browser A, I am logged out and redirected to the "test.aspx" page I setup.

If I log back in with Browser A, then the next time Browser B does anything, B will be logged out and redirected.



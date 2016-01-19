<%@ control language="C#" inherits="DotNetNuke.Entities.Modules.PortalModuleBase" %>
<%@ import namespace="System.Web" %>
<%
    if (HttpContext.Current.User.Identity.IsAuthenticated && UserId > 0)
        {
            if (
                DotNetNuke.Entities.Profile.ProfileController.GetPropertyDefinitionByName(PortalId,
                    "LoginKey") == null)
            {
                DotNetNuke.Entities.Profile.ProfileController.AddPropertyDefinition(
                    new DotNetNuke.Entities.Profile.ProfilePropertyDefinition(this.PortalId)
                    {
                        PropertyName = "LoginKey",
                        DataType = 349,
                        //text type //TODO: get list type DotNetNuke.UI.WebControls.TextEditControl, DotNetNuke
                        DefaultValue = string.Empty,
                        Visibility = UserVisibilityMode.AdminOnly,
                        PropertyCategory = "AdminValues",
                        Length = 50
                    });
            }

            var loggedInUser = DotNetNuke.Entities.Users.UserController.GetUser(PortalId, UserId, true);

            if (loggedInUser != null)
            {
                var loginKey = loggedInUser.Profile.GetPropertyValue("LoginKey");

                //User has no login key on their profile
                if (loginKey == string.Empty || loginKey == null)
                {
                    loginKey = Guid.NewGuid().ToString();

                    //Set the profile property
                    loggedInUser.Profile.SetProfileProperty("LoginKey", loginKey);


                    //Create the cookie
                    HttpCookie myCookie = new HttpCookie("LoginKey");
                    DateTime now = DateTime.Now.AddDays(180);

                    //Set the cookie value.
                    myCookie.Value = loginKey;
                    // Set the cookie expiration date.
                    myCookie.Expires = now;

                    //Add the cookie.
                    Response.Cookies.Add(myCookie);
                    //Save the DNN user properties
                    UserController.UpdateUser(PortalId, loggedInUser);
                }
                else
                {
                    //They already have a login key, let's check it against the cookie
                    HttpCookie myCookie = new HttpCookie("LoginKey");
                    myCookie = Request.Cookies["LoginKey"];

                    //If cookie exists
                    if (myCookie != null)
                    {
                        var cookieKey = myCookie.Value;

                        //Check if the cookie matches the profile property
                        if (loginKey != cookieKey)
                        {
                            //Cookie doesn't match, time to log the individual out and delete the cookie
                            var delCookie = new HttpCookie("LoginKey");
                            DateTime now = DateTime.Now.AddDays(-5);

                            // Set the cookie value.
                            delCookie.Value = string.Empty;
                            // Set the cookie expiration date.
                            delCookie.Expires = now;
                            // Add the cookie back to delete it
                            Response.Cookies.Add(delCookie);

                            //Log the user out
                            var curPortal = PortalController.GetCurrentPortalSettings();
                            //Remove user from cache
                            DataCache.ClearUserCache(curPortal.PortalId, UserController.GetCurrentUserInfo().Username);
                            var objPortalSecurity = new PortalSecurity();
                            objPortalSecurity.SignOut();

                            //Redirect somewhere (change this)
                            Response.Redirect("/test.aspx", false);

                        }
                    }

                    else
                    {
                        //no cookie found, time to reset the GUID and set a new cookie

                        loginKey = Guid.NewGuid().ToString();

                        //Set the profile property
                        loggedInUser.Profile.SetProfileProperty("LoginKey", loginKey);

                        //Create the cookie
                        var newCookie = new HttpCookie("LoginKey");
                        DateTime now = DateTime.Now.AddDays(180);

                        //Set the cookie value.
                        newCookie.Value = loginKey;
                        // Set the cookie expiration date.
                        newCookie.Expires = now;

                        //Add the cookie.
                        Response.Cookies.Add(newCookie);
                        //Save the DNN user properties
                        UserController.UpdateUser(PortalId, loggedInUser);
                    }
                }
            }
        }
        else
        {
            //let's make sure the cookie is gone
            var delCookie = new HttpCookie("LoginKey");
            DateTime now = DateTime.Now.AddDays(-5);
            // Set the cookie value.
            delCookie.Value = string.Empty;
            // Set the cookie expiration date.
            delCookie.Expires = now;
            // Add the cookie back to delete it
            Response.Cookies.Add(delCookie);
        }

%>
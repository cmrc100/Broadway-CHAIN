public class Session
{
    public Session(ApexPages.StandardController controller)
    {

    }
    
    public PageReference redirectSession()
    {
        PageReference objPage = new PageReference('/a0I/e');
        User u = [Select Id, Default_Project_Id__c, Default_Project_Name__c from User where Id=:UserInfo.getUserId()];
        objPage.getParameters().put('CF00NC0000004aqka_lkid', u.Default_Project_Id__c);
        objPage.getParameters().put('CF00NC0000004aqka', u.Default_Project_Name__c);
        objPage.getParameters().put('nooverride', '1');
        objPage.setRedirect(true);
        return objPage;
    }
    
    static testMethod Void testRedirect()
    {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Session__c());
        Session sess = new Session(sc);
        PageReference p = sess.redirectSession();
        User u = [Select Id, Default_Project_Id__C, Default_Project_Name__C from User where Id=:UserInfo.getUserId()];
        System.assertEquals( u.Default_Project_Name__C, p.getParameters().get('CF00NC0000004aqka') );
    }
}
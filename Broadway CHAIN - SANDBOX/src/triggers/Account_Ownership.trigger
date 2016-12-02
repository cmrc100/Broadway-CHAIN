trigger Account_Ownership on Account (before insert) {
    for (Account a : Trigger.new) {
        String UserId = UserInfo.getUserId();
        String UserEmail = [SELECT Email FROM User WHERE Id = :UserId].Email;
        
        if (UserEmail.toLowerCase().contains('cstm')) {
            a.Ownership = 'CSTM';
        } else if (UserEmail.toLowerCase().contains('mungo')) {
            a.Ownership = 'St Mungo\'s';
        } else if (UserEmail.toLowerCase().contains('thames')) {
            a.Ownership = 'Thames Reach';
        } else if (UserEmail.toLowerCase().contains('passage')) {
            a.Ownership = 'Passage';
        } else if (UserEmail.toLowerCase().contains('wlm')) {
            a.Ownership = 'WLDC';
        }
    }
}
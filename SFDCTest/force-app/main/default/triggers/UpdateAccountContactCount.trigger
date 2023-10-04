trigger UpdateAccountContactCount on Contact (after insert, after update, after delete, after undelete) {
    Set<Id> oldAccountIdsToUpdate = new Set<Id>();
    Set<Id> newAccountIdsToUpdate = new Set<Id>();

    // Handle inserts and updates
    for (Contact contact : Trigger.new) {
        // Track both old and new Account Ids
        if (contact.AccountId != null) {
            newAccountIdsToUpdate.add(contact.AccountId);
        }
        if (Trigger.isUpdate) {
            Contact oldContact = Trigger.oldMap.get(contact.Id);
            if (oldContact != null && oldContact.AccountId != contact.AccountId) {
                oldAccountIdsToUpdate.add(oldContact.AccountId);
            }
        }
    }
    if(Trigger.isDelete){
    for (Contact contact : Trigger.old) {
        if (contact.AccountId != null) {
            oldAccountIdsToUpdate.add(contact.AccountId);
        }
    }
    }

    // Query the count of Contacts for old and new Accounts
    Map<Id, Integer> accountContactCountMap = new Map<Id, Integer>();
    
    // Query and update old Accounts
    List<Account> oldAccountsToUpdate = [
        SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :oldAccountIdsToUpdate
    ];
    for (Account oldAccount : oldAccountsToUpdate) {
        accountContactCountMap.put(oldAccount.Id, oldAccount.Contacts.size());
    }

    // Query and update new Accounts
    List<Account> newAccountsToUpdate = [
        SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :newAccountIdsToUpdate
    ];
    for (Account newAccount : newAccountsToUpdate) {
        accountContactCountMap.put(newAccount.Id, newAccount.Contacts.size());
    }

    // Update the "Number_of_Contacts__c" field on both old and new Accounts
    List<Account> accountsToUpdate = new List<Account>();
    for (Id accountId : oldAccountIdsToUpdate) {
        Integer contactCount = accountContactCountMap.get(accountId);
        if (contactCount == null) {
            contactCount = 0; // Set the count to 0 if no Contacts are found
        }

        accountsToUpdate.add(new Account(
            Id = accountId,
            Number_of_Contacts__c = contactCount
        ));
    }

    for (Id accountId : newAccountIdsToUpdate) {
        Integer contactCount = accountContactCountMap.get(accountId);
        if (contactCount == null) {
            contactCount = 0; // Set the count to 0 if no Contacts are found
        }

        accountsToUpdate.add(new Account(
            Id = accountId,
            Number_of_Contacts__c = contactCount
        ));
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
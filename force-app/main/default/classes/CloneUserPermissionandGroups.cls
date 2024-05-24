public class CloneUserPermissionandGroups {
	@AuraEnabled(cacheable=true)
    public static list<user> FetchUsers(String KeyWord){
        List<User> users = [SELECT Id, Name, Email FROM User WHERE Name LIKE :('%' + KeyWord + '%') AND IsActive = True];
        return users;
    }
    
    @AuraEnabled
    public static void Clone(String UserId, String CloneId,Boolean IsPS,Boolean IsPGQ, Boolean IsPSA){
        if(IsPS){
           ClonePS(UserId,CloneId);
        }
        if(IsPGQ){
           ClonePGQ(UserId,CloneId);
        }
        if(IsPSA){
          ClonePSA(UserId,CloneId);  
        }
    }
    
    public static void ClonePS(String UserId, String CloneId){
        //Query CloneId
        list<PermissionSetAssignment>ClonePSlist = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: CloneId AND PermissionSet.ProfileId = null];
        if (ClonePSlist.isEmpty()) {
        	throw new IllegalArgumentException('No permission set asigned to clone user');
    	}
        Set<Id> clonePSIds = new Set<Id>();
    	for (PermissionSetAssignment ps : ClonePSlist) {
        	clonePSIds.add(ps.PermissionSetId);
    	}
        
        //Query UserId
        list<PermissionSetAssignment>UserPS = [SELECT Id,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserId AND PermissionSet.ProfileId = null];
        Set<Id> userPSIds = new Set<Id>();
    	for (PermissionSetAssignment ps : UserPS) {
        	userPSIds.add(ps.PermissionSetId);
    	}
        
        //New and Delete lists
        list<PermissionSetAssignment>NewPS = new list<PermissionSetAssignment>();
        list<PermissionSetAssignment>DeletePS = new list<PermissionSetAssignment>();
        
        //Process New List
        for(PermissionSetAssignment i : ClonePSlist){
            if(!userPSIds.contains(i.PermissionSetId)){
                PermissionSetAssignment PS = new PermissionSetAssignment();
                PS.AssigneeId = UserId;
                PS.PermissionSetId = i.PermissionSetId;
                NewPS.add(PS);
            }
        }
        
        //Process Delete list
        for (PermissionSetAssignment j : UserPS) {
            if (!clonePSIds.contains(j.PermissionSetId)) {
                PermissionSetAssignment PS = new PermissionSetAssignment();
                PS.Id = j.Id;
                DeletePS.add(PS);
            }
        }
        
        //Insert
        if(!NewPS.isEmpty()){
            try{
                insert NewPS;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        //Delete
        if(!DeletePS.isEmpty()){
            try{
                delete DeletePS;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    public static void ClonePGQ(String UserId, String CloneId){
        //Query clone
        list<GroupMember>ClonePGQlist = [SELECT Id,GroupId FROM GroupMember WHERE UserOrGroupId =: CloneId];
        if(ClonePGQlist.isEmpty()){
            throw new IllegalArgumentException('No groups asigned to clone user');
        }
        Set<Id> clonePGQIds = new Set<Id>();
    	for (GroupMember psq : ClonePGQlist) {
        	clonePGQIds.add(psq.GroupId);
    	}
        //Query User
        list<GroupMember>UserPGQlist = [SELECT Id,GroupId FROM GroupMember WHERE UserOrGroupId =: UserId];
        Set<Id> userPGQIds = new Set<Id>();
    	for (GroupMember psq : UserPGQlist) {
        	userPGQIds.add(psq.GroupId);
    	}
        
        list<GroupMember>NewPGQlist = new list<GroupMember>();
        list<GroupMember>DeletePGQlist = new list<GroupMember>();
        //Process Insert
        for(GroupMember i : ClonePGQlist){
            if(!userPGQIds.contains(i.GroupId)){
                GroupMember GPQ = new GroupMember();
                GPQ.UserOrGroupId = UserId;
                GPQ.GroupId = i.GroupId;
                NewPGQlist.add(GPQ);
            }
        }
        //Process Delete
        for(GroupMember j : UserPGQlist){
            if(!clonePGQIds.contains(j.GroupId)){
                GroupMember GPQ = new GroupMember();
                GPQ.Id = j.Id;
                DeletePGQlist.add(GPQ);
            }
        }
        if(!NewPGQlist.isEmpty()){
            try{
                insert NewPGQlist;
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        if(!DeletePGQlist.isEmpty()){
            try{
               delete DeletePGQlist; 
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
    }
    
   public static void ClonePSA(String UserId, String CloneId){
       //Query Clone
        list<PermissionSetLicenseAssign>ClonePSAlist = [SELECT Id,PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId =: CloneId];
        if (ClonePSAlist.isEmpty()) {
        	throw new IllegalArgumentException('No groups permission set license assigned to clone user');
    	}
       	Set<Id> clonePSAIds = new Set<Id>();
    	for (PermissionSetLicenseAssign psa : ClonePSAlist) {
        	clonePSAIds.add(psa.PermissionSetLicenseId);
    	}
       	//Query User
        list<PermissionSetLicenseAssign>UserPSA = [SELECT Id,PermissionSetLicenseId FROM PermissionSetLicenseAssign WHERE AssigneeId =: UserId];
        Set<Id> userPSAIds = new Set<Id>();
    	for (PermissionSetLicenseAssign psa : UserPSA) {
        	userPSAIds.add(psa.PermissionSetLicenseId);
    	}
       list<PermissionSetLicenseAssign>NewPSA = new list<PermissionSetLicenseAssign>();
       list<PermissionSetLicenseAssign>DeletePSA = new list<PermissionSetLicenseAssign>();
       //Process Insert
        for(PermissionSetLicenseAssign i : ClonePSAlist){
            if(!userPSAIds.Contains(i.PermissionSetLicenseId)){
                PermissionSetLicenseAssign PS = new PermissionSetLicenseAssign();
                PS.AssigneeId = UserId;
                PS.PermissionSetLicenseId = i.PermissionSetLicenseId;
                NewPSA.add(PS);
            }
        }
       //Process Delete
        for(PermissionSetLicenseAssign j : UserPSA){
            if(!clonePSAIds.Contains(j.PermissionSetLicenseId)){
                PermissionSetLicenseAssign PS = new PermissionSetLicenseAssign();
                PS.Id = j.Id;
                DeletePSA.add(PS);
            }
        }
       if(!NewPSA.isEmpty()){
           try{
               insert NewPSA; 
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
           
       }
       if(!DeletePSA.isEmpty()){
           try{
               delete DeletePSA; 
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
       }
    } 
	
}
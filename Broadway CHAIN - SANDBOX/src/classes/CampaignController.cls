/*
###########################################################################
# Project Name..........: <<Broadway>>
# File..................: <<CampaignController.cls >>
# Version...............: << >>
# Created by............: <<Gulshan Middha>>
# Created Date..........: <<03-Mar-2010>>
# Last Modified by......: <<Gulshan Middha >>
# Last Modified Date....: << 03-Mar-2010>>
# Description...........: <<This class is used to rendere and sav ethe picklist value on the lef panel>>
# Copyright (c) 2000-2008. Astadia, Inc. All Rights Reserved.
#
# Created by the Astadia, Inc. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Astadia, Inc., is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: 2839 Paces Ferry Road, Suite 350, Atlanta, GA 30339
# Company URL : http://www.astadia.com
###########################################################################
*/
public without sharing class CampaignController 
{
	User u;
	public String selectedCampaign {get;set;} //get the already set campaign, so that it can be dafualted on load
	public CampaignController()
	{
		//Check of the logged in user is a Customer Portal User or a Standard Salesforce User
		u = [Select Id,ContactId,Default_Project_Id__c, Default_Project_Name__c from User where Id=: UserInfo.getUserId()];
		selectedCampaign = u.Default_Project_Id__c + '~' + u.Default_Project_Name__c;	
	}
	//Fetch the campaigns to list as a picklist. If user is a customer portal user, get the campaigns accosiated to the user's contact, from campaign memeber
	//If a user is non portal user, get all the active camappigns.
	public List<SelectOption> getCampaigns() 
	{
		List<SelectOption> options = new List<SelectOption>();
		 
		if(u.ContactId!=null)
			{
				List<CampaignMember> campaignMemberList = [Select CampaignId, Campaign.Id, Campaign.Name, ContactId from CampaignMember where ContactId=:u.ContactId AND Campaign.IsActive=true order by Campaign.Name limit 100];
				if(campaignMemberList!=null && campaignMemberList.size()>0)
				{
					for(CampaignMember cm: campaignMemberList)
					{
						options.add(new SelectOption(cm.Campaign.Id + '~' + cm.Campaign.Name,cm.Campaign.Name));
					}
				}
			}	
		else
			{
				List<Campaign> campaignList = [Select Id,Name from Campaign where isActive=true order by Name limit 1000];
				if(campaignList!=null && campaignList.size()>0)
				{
					for(Campaign c: campaignList)
					{
						options.add(new SelectOption(c.Id + '~' + c.Name,c.Name));
					}
				}
			}
		
				
		return options;
	}
	
	public string getDefaultProj() {
		List<User> newUs = [select id, Default_Project_Name__c from User where Id=:UserInfo.getUserId() limit 1];
		return newUs[0].Default_Project_Name__c;
	}
	
	public PageReference save()
	{
		//Save the selected value in User record
		if(selectedCampaign!=null)
		{
			String strCId = '';
			String strName = '';
			try{
			strCId = selectedCampaign.substring(0,selectedCampaign.indexOf('~'));
			strName =  selectedCampaign.substring(selectedCampaign.indexOf('~') + 1, selectedCampaign.length());
			}catch(Exception e){}
			if(strCId!=null || strName!=null)
			{	
				User newU = new User(Id=UserInfo.getUserId(), Default_Project_Id__c=strCId, Default_Project_Name__c=strName);
				update newU;
			}	
			
		}
		return null;
	}
}
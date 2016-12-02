/*
###########################################################################
# Project Name..........: <<Broadway  >>
# File..................: <<SupportNeedAssessment.cls >>
# Version...............: << >>
# Created by............: <<Rakesh Aggarwal>>
# Created Date..........: <<28-April-2010>>
# Last Modified by......: <<Rakesh Aggarwal>>
# Last Modified Date....: << >>
# Description...........: <<The class is being used by the SupportNeedAssessment page >>
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

public with sharing class SupportNeedAssessment {


	public SupportNeedAssessment(ApexPages.StandardController stdController)
    {
        
    }
    

	public PageReference redirectSupportNeedAssessment()
    {
		PageReference objPage = new PageReference('/a08/e');
		//objpage.getParameters().putAll(ApexPages.currentPage().getParameters());
		objpage.getParameters().put('nooverride', '1');
		objpage.getParameters().put('CF00N80000004HMgQ', ApexPages.currentPage().getParameters().get('CF00N80000004HMgQ'));
		objpage.getParameters().put('CF00N80000004HMgQ_lkid', ApexPages.currentPage().getParameters().get('CF00N80000004HMgQ_lkid'));
		objpage.getParameters().put('_CONFIRMATIONTOKEN', ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN'));
		objpage.getParameters().put('RecordType', ApexPages.currentPage().getParameters().get('RecordType'));
		objpage.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
		objpage.getParameters().put('Name','Updated on save');
		objPage.setRedirect(true);
    	return objPage;
    }
    
    
    //test method
    public static testMethod void testSupportNeedAssessment(){
    
    	ApexPages.StandardController con = new ApexPages.StandardController(new Support_Needs_Assessment__c());
    	SupportNeedAssessment objSupportNeedAssessment = new SupportNeedAssessment(con);
    	objSupportNeedAssessment.redirectSupportNeedAssessment();	
    	
     
    }
    
    
    
}
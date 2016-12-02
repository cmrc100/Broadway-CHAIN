/*
###########################################################################
# Project Name..........: <<Broadway  >>
# File..................: <<reportController.cls >>
# Version...............: << >>
# Created by............: <<Gulshan Middha>>
# Created Date..........: <<20-Jan-2009>>
# Last Modified by......: <<David Sekules >>
# Last Modified Date....: <<7th March, 2010 >>
# Description...........: <<Custome rportal does not allows to edit report filters. This class helps to create a VF page where users can modifiy the filters in query parameneters.>>
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

public without sharing class ReportController 
{
	//Custome rportal does not allows to edit report filters. This class helps to create a VF page where users can modifiy the filters 
	//in query parameneters.
	public String strStartDate {get;set;}
	public String strEndDate {get;set;}	
	public String strClientName {get;set;}
	public String strTargetReport {get;set;}
	// Redirect to a report with ID passed from the page
	public PageReference goToReport()
	{
		return new PageReference('/' + strTargetReport + '?pv0=' + strStartDate + '&pv1=' + strEndDate + '&pv2=' + strClientName);
	}
}
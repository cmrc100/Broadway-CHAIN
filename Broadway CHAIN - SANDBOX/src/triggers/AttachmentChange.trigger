trigger AttachmentChange on Attachment (after delete, after insert) {

	if(trigger.isAfter && trigger.isInsert){
		
		AttachmentChangeTriggerHandler.attachmentChange(trigger.newMap);
		
	}

	if(trigger.isAfter && trigger.isDelete){
		
		AttachmentChangeTriggerHandler.attachmentChange(trigger.oldMap);
		
	}

}
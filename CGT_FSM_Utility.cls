/********************************************************************************************************
* @Author         ext.chandan.singh@cargotec.com
* @description    This is a utility Class.     
* @CreatedDate    01-02-2019
* @TestClass      CGT_Test_WorkOrder_Handler
* @Modified Date  

*********************************************************************************************************/  
    
public class CGT_FSM_Utility{
    public static String CGT_Sunday = 'Sunday';
    public static String CGT_Monday = 'Monday';
    public static String CGT_Tuesday = 'Tuesday';
    public static String CGT_Wednesday = 'Wednesday';
    public static String CGT_Thursday = 'Thursday';
    public static String CGT_Friday = 'Friday';
    public static String CGT_Saturday = 'Saturday';
    public static boolean isNotAfterInsert = true;
    public static boolean isNotInsert = true; // Used in assignedresource Trigger for SFF-1023
    public static boolean isUpdate = true;
     /********************************************************************************************************
    * @author         ext.chandan.singh@cargotec.com
    * @method          calculateDuration
    * @parameters      StartDate,EndDate,DurationType
    * @description     This method is used for calculating Duration based on StartDate and EndDate. In first line StartDate will be subtracted from EndDate to get 
                        duration in hours and then in second line it will be subtracted again to get duration in mins and then both time will be added and converted in hours
                        or mins.
    * @createdDate    01-02-2019
    * @return Decimal
    *********************************************************************************************************/
    public static Decimal calculateDuration (Datetime StartDate,DateTime EndDate,String DurationType) {
        Decimal duration ;
        if(DurationType == system.Label.CGT_Service_Appointment_Time){
         Decimal decHours = ((endDate.getTime())/1000/60/60) - ((startDate.getTime())/1000/60/60);
         Decimal decMin = ((endDate.getTime())/1000/60) - ((startDate.getTime())/1000/60);
         Decimal timeT = decMin-(decHours*60);
         Duration = decHours + (timeT/60);
        }
        else{
         Decimal decMin = ((endDate.getTime())/1000/60) - ((startDate.getTime())/1000/60);
         duration = decMin;
        }
        return duration;
        
    }
     /********************************************************************************************************
    * @Author         ext.chandan.singh@cargotec.com
    * @Method          calculateEndDate
    * @Parameters      StartDate,Duration,DurationType
    * @description     This method is used for calculating EndDate based on StartDate and Duration. Here Duration will be added in StartDate to give EndDate.
    * @CreatedDate     01-02-2019
    * @return          DateTime
    *********************************************************************************************************/
    public static DateTime calculateEndDate (Datetime StartDate,Decimal Duration,String DurationType) {
        DateTime EndDate;
        if(DurationType == system.Label.CGT_Service_Appointment_Time){
            Integer DurationinHrs = Duration.intValue();
            Integer DurationinMin = (Duration*60).intValue() - (DurationinHrs*60);
            endDate = startDate.addMinutes((DurationinHrs *60) + DurationinMin);
        }else{
            Integer DurationinMin = Duration.intValue();
            EndDate = startDate.addMinutes(DurationinMin);
        }
        return EndDate;
    }
    
/********************************************************************************************************
* @author        Tieto 
* @description    Getting StartDate of TimeSheet.
* @date           2019-03-24
* @group          Time Sheet
*********************************************************************************************************/ 
    public static Date timeSheetStartDate(Date startDate){
        Date timesheetStartDate;
        Date weekStart = startDate.toStartofWeek();
        DateTime weekStartTime = DateTime.newInstance(weekStart, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=weekStartTime.format('EEEE');
        String timeSheetEntryDay = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('EEEE');
        if(dayOfWeek.equalsIgnoreCase(CGT_Sunday)){
            if(timeSheetEntryDay.equalsIgnoreCase(CGT_Sunday)){
                timesheetStartDate = weekStartTime.Date().addDays(-6);
            }else{
                timesheetStartDate = weekStartTime.Date().addDays(1);
            }
        }else if (dayOfWeek.equalsIgnoreCase(CGT_Monday)){
            timesheetStartDate = weekStartTime.Date();
        }
        return timesheetStartDate;
    }
    
 /********************************************************************************************************
* @author        Tieto 
* @description    Getting First WOLI of WorkOrder.
* @date           2019-04-25
* @group          Time Sheet
* @param          woList
* @return         Map<Id,Id>
*********************************************************************************************************/ 
    public static Map<Id,Id> firstWOLIofWO(List<Id> woList){
    Set<Id> woSet = new Set<Id>();
    woset.addAll(woList);
        Map<Id,Id> woIdwoliIdMap = new Map<Id,Id>();
        List<WorkOrder> workOrderList = [SELECT
                                                Id,(Select Id from WorkOrderLineItems)
                                                FROM
                                                WorkOrder
                                                WHERE
                                                Id IN :woSet
                                            ];
                                            
        for(WorkOrder wo : workOrderList){   
            if(wo.WorkOrderLineItems != null && !wo.WorkOrderLineItems.isEmpty()){
                    woIdwoliIdMap.put(wo.id,wo.WorkOrderLineItems[0].Id);
            }
        }
        return woIdwoliIdMap;
        
    }
	 /********************************************************************************************************
	* @author        Tieto 
	* @description    This method returns client id and client secret based on events.
	* @date           01-17-2020
    * @group          Time Sheet
    * @ return         CGT_Synchronous_Organization_Settings__mdt
    * @param eventType
	*********************************************************************************************************/ 
	public static CGT_Synchronous_Organization_Settings__mdt getCustomMetadataAttributes(String eventType){
        CGT_Synchronous_Organization_Settings__mdt metadatarecord = [SELECT 
                                                                    CGT_Client_Id__c,CGT_Client_Secret__c,DeveloperName
                                                                    FROM 
                                                                    CGT_Synchronous_Organization_Settings__mdt 
                                                                    WHERE 
                                                                    DeveloperName = : eventType][0]; 
        System.debug('metadatarecord>>>> ' + metadatarecord);
        return metadatarecord;
    }
}